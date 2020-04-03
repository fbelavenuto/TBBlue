--
-- TBBlue / ZX Spectrum Next project
-- Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
-- Copyright (c) ? - (original author unknown!)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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

-- PS/2 scancode to Spectrum matrix conversion
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.keyscans.all;

entity keyboard is
	generic (
		clkfreq_g		: integer										-- This is the system clock value in kHz
	);
	port (
		enable			: in    std_logic;
		clock				: in    std_logic;
		reset				: in    std_logic;
		-- PS/2 interface
		ps2_clk			: inout std_logic;
		ps2_data			: inout std_logic;
		-- CPU address bus (row)
		rows				: in    std_logic_vector(7 downto 0);
		-- Column outputs to ULA
		cols				: out   std_logic_vector(4 downto 0);
		functionkeys_o	: out   std_logic_vector(11 downto 0);
		core_reload_o	: out   std_logic
	);
end keyboard;

architecture rtl of keyboard is

	-- Interface to PS/2 block
	signal keyb_data       : std_logic_vector(7 downto 0);
	signal keyb_valid      : std_logic;

	-- Internal signals
	type key_matrix is array (7 downto 0) of std_logic_vector(4 downto 0);
	signal keys					: key_matrix;
	signal release				: std_logic;
	signal extended			: std_logic;
	signal k1, k2, k3, k4,
		    k5, k6, k7, k8	: std_logic_vector(4 downto 0);

	signal idata				: std_logic_vector(7 downto 0);
	signal idata_rdy			: std_logic                     	:= '0';
	signal ctrl_s				: std_logic								:= '1';
	signal alt_s				: std_logic								:= '1';

