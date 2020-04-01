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
-- For ZX Spectrum 48K:
--
-- Horizontal timing (hcounter):
--  0-255   = video
--  256-319 = border (64 pixels)
--  320-415 = hblank (96 pixels)
--  416-447 = border (32 pixels)
--
-- Vertical Timings
--  Phase__________50_Hz_version__________60_Hz_Version_______
--  Picture        192 lines (0..191)     192 lines (0..191)
--  Lower Border    56 lines (192..247)    32 lines (192..223)
--  Vsync            8 lines (248..255)     8 lines (224..231)
--  Upper Border    56 lines (256..311)    32 lines (232..263)
--  Total          312 lines (0..311)     264 lines (0..263)
--
-- For ZX Spectrum 128K
--
-- Horizontal timing (hcounter):
--  0-255   = video
--  256-319 = border (64 pixels)
--  320-415 = hblank (96 pixels)
--  416-455 = border (32 pixels)
--
-- Vertical Timings
--  Phase__________50_Hz_version__________60_Hz_Version_______
--  Picture        192 lines (0..191)     192 lines (0..191)
--  Lower Border    56 lines (192..247)    32 lines (192..223)
--  Vsync            8 lines (248..255)     8 lines (224..231)
--  Upper Border    56 lines (256..311)    32 lines (232..263)
--  Total          311 lines (0..310)     264 lines (0..263)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zxula_timing is
	port (
		clock_i			: in  std_logic;
		mode_i			: in  std_logic_vector(1 downto 0);
		vf50_60_i		: in  std_logic;
		hcount_o			: out unsigned(8 downto 0);
		vcount_o			: out unsigned(8 downto 0);
		hsync_n_o		: out std_logic;
		vsync_n_o		: out std_logic;
		hblank_n_o		: out std_logic;
		vblank_n_o		: out std_logic;
		int_n_o			: out std_logic;
		-- Sprites
		spt_hcount_o	: out unsigned(8 downto 0);
		spt_vcount_o	: out unsigned(8 downto 0)
	);
end entity;

architecture Behavior of zxula_timing is

	signal hc_s 						: unsigned(8 downto 0)				:= (others => '0');
	signal vc_s 						: unsigned(8 downto 0)				:= (others => '0');
	-- Counter values
	signal c_max_hc_s					: unsigned(8 downto 0);
	signal c_max_vc_s					: unsigned(8 downto 0);
	signal c_vblank_min_s			: unsigned(8 downto 0);
	signal c_vblank_max_s			: unsigned(8 downto 0);
	signal c_hblank_min_s			: unsigned(8 downto 0);
	signal c_hblank_max_s			: unsigned(8 downto 0);
	signal c_vsync_min_s				: unsigned(8 downto 0);
	signal c_vsync_max_s				: unsigned(8 downto 0);
	signal c_hsync_min_s				: unsigned(8 downto 0);
	signal c_hsync_max_s				: unsigned(8 downto 0);
	signal c_int_minh_s				: unsigned(8 downto 0);
	signal c_int_maxh_s				: unsigned(8 downto 0);
	signal c_int_minv_s				: unsigned(8 downto 0);
	signal c_int_maxv_s				: unsigned(8 downto 0);
	-- sprites
	signal spt_hc_s 					: unsigned(8 downto 0)				:= (others => '0');
	signal spt_vc_s 					: unsigned(8 downto 0)				:= (others => '0');

