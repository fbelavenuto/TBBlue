--
-- TBBlue / ZX Spectrum Next project
-- Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--

library ieee;
use ieee.std_logic_1164.all;

entity multiface is
	port
	(
		clock_i					: in    std_logic;							-- CPU clock
		reset_n_i				: in    std_logic;
		cpu_addr_i				: in    std_logic_vector(15 downto 0);
		data_i					: in    std_logic_vector(7 downto 0);
		data_o					: out   std_logic_vector(7 downto 0);  	
		has_data_o				: out   std_logic;
		cpu_mreq_n_i			: in    std_logic;
		cpu_iorq_n_i			: in    std_logic;
		cpu_rd_n_i				: in    std_logic;
		cpu_wr_n_i				: in    std_logic;
		cpu_m1_n_i				: in    std_logic;
		nmi_button_n_i			: in    std_logic;
		nmi_to_cpu_n_o			: out   std_logic;
		-- Multiface interface control
		enable_i					: in    std_logic;
		mode_i					: in 	  integer range 0 to 3;
		zxromcs_o				: out   std_logic;    
		-- RAM and ROM
		m1_rom_cs_n_o			: out   std_logic;
		m1_ram_cs_n_o			: out   std_logic;   
		m1_ram_we_n_o			: out   std_logic;
		m1_7ffd_i				: in    std_logic_vector(7 downto 0);
		m1_1ffd_i				: in    std_logic_vector(7 downto 0)
	);
end entity;

architecture Behavior of multiface is

	signal port_rd_en_s	: std_logic;
	signal port_in_s		: std_logic_vector( 3 downto 0);
	signal port_out_s		: std_logic_vector( 3 downto 0);
	signal enabled_q		: std_logic;
	signal nmi_ctl_q		: std_logic;
	signal locked_out		: std_logic := '0';

begin

	port_rd_en_s	<= '1'	when cpu_iorq_n_i = '0' and cpu_rd_n_i = '0'	else '0';

	----------------------------------------------
	-- Multiface one : entra em 9F, sai em 1F
	-- Multiface 128 : entra em BF, sai em 3F
	-- Multiface +3  : entra em 3F, sai em BF
	----------------------------------------------
	-- Set addresses
	process(mode_i)
	begin
		case mode_i is
			when 0 | 1 =>
				port_in_s	<= X"9";		-- MF1 entra em 0x9f
				port_out_s	<= X"1";		-- sai em 0x1f
			when 2 =>
				port_in_s	<= X"B";		-- MF128 entra em 0xbF
				port_out_s	<= X"3";		-- sai em 0x3f
			when 3 =>
				port_in_s	<= X"3";		-- MF3 entra em 0x3f
				port_out_s	<= X"B";		-- sai em 0xBF
			when others =>
				null;
		end case;
	end process;

	-- Enable/Disable interface
	process (reset_n_i, clock_i, enable_i)
	begin
		if reset_n_i = '0' then
			enabled_q <= '0';
		elsif falling_edge(clock_i) and enable_i = '1' then
			if cpu_mreq_n_i = '0' and cpu_m1_n_i = '0' and cpu_addr_i(15 downto 0) = X"0066" and nmi_ctl_q = '1' then	-- Memory access in 0x0066
				enabled_q <= '1';
			elsif port_rd_en_s = '1' and cpu_addr_i(3 downto 0) = "1111" then			-- I/O read
				if cpu_addr_i(7 downto 4) = port_in_s then
					enabled_q <= '1';
				elsif cpu_addr_i(7 downto 4) = port_out_s  then
					enabled_q <= '0';
				end if;
			end if;
		end if;
	end process;

	process (reset_n_i, clock_i, enable_i)
	begin
		if reset_n_i = '0' then
			nmi_ctl_q <= '0';
		elsif falling_edge(clock_i) and enable_i = '1' then
			if nmi_button_n_i = '0' and nmi_ctl_q = '0' then
				nmi_ctl_q <= '1';
			elsif cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_addr_i(1) = '1' and cpu_addr_i(6 downto 4) = port_in_s(2 downto 0) then
				nmi_ctl_q <= '0';
			end if;
		end if;
	end process;

	--
	zxromcs_o <= enabled_q;

	m1_rom_cs_n_o	<= '0' when cpu_addr_i(15 downto 13) = "000" and cpu_mreq_n_i = '0' and enabled_q = '1' and locked_out = '0'	else '1';		-- Rom de 0000 a 8191
   m1_ram_cs_n_o	<= '0' when cpu_addr_i(15 downto 13) = "001" and cpu_mreq_n_i = '0' and enabled_q = '1' and locked_out = '0'	else '1';		-- RAM de 8192 a 16383
	m1_ram_we_n_o	<= cpu_wr_n_i;

	nmi_to_cpu_n_o	<= not nmi_ctl_q;
	
	-- Especificos para a M128 e M3
	
	-- A port write to port $3F enables the software lock out. A read from $BF then won't page in the Multiface. The NMI button overrides this lockout. 
	locked_out <= '1' when mode_i = 2 and cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_addr_i(7 downto 4) = port_out_s and cpu_addr_i(3 downto 0) = "1111" else
					  '0' when nmi_button_n_i = '0' and nmi_ctl_q = '0';

	-- Na M128, guardamos o D3 do barramento de 0x7FFD e repassamos para o bit 7 no IN 0xBF
	-- Na M3, um IN em 0x1F3f serve os dados de 0x1ffd e um IN em 0x7F3f serve os dados de 0x7ffd, mas somente se a Multiface estiver ativa
	
	data_o	<= m1_1ffd_i						when enable_i = '1' and mode_i = 3 and port_rd_en_s = '1' and cpu_addr_i = X"1F3F" else 	
					m1_7ffd_i						when enable_i = '1' and mode_i = 3 and port_rd_en_s = '1' and cpu_addr_i = X"7F3F" else
					m1_7ffd_i(3) & "1111111"	when enable_i = '1' and locked_out = '0' and mode_i = 2 and port_rd_en_s = '1' and cpu_addr_i(7 downto 0) = X"BF"	else
					(others => 'Z');

	-- Avisamos ao top q tem dados a serem coletados
	has_data_o	<= '1' when enable_i = '1' and mode_i = 3 and port_rd_en_s = '1' and (cpu_addr_i = X"1F3F" or cpu_addr_i = X"7F3F") and enabled_q = '1'	else
						'1' when enable_i = '1' and locked_out = '0' and mode_i = 2 and port_rd_en_s = '1' and cpu_addr_i(7 downto 0) = X"BF"	else
						'0';

end architecture;