begin

	-- PS/2 interface
	ps2 : entity work.ps2_iobase
	generic map (
		clkfreq			=> clkfreq_g
	)
	port map (
		enable			=> enable,
		clock				=> clock,
		reset				=> reset,
		ps2_clk			=> ps2_clk,
		ps2_data			=> ps2_data,
		idata_rdy		=> idata_rdy,
		idata				=> idata,
		send_rdy			=> open,
		odata_rdy		=> keyb_valid,
		odata				=> keyb_data
	);
		
	-- Mesclagem das linhas
	k1 <= keys(0) when rows(0) = '0' else (others => '1');
	k2 <= keys(1) when rows(1) = '0' else (others => '1');
	k3 <= keys(2) when rows(2) = '0' else (others => '1');
	k4 <= keys(3) when rows(3) = '0' else (others => '1');
	k5 <= keys(4) when rows(4) = '0' else (others => '1');
	k6 <= keys(5) when rows(5) = '0' else (others => '1');
	k7 <= keys(6) when rows(6) = '0' else (others => '1');
	k8 <= keys(7) when rows(7) = '0' else (others => '1');
	cols <= k1 and k2 and k3 and k4 and k5 and k6 and k7 and k8;

	process(reset, clock)
		variable keyb_valid_edge : std_logic_vector(1 downto 0)	:= "00";
		variable sendresp        : std_logic := '0';
	begin
		if reset = '1' then
			keyb_valid_edge	:= "00";
			release 				<= '0';
			extended 			<= '0';

			keys(0) <= (others => '1');
			keys(1) <= (others => '1');
			keys(2) <= (others => '1');
			keys(3) <= (others => '1');
			keys(4) <= (others => '1');
			keys(5) <= (others => '1');
			keys(6) <= (others => '1');
			keys(7) <= (others => '1');

			functionkeys_o <= (others => '0');
			alt_s		<= '1';
			ctrl_s	<= '1';

		elsif rising_edge(clock) then
			core_reload_o <= '0';

			keyb_valid_edge := keyb_valid_edge(0) & keyb_valid;
			if keyb_valid_edge = "01" then
				if keyb_data = X"AA" then
					sendresp := '1';
				elsif keyb_data = X"E0" then	-- Extended key code follows
					extended <= '1';
				elsif keyb_data = X"F0" then	-- Release code follows
					release <= '1';
				else
					-- Cancel extended/release flags for next time
					release <= '0';
					extended <= '0';

					if extended = '0' then
						-- Normal scancodes
						case keyb_data is
							when KEY_LSHIFT		=> keys(0)(0) <= release; -- Left shift (CAPS SHIFT)
							when KEY_RSHIFT 		=> keys(0)(0) <= release; -- Right shift (CAPS SHIFT)
							when KEY_Z      		=> keys(0)(1) <= release; -- Z
							when KEY_X 				=> keys(0)(2) <= release; -- X
							when KEY_C 				=> keys(0)(3) <= release; -- C
							when KEY_V 				=> keys(0)(4) <= release; -- V

							when KEY_A 				=> keys(1)(0) <= release; -- A
							when KEY_S 				=> keys(1)(1) <= release; -- S
							when KEY_D 				=> keys(1)(2) <= release; -- D
							when KEY_F 				=> keys(1)(3) <= release; -- F
							when KEY_G 				=> keys(1)(4) <= release; -- G

							when KEY_Q 				=> keys(2)(0) <= release; -- Q
							when KEY_W 				=> keys(2)(1) <= release; -- W
							when KEY_E 				=> keys(2)(2) <= release; -- E
							when KEY_R 				=> keys(2)(3) <= release; -- R
							when KEY_T 				=> keys(2)(4) <= release; -- T

							when KEY_1 				=> keys(3)(0) <= release; -- 1
							when KEY_2 				=> keys(3)(1) <= release; -- 2
							when KEY_3 				=> keys(3)(2) <= release; -- 3
							when KEY_4 				=> keys(3)(3) <= release; -- 4
							when KEY_5 				=> keys(3)(4) <= release; -- 5

							when KEY_0 				=> keys(4)(0) <= release; -- 0
							when KEY_9 				=> keys(4)(1) <= release; -- 9
							when KEY_8 				=> keys(4)(2) <= release; -- 8
							when KEY_7 				=> keys(4)(3) <= release; -- 7
							when KEY_6 				=> keys(4)(4) <= release; -- 6

							when KEY_P 				=> keys(5)(0) <= release; -- P
							when KEY_O 				=> keys(5)(1) <= release; -- O
							when KEY_I 				=> keys(5)(2) <= release; -- I
							when KEY_U 				=> keys(5)(3) <= release; -- U
							when KEY_Y 				=> keys(5)(4) <= release; -- Y

							when KEY_ENTER 		=> keys(6)(0) <= release; -- ENTER
							when KEY_L 				=> keys(6)(1) <= release; -- L
							when KEY_K 				=> keys(6)(2) <= release; -- K
							when KEY_J 				=> keys(6)(3) <= release; -- J
							when KEY_H 				=> keys(6)(4) <= release; -- H

							when KEY_SPACE 		=> keys(7)(0) <= release; -- SPACE
							when KEY_LCTRL 		=> keys(7)(1) <= release; -- Left CTRL (Symbol Shift)
															ctrl_s <= release;
							when KEY_M 				=> keys(7)(2) <= release; -- M
							when KEY_N 				=> keys(7)(3) <= release; -- N
							when KEY_B 				=> keys(7)(4) <= release; -- B

							when KEY_KP0         => keys(4)(0) <= release; -- 0
							when KEY_KP1			=> keys(3)(0) <= release; -- 1
							when KEY_KP2			=> keys(3)(1) <= release; -- 2
							when KEY_KP3			=> keys(3)(2) <= release; -- 3
							when KEY_KP4			=> keys(3)(3) <= release; -- 4
							when KEY_KP5			=> keys(3)(4) <= release; -- 5
							when KEY_KP6			=> keys(4)(4) <= release; -- 6
							when KEY_KP7			=> keys(4)(3) <= release; -- 7
							when KEY_KP8			=> keys(4)(2) <= release; -- 8
							when KEY_KP9			=> keys(4)(1) <= release; -- 9
							
							-- Teclas para o FPGA e nao para o Speccy
							when KEY_F1				=> functionkeys_o(0)		<= not release;
							when KEY_F2				=> functionkeys_o(1)		<= not release;
							when KEY_F3				=> functionkeys_o(2)		<= not release;
							when KEY_F4				=> functionkeys_o(3)		<= not release;
							when KEY_F5				=> functionkeys_o(4)		<= not release;
							when KEY_F6				=> functionkeys_o(5)		<= not release;
							when KEY_F7				=> functionkeys_o(6)		<= not release;
							when KEY_F8				=> functionkeys_o(7)		<= not release;
							when KEY_F9				=> functionkeys_o(8)		<= not release;
							when KEY_F10			=> functionkeys_o(9)		<= not release;
							when KEY_F11			=> functionkeys_o(10)	<= not release;
							when KEY_F12			=> functionkeys_o(11)	<= not release;

							-- Other special keys sent to the ULA as key combinations
							when KEY_BACKSPACE	=> keys(0)(0) <= release; -- Backspace (CAPS 0)
															keys(4)(0) <= release;
															if alt_s = '0' and ctrl_s = '0' then
																core_reload_o <= '1';
															end if;
							when KEY_CAPSLOCK		=> keys(0)(0) <= release; -- Caps lock (CAPS 2)
															keys(3)(1) <= release;
							when KEY_ESC			=> keys(0)(0) <= release; -- Escape (CAPS SPACE)
															keys(7)(0) <= release;
							when KEY_BL				=> keys(7)(1) <= release; -- ' (SYMBOL + 7)
															keys(4)(3) <= release;
							when KEY_MINUS			=> keys(7)(1) <= release; -- - (SYMBOL + J)
															keys(6)(3) <= release;
							when KEY_KPMINUS		=> keys(7)(1) <= release; -- - (SYMBOL + J)
															keys(6)(3) <= release;
							when KEY_EQUAL			=> keys(7)(1) <= release; -- = (SYMBOL + L)
															keys(6)(1) <= release;
							when KEY_COMMA       => keys(7)(1) <= release; -- , (SYMBOL + N)
															keys(7)(3) <= release;
							when KEY_KPCOMMA		=> keys(7)(1) <= release; -- , (SYMBOL + N)
															keys(7)(3) <= release;
							when KEY_POINT			=> keys(7)(1) <= release; -- . (SYMBOL + M)
															keys(7)(2) <= release;
							when KEY_KPPOINT		=> keys(7)(1) <= release; -- . (SYMBOL + M)
															keys(7)(2) <= release;
							when KEY_SLASH 		=> keys(7)(1) <= release; -- / (SYMBOL + V)
															keys(0)(4) <= release;
							when KEY_TWOPOINT		=> keys(7)(1) <= release; -- ; (SYMBOL + O)
															keys(5)(1) <= release;
							when KEY_KPASTER		=> keys(7)(1) <= release; -- * (SYMBOL + B)
															keys(7)(4) <= release;
							when KEY_KPPLUS		=> keys(7)(1) <= release; -- + (SYMBOL + K)
															keys(6)(2) <= release;
							when KEY_LALT			=> alt_s <= release;
							when others =>
								null;
						end case;
					else
						-- Extended scancodes
						case keyb_data is

							when KEY_KPENTER 		=> keys(6)(0) <= release; -- ENTER
							when KEY_LWIN			=> keys(7)(0) <= release; -- SPACE
							when KEY_RWIN			=> keys(7)(0) <= release; -- SPACE

							-- Cursor keys
							when KEY_LEFT			=>	keys(3)(4) <= release; -- Left (CAPS 5)
--															keys(0)(0) <= release;
							when KEY_DOWN			=>	keys(4)(4) <= release; -- Down (CAPS 6)
--															keys(0)(0) <= release;
							when KEY_UP				=>	keys(4)(3) <= release; -- Up (CAPS 7)
--															keys(0)(0) <= release;
							when KEY_RIGHT			=>	keys(4)(2) <= release; -- Right (CAPS 8)
--															keys(0)(0) <= release;
							when KEY_RCTRL			=> keys(7)(1) <= release; -- Right CTRL (Symbol Shift)
															ctrl_s <= release;

							-- Other special keys sent to the ULA as key combinations
							when KEY_KPSLASH 		=> keys(7)(1) <= release; -- / (SYMBOL + V)
															keys(0)(4) <= release;

							when KEY_RALT			=> alt_s <= release;

							when others =>
								null;
						end case;
					end if; -- extended = 0
				end if; -- keyb_data = F0
			else -- keyb_valid_edge = 01
				if sendresp = '1' then
					sendresp 	:= '0';
					idata			<= X"55";
					idata_rdy	<= '1';
				else
					idata_rdy	<= '0';
				end if;
			end if; -- keyb_valid_edge = 01
		end if; -- rising_edge
	end process;

end architecture;
