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
use ieee.std_logic_unsigned.all;

entity tb is
end tb;

architecture testbench of tb is

	-- test target
	component t80a
	port(
		RESET_n		: in std_logic;
		CLK_n			: in std_logic;
		WAIT_n		: in std_logic;
		INT_n			: in std_logic;
		NMI_n			: in std_logic;
		BUSRQ_n		: in std_logic;
		M1_n			: out std_logic;
		MREQ_n		: out std_logic;
		IORQ_n		: out std_logic;
		RD_n			: out std_logic;
		WR_n			: out std_logic;
		RFSH_n		: out std_logic;
		HALT_n		: out std_logic;
		BUSAK_n		: out std_logic;
		A				: out std_logic_vector(15 downto 0);
		D				: inout  std_logic_vector(7 downto 0)
	);
	end component;

	signal tb_end				: std_logic := '0';
	signal clock				: std_logic;								-- CLOCK
	signal reset_n				: std_logic;								-- /RESET
	signal cpu_wait_n			: std_logic;								-- /WAIT
	signal cpu_irq_n			: std_logic;								-- /IRQ
	signal cpu_nmi_n			: std_logic;								-- /NMI
	signal cpu_busreq_n		: std_logic;								-- /BUSREQ
	signal cpu_m1_n			: std_logic;								-- /M1
	signal cpu_mreq_n			: std_logic;								-- /MREQ
	signal cpu_ioreq_n		: std_logic;								-- /IOREQ
	signal cpu_rd_n			: std_logic;								-- /RD
	signal cpu_wr_n			: std_logic;								-- /WR
	signal cpu_rfsh_n			: std_logic;								-- /REFRESH
	signal cpu_halt_n			: std_logic;								-- /HALT
	signal cpu_busak_n		: std_logic;								-- /BUSAK
	signal cpu_a				: std_logic_vector(15 downto 0);		-- A
	signal cpu_data				: std_logic_vector(7 downto 0);
	signal cpu_do				: std_logic_vector(7 downto 0);
	
begin

	--  instance
	u_target: t80a
	port map(
		RESET_n		=> reset_n,
		CLK_n		=> clock,
		WAIT_n		=> cpu_wait_n,
		INT_n		=> cpu_irq_n,
		NMI_n		=> cpu_nmi_n,
		BUSRQ_n		=> cpu_busreq_n,
		M1_n		=> cpu_m1_n,
		MREQ_n		=> cpu_mreq_n,
		IORQ_n		=> cpu_ioreq_n,
		RD_n		=> cpu_rd_n,
		WR_n		=> cpu_wr_n,
		RFSH_n		=> cpu_rfsh_n,
		HALT_n		=> cpu_halt_n,
		BUSAK_n		=> cpu_busak_n,
		A			=> cpu_a,
		D			=> cpu_data
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock <= '0';
		wait for 140 ns;		-- 3.57 MHz
		clock <= '1';
		wait for 140 ns;
	end process;

	--
	--
	--
	process (cpu_a)
	begin
		case cpu_a is
			when X"0000" => cpu_do <= X"ED";		-- IM 2
			when X"0001" => cpu_do <= X"5E";		-- "
			when X"0002" => cpu_do <= X"FB";		-- EI
			when X"0003" => cpu_do <= X"00";		--
			when X"0004" => cpu_do <= X"00";		-- 
			when X"0005" => cpu_do <= X"00";		--
			when X"0006" => cpu_do <= X"00";		-- 
			when X"0007" => cpu_do <= X"00";		-- 
			when X"0008" => cpu_do <= X"00";		--
			when X"0009" => cpu_do <= X"00";		-- 
			when X"000A" => cpu_do <= X"00";		--
			when X"000B" => cpu_do <= X"00";		-- 
			when X"000C" => cpu_do <= X"00";		-- 
			when X"000D" => cpu_do <= X"00";		--
			when X"000E" => cpu_do <= X"00";		-- 
			when X"000F" => cpu_do <= X"00";		-- 
			when others  => cpu_do <= X"00";		-- 
		end case;

	end process;

--	cpu_data	<= cpu_do			when (cpu_mreq_n = '0' or cpu_ioreq_n = '0') and cpu_rd_n = '0'	else
--					(others => 'Z')	when (cpu_mreq_n = '0' or cpu_ioreq_n = '0') and cpu_wr_n = '0'	else
--					X"AA";

	cpu_data	<= cpu_do			when (cpu_mreq_n = '0' or cpu_ioreq_n = '0') and cpu_rd_n = '0'	else
					X"AA"			when cpu_ioreq_n = '0' and cpu_wr_n = '1' and cpu_rd_n = '1'	else
--					X"AA"			when cpu_ioreq_n = '0' and cpu_mreq_n = '0'						else
					(others => 'Z');

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		cpu_wait_n		<= '1';
		cpu_irq_n		<= '1';
		cpu_nmi_n		<= '1';
		cpu_busreq_n	<= '1';

		-- reset
		reset_n	<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		reset_n	<= '1';
		wait until( rising_edge(clock) );

		for i in 0 to 12 loop
			wait until( rising_edge(clock) );
		end loop;

		cpu_irq_n <= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_irq_n <= '1';

		for i in 0 to 30 loop
			wait until( rising_edge(clock) );
		end loop;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end architecture;
