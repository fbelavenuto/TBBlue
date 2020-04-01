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

entity joystick_keys is
port 
(
	-- controle
	cpu_a							: in    std_logic_vector(15 downto 0);
	enable						: in    std_logic; 	 		-- "1" habilita a interface  

	-- modos
	joy0_mode					: in std_logic_vector(1 downto 0);
	joy1_mode					: in std_logic_vector(1 downto 0);
		
	-- entradas
	joy0_pins					: in  std_logic_vector(7 downto 0);
	joy1_pins					: in  std_logic_vector(7 downto 0);
	
	-- Saida
	joy_columns					: out    std_logic_vector(4 downto 0)	

);
end joystick_keys;

architecture joystick_keys_arch of joystick_keys is
                             
signal iJoy0Fire, iJoy0Fire2, iJoy0Up, iJoy0Down, iJoy0Right, iJoy0Left,
		 iJoy1Left, iJoy1Right, iJoy1Down, iJoy1Up, iJoy1Fire, iJoy1Fire2 : std_logic;

begin

	iJoy0Fire2	<= joy0_pins(5);
	iJoy0Fire 	<= joy0_pins(4);
	iJoy0Up 		<= joy0_pins(3);
	iJoy0Down 	<= joy0_pins(2);
	iJoy0Left 	<= joy0_pins(1);
	iJoy0Right 	<= joy0_pins(0);

	iJoy1Fire2	<= joy1_pins(5);
	iJoy1Fire 	<= joy1_pins(4);
	iJoy1Up 		<= joy1_pins(3);
	iJoy1Down 	<= joy1_pins(2);
	iJoy1Left 	<= joy1_pins(1);
	iJoy1Right 	<= joy1_pins(0);
	
	-- Teclado e joystick
	-- Sinclair:
	-- Joy0:  6 (left), 7 (right), 8 (down), 9 (up), 0 (fire), A (fire2)
	-- Joy1:  1 (left), 2 (right), 3 (down), 4 (up), 5 (fire), S (fire2)
	-- Cursor
	-- 5 (left), 6 (down), 7 (up), 8 (right), 0 (fire), A (fire2)


	process (enable, joy0_mode, joy1_mode, cpu_a,
	         iJoy0Fire, iJoy0Fire2, iJoy0Up, iJoy0Down, iJoy0Right, iJoy0Left,
				iJoy1Left, iJoy1Right, iJoy1Down, iJoy1Up, iJoy1Fire, iJoy1Fire2)
				
		variable jr1 : std_logic_vector(4 downto 0);
		variable jr2 : std_logic_vector(4 downto 0);
		variable jr3 : std_logic_vector(4 downto 0);
		
	begin
	
		jr1 := (others => '1');
		jr2 := (others => '1');
		jr3 := (others => '1');
		
		-- Joystick 0
		if joy0_mode = "00" then	
		-- Sinclair
			if cpu_a(10) = '0' then
				jr3(0) := not iJoy0Fire2;
			end if;
			
			if cpu_a(12) = '0' then
				jr1 := not (iJoy0Left & iJoy0Right & iJoy0Down & iJoy0Up & iJoy0Fire);
			end if;
			
		elsif joy0_mode = "10" then						-- Cursor
		
			if cpu_a(10) = '0' then
				jr3(0) := not iJoy0Fire2;
			end if;
			
			if cpu_a(11) = '0' then
				jr1 := not (iJoy0Left & "0000");
			end if;
			
			if cpu_a(12) = '0' then
				jr2 := not (iJoy0Down & iJoy0Up & iJoy0Right & '0' & iJoy0Fire);
			end if;
			
		end if;
		
		-- Joystick 1
		if joy1_mode = "00" then							-- Sinclair
		
			if cpu_a(10) = '0' then
				jr3(1) := not iJoy1Fire2;
			end if;
			
			if cpu_a(11) = '0' then
				jr2 := not (iJoy1Fire & iJoy1Up & iJoy1Down & iJoy1Right & iJoy1Left);
			end if;
			
		elsif joy1_mode = "10" then						-- Cursor
		
			if cpu_a(10) = '0' then
				jr3(0) := not iJoy1Fire2;
			end if;
			
			if cpu_a(11) = '0' then
				jr1(4) := not iJoy1Left;
			end if;
			
			if cpu_a(12) = '0' then
				jr2 := not (iJoy1Down & iJoy1Up & iJoy1Right & '0' & iJoy1Fire);
			end if;
			
		end if;
		
		if enable = '1' then
			joy_columns <= jr1 and jr2 and jr3;
		else
			joy_columns <= (others => '1');
		end if;

	end process;
	

end joystick_keys_arch;
