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
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture zxula_arch of tb is

	-- test target
	component zxula
	generic (
		DEBUG : boolean := false
	);
	port(
		clock_28_i		: in  std_logic;
		clock_i			: in  std_logic;
		reset_i			: in  std_logic;
		mode_i			: in  std_logic_vector(1 downto 0);
		turbo_en_i		: in  std_logic;
		enh_ula_en_i	: in  std_logic;
		timex_en_i		: in  std_logic;
		vf50_60_i		: in  std_logic;
		iocs_i			: in  std_logic;
		cpu_addr_i		: in  std_logic_vector(15 downto 0);
		cpu_data_i		: in  std_logic_vector( 7 downto 0);
		cpu_data_o		: out std_logic_vector( 7 downto 0);
		has_data_o		: out std_logic;
		cpu_mreq_n_i	: in  std_logic;
		cpu_iorq_n_i	: in  std_logic;
		cpu_rd_n_i		: in  std_logic;
		cpu_wr_n_i		: in  std_logic;
		cpu_clock_o		: out std_logic;
		cpu_int_n_o		: out std_logic;
		-- vram
		vram_shadow_i	: in  std_logic;
		ram_bank_i		: in  std_logic;
		mem_addr_o		: out std_logic_vector(15 downto 0);
		mem_data_i		: in  std_logic_vector( 7 downto 0);
		mem_cs_o			: out std_logic;
		mem_oe_o			: out std_logic;
		-- I/O
		ear_i				: in  std_logic;
		speaker_o		: out std_logic;
		mic_o				: out std_logic;
		kb_columns_i	: in  std_logic_vector(4 downto 0);
		-- RGB
		rgb_r_o			: out std_logic;
		rgb_g_o			: out std_logic;
		rgb_b_o			: out std_logic;
		rgb_i_o			: out std_logic;
		rgb_enh_o		: out std_logic_vector(7 downto 0);
		rgb_enh_en_o	: out std_logic;
		rgb_hsync_o		: out std_logic;
		rgb_vsync_o		: out std_logic;
		rgb_hblank_o	: out std_logic;
		rgb_vblank_o	: out std_logic;
		i_sw				: in  std_logic;
		--contadores Horizontal e vertical
		hcount_o			: out unsigned(8 downto 0);
		vcount_o			: out unsigned(8 downto 0);
		pixel_clock_o 	: out std_logic
	);
	end component;

	component vram_data is
	port (
		clk		: in    std_logic;
		addr		: in    std_logic_vector(12 downto 0);
		data		: out   std_logic_vector(7 downto 0)
	);
	end component;

	signal clock_28_s		: std_logic;
	signal clock_s			: std_logic;
	signal reset_s			: std_logic;
	signal mode_s			: std_logic_vector(1 downto 0);
	signal turbo_en_s		: std_logic;
	signal enh_ula_en_s		: std_logic;
	signal timex_en_s		: std_logic;
	signal vf50_60_s		: std_logic;
	signal iocs_s			: std_logic;
	signal cpu_addr_s		: std_logic_vector(15 downto 0);
	signal cpu_data_i_s		: std_logic_vector( 7 downto 0);
	signal cpu_data_o_s		: std_logic_vector( 7 downto 0);
	signal has_data_s		: std_logic;
	signal cpu_mreq_n_s		: std_logic;
	signal cpu_iorq_n_s		: std_logic;
	signal cpu_rd_n_s		: std_logic;
	signal cpu_wr_n_s		: std_logic;
	signal cpu_clock_s		: std_logic;
	signal cpu_int_n_s		: std_logic;
	signal vram_shadow_s	: std_logic;
	signal ram_bank_s		: std_logic;
	signal mem_addr_s		: std_logic_vector(15 downto 0);
	signal mem_data_i_s		: std_logic_vector( 7 downto 0);
	signal mem_cs_s			: std_logic;
	signal mem_oe_s			: std_logic;
	signal ear_s			: std_logic;
	signal speaker_s		: std_logic;
	signal mic_s			: std_logic;
	signal kb_columns_s		: std_logic_vector(4 downto 0);
	signal rgb_r_s			: std_logic;
	signal rgb_g_s			: std_logic;
	signal rgb_b_s			: std_logic;
	signal rgb_i_s			: std_logic;
	signal rgb_enh_s		: std_logic_vector(7 downto 0);
	signal rgb_enh_en_s		: std_logic;
	signal rgb_hsync_s		: std_logic;
	signal rgb_vsync_s		: std_logic;
	signal rgb_hblank_s		: std_logic;
	signal rgb_vblank_s		: std_logic;
	signal hcount_s			: unsigned(8 downto 0);
	signal vcount_s			: unsigned(8 downto 0);
	signal pixel_clock_s	: std_logic;
	signal tb_end			: std_logic;

