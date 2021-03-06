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
use ieee.numeric_std.all;

entity kempston_mouse is
	port 
	(
		clk				: in   std_logic;
		rst_n				: in   std_logic;
		cpu_a				: in   std_logic_vector(15 downto 0);
		cpu_iorq_n		: in   std_logic;
		cpu_rd_n			: in   std_logic;
		enable			: in   std_logic;								-- "1" habilita a interface 
		-- entradas
		mouse_x			: in   std_logic_vector(7 downto 0);	
		mouse_y			: in   std_logic_vector(7 downto 0);			
		mouse_bts		: in   std_logic_vector(2 downto 0);		
		mouse_wheel		: in   std_logic_vector(3 downto 0);	
		-- Saida
		mouse_d			: out  std_logic_vector(7 downto 0);
		mouse_out		: out  std_logic								-- "1" se temos dados prontos para o barramento 
	);
end;

architecture kempston_mouse_arch of kempston_mouse is

	signal mouse_read_x  : std_logic;
	signal mouse_read_y  : std_logic;
	signal mouse_read_bt : std_logic;

begin

	-- Logica de selecao de acordo com esquema
	mouse_read_x   <= '1' when enable = '1' and cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(5) = '0' and cpu_a(11 downto 8) = "1011" else '0'; -- 64479 - fbdf
	mouse_read_y   <= '1' when enable = '1' and cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(5) = '0' and cpu_a(11 downto 8) = "1111" else '0'; -- 65503 - ffdf
	mouse_read_bt  <= '1' when enable = '1' and cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(5) = '0' and cpu_a(11 downto 8) = "1010" else '0'; -- 64223 - fadf
		
	-- Alguma documentacao usava essas portas, deixei só pra lembrar
--	mouse_read_x   <= '1' when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(15 downto 0) = X"ED9B" else '0'; -- 60827 - ED9B 
--	mouse_read_y   <= '1' when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(15 downto 0) = X"ED9C" else '0'; -- 60828 - ED9C 
--	mouse_read_bt  <= '1' when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a(15 downto 0) = X"EA60" else '0'; -- 60000 - EA60 

	-- Saidas
	mouse_d <= 	mouse_x when mouse_read_x  = '1' else 
					mouse_y when mouse_read_y  = '1' else 
					mouse_wheel & '1' & not mouse_bts(2) & not mouse_bts(0) & not mouse_bts(1) when mouse_read_bt = '1' else 
					(others=>'Z');

	mouse_out <= '1' when mouse_read_x = '1' or  mouse_read_y = '1' or mouse_read_bt = '1'  else '0';

end kempston_mouse_arch;
