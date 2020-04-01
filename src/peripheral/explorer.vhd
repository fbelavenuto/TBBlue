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

entity explorer is
port 
(
	clk						: in    std_logic;  -- Clock alto (> 6 MHz)
	clk_psg					: in    std_logic;  -- Sinal de clock de 1.75 MHz
	rst_n						: in    std_logic;
	cpu_a						: in    std_logic_vector(15 downto 0);
	cpu_di					: in    std_logic_vector(7 downto 0);
	cpu_do					: out   std_logic_vector(7 downto 0);
	cpu_iorq_n				: in    std_logic;
	cpu_rd_n					: in    std_logic;
	cpu_wr_n					: in    std_logic;
	cpu_m1_n					: in    std_logic;
	
	-- audio
	out_audio_mix        : out std_logic_vector(7 downto 0);
	
	-- controles
	enable					: in  std_logic; 		-- "1" habilita a interface  
	selected					: in  std_logic; 		-- "1" when receiving data  
	psg_out 					: out std_logic;  	-- "1" se temos dados prontos para o barramento   
	ctrl_aymode				: in std_logic; 		-- 0 = YM, 1 = AY
	
	-- pinos para controle de AY externo
	BDIR						: out std_logic;		
	BC1						: out std_logic;

	-- Serial
	rs232_rx					: in  std_logic		:= '0';
	rs232_tx					: out std_logic;
	rs232_cts				: out std_logic;
	rs232_dtr				: in  std_logic		:= '0'
);
end explorer;

architecture explorer_arch of explorer is

	signal psg_do					: std_logic_vector(7 downto 0)	:= "11111111";
	signal psg_addr				: std_logic;
	signal psg_we					: std_logic;
	signal psg_re					: std_logic;
	signal psg_chMix				: std_logic_vector(7 downto 0)	:= "00000000";
	signal psg_BDIR				: std_logic;		-- para AY externo
	signal psg_BC1					: std_logic;		-- para AY externo
	signal port_a_o				: std_logic_vector(7 downto 0);
	signal port_a_i				: std_logic_vector(7 downto 0);

begin

	psg : entity work.YM2149
	port map (
		CLK				=> clk,					-- Clock alto (> 6 MHz)
		ENA				=> clk_psg,				-- Sinal de enable a 1.75 MHz
		RESET_L			=> rst_n,
		I_SEL_L			=> '1', 					-- /SEL is high for AY-3-8912 compatibility

		I_DA				=> cpu_di,				-- Entrada de dados
		O_DA				=> psg_do,				-- Saida de dados

		busctrl_addr	=> psg_addr,			-- 1 grava o endereco do registrador
		busctrl_we		=> psg_we,				-- 1 grava o valor no registrador setado anteriormente
		busctrl_re		=> psg_re,				-- 1 le o valor do registrador setado anteriormente
		ctrl_aymode		=> ctrl_aymode,			-- 0 = YM, 1 = AY

		port_a_i			=> port_a_i,
		port_a_o			=> port_a_o,
		port_b_i			=> (others => '0'),
		port_b_o			=> open,

		O_AUDIO_A		=> open,					-- Sai­da do canal A
		O_AUDIO_B		=> open,					-- Sai­da do canal B
		O_AUDIO_C		=> open,					-- Sai­da do canal C
		O_AUDIO			=> out_audio_mix		-- Saida mixada dos 3 canais
	);

	psg_BDIR <= '1' when enable = '1' and selected = '1' and cpu_iorq_n = '0' and cpu_m1_n = '1' and cpu_a(15) = '1' and cpu_a(2 downto 0) = "101" and cpu_wr_n = '0' else '0';
	psg_BC1  <= '1' when enable = '1' and selected = '1' and cpu_iorq_n = '0' and cpu_m1_n = '1' and cpu_a(15 downto 14) = "11" and cpu_a(2 downto 0) = "101" else '0';

	psg_addr <= '1' when psg_BDIR ='1' and psg_BC1 = '1' else '0'; -- Escrita na porta FFFD seta endereco registrador
	psg_re 	<= '1' when psg_BDIR ='0' and psg_BC1 = '1' else '0'; -- Leitura na porta FFFD le valor registrador
	psg_we   <= '1' when psg_BDIR ='1' and psg_BC1 = '0' else '0'; -- Escrita na porta BFFD seta valor registrador

	-- Saida dos dados para o barramento caso a interface estiver sendo lida
	cpu_do <=  psg_do	when psg_re = '1' and selected = '1' 	else			-- Leitura da porta FFFD (AY)
				 (others=>'Z');
	
	psg_out <= psg_re;
	
	BDIR <= psg_BDIR;
	BC1  <= psg_BC1;

	port_a_i  <= rs232_rx & rs232_dtr & "111111";
	rs232_tx  <= port_a_o(3);
	rs232_cts <= port_a_o(2);

--	port_a_i  <= "0000" & rs232_rx & rs232_dtr & "00";
--	rs232_tx  <= port_a_o(7);
--	rs232_cts <= port_a_o(6);


end explorer_arch;