begin

	--
	process (mode_i, vf50_60_i)
	begin
		if mode_i = "00" or mode_i = "01" then									-- ZX 48K
			c_hblank_min_s	<= to_unsigned(320, 9);
			c_hsync_min_s	<= to_unsigned(344, 9);
			c_hsync_max_s	<= to_unsigned(375, 9);
			c_hblank_max_s	<= to_unsigned(415, 9);
			c_int_minh_s	<= to_unsigned(2, 9);								-- 2
			c_int_maxh_s	<= to_unsigned(65, 9);								-- 65
			c_max_hc_s		<= to_unsigned(447, 9);
			if vf50_60_i = '0' then
				c_vblank_min_s	<= to_unsigned(248, 9);
				c_vblank_max_s	<= to_unsigned(255, 9);
				c_vsync_min_s	<= to_unsigned(248, 9);
				c_vsync_max_s	<= to_unsigned(251, 9);
				c_int_minv_s	<= to_unsigned(248, 9);							-- 248
				c_int_maxv_s	<= to_unsigned(248, 9);							-- 248
				c_max_vc_s		<= to_unsigned(311, 9);
			else
				c_vblank_min_s	<= to_unsigned(224, 9);
				c_vsync_min_s	<= to_unsigned(224, 9);
				c_vsync_max_s	<= to_unsigned(227, 9);
				c_vblank_max_s	<= to_unsigned(231, 9);
				c_int_minv_s	<= to_unsigned(224, 9);							-- 224
				c_int_maxv_s	<= to_unsigned(224, 9);							-- 224
				c_max_vc_s		<= to_unsigned(261, 9);
			end if;
		else																				-- ZX 128K / +3
			c_hblank_min_s	<= to_unsigned(320, 9);
			c_hsync_min_s	<= to_unsigned(344, 9);
			c_hsync_max_s	<= to_unsigned(375, 9);
			c_hblank_max_s	<= to_unsigned(415, 9);
			c_int_minh_s	<= to_unsigned(4, 9);								-- 4
			c_int_maxh_s	<= to_unsigned(67, 9);								-- 67
			c_max_hc_s		<= to_unsigned(455, 9);
			if vf50_60_i = '0' then
				c_vblank_min_s	<= to_unsigned(248, 9);
				c_vsync_min_s	<= to_unsigned(248, 9);
				c_vsync_max_s	<= to_unsigned(251, 9);
				c_vblank_max_s	<= to_unsigned(255, 9);
				c_int_minv_s	<= to_unsigned(248, 9);							-- 248
				c_int_maxv_s	<= to_unsigned(248, 9);							-- 248
				c_max_vc_s		<= to_unsigned(310, 9);
			else
				c_vblank_min_s	<= to_unsigned(224, 9);
				c_vsync_min_s	<= to_unsigned(224, 9);
				c_vsync_max_s	<= to_unsigned(227, 9);
				c_vblank_max_s	<= to_unsigned(231, 9);
				c_int_minv_s	<= to_unsigned(224, 9);							-- 224
				c_int_maxv_s	<= to_unsigned(224, 9);							-- 224
				c_max_vc_s		<= to_unsigned(260, 9);
			end if;		
		end if;
	end process;

	-- Horizontal counter
	process (clock_i)
	begin
		if rising_edge(clock_i) then
			if hc_s = c_max_hc_s then
				hc_s <= (others => '0');
			else
				hc_s <= hc_s + 1;
			end if;
		end if;
	end process;

	-- Vertical counter
	process (clock_i)
	begin
		if rising_edge(clock_i) then
			if hc_s = c_max_hc_s then
				if vc_s = c_max_vc_s then
					vc_s <= (others => '0');
				else
					vc_s <= vc_s + 1;
				end if;
			end if;
		end if;
	end process;

	hcount_o <= hc_s;
	vcount_o <= vc_s;

	-- Signals generation
	process (hc_s, vc_s, c_hblank_min_s, c_hblank_max_s, c_vblank_min_s, c_vblank_max_s,
				c_hsync_min_s, c_hsync_max_s, c_vsync_min_s, c_vsync_max_s)
	begin
		hblank_n_o	<= '1';
		vblank_n_o	<= '1';
		hsync_n_o	<= '1';
		vsync_n_o	<= '1';

		-- HBlank
		if hc_s >= c_hblank_min_s and hc_s <= c_hblank_max_s then
			hblank_n_o <= '0';
		end if;
		-- VBlank
		if vc_s >= c_vblank_min_s and vc_s <= c_vblank_max_s then
			vblank_n_o <= '0';
		end if;
		-- HSync
		if hc_s >= c_hsync_min_s and hc_s <= c_hsync_max_s then
			hsync_n_o <= '0';
		end if;
		-- VSync
		if vc_s >= c_vsync_min_s and vc_s <= c_vsync_max_s then
			vsync_n_o <= '0';
		end if;

	end process;

	-- INT generation
	process (hc_s, vc_s, c_int_minv_s, c_int_minh_s, c_int_maxv_s, c_int_maxh_s)
	begin
		int_n_o <= '1';
		if vc_s >= c_int_minv_s and vc_s <= c_int_maxv_s then
			if hc_s >= c_int_minh_s and hc_s <= c_int_maxh_s then
				int_n_o <= '0';
			end if;
		end if;
	end process;

	-- Sprite counters
	process (clock_i)
	begin
		if rising_edge(clock_i) then
			if hc_s = (c_max_hc_s - 20) then
				spt_hc_s <= (others => '0');
				if vc_s = (c_max_vc_s - 33) then
					spt_vc_s <= (others => '0');
				else
					spt_vc_s <= spt_vc_s + 1;
				end if;
			else
				spt_hc_s <= spt_hc_s + 1;
			end if;
		end if;
	end process;

	spt_hcount_o <= spt_hc_s;
	spt_vcount_o <= spt_vc_s;

end architecture;

