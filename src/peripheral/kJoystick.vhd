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

entity kempston_joystick is
port 
(
	cpu_a						: in    std_logic_vector(15 downto 0);
	cpu_iorq_n				: in    std_logic;
	cpu_rd_n					: in    std_logic;

	-- pinos do joystick
	joy_pins					: in    std_logic_vector(7 downto 0);
	
	-- controle
	enable					: in    std_logic; 	 		-- "1" habilita a interface  

	-- Saida
	kj_do						: out   std_logic_vector(7 downto 0);
	kj_out					: out   std_logic := '0' 	-- "1" se a interface esta disponibilizando dados

);
end kempston_joystick;

architecture kempston_joystick_arch of kempston_joystick is

	signal kj_port_en : std_logic;

begin

	kj_port_en  <= '1' when  enable = '1' and cpu_iorq_n = '0' and cpu_a( 5 downto 0 ) = "011111" and cpu_rd_n = '0' else '0';   -- Porta 1F (31) 

	kj_do <= joy_pins when kj_port_en = '1' else (others=>'Z');

	kj_out <= kj_port_en;

end kempston_joystick_arch;