begin

	--  instance
	u_target: zxula
	generic map (
		DEBUG => false
	)
	port map(
		clock_28_i		=> clock_28_s,
		clock_i			=> clock_s,
		reset_i			=> reset_s,
		mode_i			=> mode_s,
		turbo_en_i		=> turbo_en_s,
		enh_ula_en_i	=> enh_ula_en_s,
		timex_en_i		=> timex_en_s,
		vf50_60_i		=> vf50_60_s,
		iocs_i			=> iocs_s,
		cpu_addr_i		=> cpu_addr_s,
		cpu_data_i		=> cpu_data_i_s,
		cpu_data_o		=> cpu_data_o_s,
		has_data_o		=> has_data_s,
		cpu_mreq_n_i	=> cpu_mreq_n_s,
		cpu_iorq_n_i	=> cpu_iorq_n_s,
		cpu_rd_n_i		=> cpu_rd_n_s,
		cpu_wr_n_i		=> cpu_wr_n_s,
		cpu_clock_o		=> cpu_clock_s,
		cpu_int_n_o		=> cpu_int_n_s,
		-- VRAM
		vram_shadow_i	=> vram_shadow_s,
		ram_bank_i		=> ram_bank_s,
		mem_addr_o		=> mem_addr_s,
		mem_data_i		=> mem_data_i_s,
		mem_cs_o		=> mem_cs_s,
		mem_oe_o		=> mem_oe_s,
		-- I/O
		ear_i			=> ear_s,
		speaker_o		=> speaker_s,
		mic_o			=> mic_s,
		kb_columns_i	=> kb_columns_s,
		-- RGB
		rgb_r_o			=> rgb_r_s,
		rgb_g_o			=> rgb_g_s,
		rgb_b_o			=> rgb_b_s,
		rgb_i_o			=> rgb_i_s,
		rgb_enh_o		=> rgb_enh_s,
		rgb_enh_en_o	=> rgb_enh_en_s,
		rgb_hsync_o		=> rgb_hsync_s,
		rgb_vsync_o		=> rgb_vsync_s,
		rgb_hblank_o	=> rgb_hblank_s,
		rgb_vblank_o	=> rgb_vblank_s,
		i_sw			=> '1',
		--contadores Horizontal e vertical
		hcount_o		=> hcount_s,
		vcount_o		=> vcount_s,
		pixel_clock_o 	=> pixel_clock_s
	);

	vram: vram_data
	port map (
		clk		=> clock_s,
		addr		=> mem_addr_s(12 downto 0),
		data		=> mem_data_i_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 35.714285714285714285714285714286 ns;
		clock_s <= '1';
		wait for 35.714285714285714285714285714286 ns;
	end process;

	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_28_s	<= '0';
		wait for 17.857142857142857142857142857143 ns;
		clock_28_s	<= '1';
		wait for 17.857142857142857142857142857143 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		mode_s				<= "00";
		turbo_en_s			<= '0';
		enh_ula_en_s		<= '1';
		timex_en_s			<= '0';
		vf50_60_s			<= '0';
		cpu_addr_s			<= (others => '0');
		cpu_data_i_s		<= (others => '0');
		cpu_mreq_n_s		<= 	'1';
		cpu_iorq_n_s		<= 	'1';
		cpu_rd_n_s			<= 	'1';
		cpu_wr_n_s			<= 	'1';
		vram_shadow_s		<= '0';
		ram_bank_s			<= '0';
		ear_s				<= '0';
		kb_columns_s		<= (others => '0');

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 40 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end zxula_arch;
