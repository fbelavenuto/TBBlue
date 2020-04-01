--
-- TBBlue / ZX Spectrum Next project
-- Based on ula_radas.v - Copyright (c) 2015 - ZX-Uno Team (www.zxuno.com)
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

entity overlay is
	generic (
		DEBUG		: boolean := false
	);
	port (
		clock_28_i		: in  std_logic;
		reset_n_i			: in  std_logic;
			
		overlay_en_i	: in  std_logic := '1';

		overlay_X_i		: in unsigned(8 downto 0);
		overlay_Y_i		: in unsigned(8 downto 0);
		offset_x_i		: in std_logic_vector(7 downto 0);
		offset_y_i		: in std_logic_vector(5 downto 0);
		
		overlay_addr_o : out std_logic_vector(15 downto 0) := X"0000";
		overlay_data_i : in std_logic_vector(7 downto 0);
		
		overlay_R_o		: out std_logic_vector(2 downto 0);
		overlay_G_o		: out std_logic_vector(2 downto 0);
		overlay_B_o		: out std_logic_vector(1 downto 0);
		
		pixel_en_o		: out std_logic

	);
end entity;

architecture rtl of overlay is



	signal overlay_addr_s			: std_logic_vector(15 downto 0);
	signal pixel_en_s					: std_logic := '0';
	signal overlay_X_s				: unsigned(8 downto 0); 
	signal overlay_Y_s				: unsigned(8 downto 0); 
	signal overlay_R_s				: std_logic_vector(2 downto 0);
	signal overlay_G_s				: std_logic_vector(2 downto 0);
	signal overlay_B_s				: std_logic_vector(1 downto 0);

begin

	overlay_X_s <= Overlay_X_i - 12; --why 12 pixels???

	process (reset_n_i, overlay_X_s, overlay_Y_i, offset_x_i, offset_y_i)
		variable sum_x_v	: unsigned(8 downto 0);
		variable sum_y_v	: unsigned(8 downto 0);		
	begin
		sum_x_v := overlay_X_s + unsigned(offset_x_i);
		sum_y_v := overlay_Y_i + unsigned(offset_y_i);
		if reset_n_i = '0' then
			overlay_addr_s <= X"0000";
		else
			if (overlay_X_s <= 256 and overlay_Y_i <= 256) then
				overlay_addr_s <= std_logic_vector(sum_y_v(7 downto 0)) & std_logic_vector(sum_x_v(7 downto 0));
			else
				overlay_addr_s <= X"3FFF";
			end if;

		end if;
	end process;



	process (overlay_X_s, overlay_Y_i, overlay_en_i, overlay_data_i, overlay_R_s, overlay_G_s, overlay_B_s)
	begin
	
		overlay_R_s <= "111";
		overlay_G_s <= "000";
		overlay_B_s <= "11";
		pixel_en_s <= '0';
		
		if overlay_en_i = '1' then
	
				if (overlay_X_s <= 256 and overlay_Y_i < 192) then
					
						overlay_R_s <= overlay_data_i(7 downto 5);
						overlay_G_s <= overlay_data_i(4 downto 2);
						overlay_B_s <= overlay_data_i(1 downto 0);
						
						if (overlay_R_s = "111" and overlay_G_s = "000" and overlay_B_s = "11") then
							pixel_en_s <= '0';
						else
							pixel_en_s <= '1';
						end if;
					
				end if;
			
		end if;
	end process;


	
	--pixel_en_s <= '0' when  overlay_en_i = '0' or (overlay_R_s = "111" and overlay_G_s = "000" and overlay_B_s = "11") else '1';


	-- external
	overlay_addr_o <= overlay_addr_s;
	overlay_R_o <= overlay_R_s;
	overlay_G_o <= overlay_G_s;
	overlay_B_o <= overlay_B_s;
	pixel_en_o 	<= pixel_en_s;
	

end architecture;