--
-- TBBlue / ZX Spectrum Next project
--
-- Based on ula_radas.v - Copyright (c) 2015 - ZX-Uno Team (www.zxuno.com)
--
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

entity zxula is
	generic (
		DEBUG		: boolean := false
	);
	port (
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
		-- Raster int
		rint_ctrl_i		: in  std_logic_vector(1 downto 0);
		rint_line_i		: in  std_logic_vector(8 downto 0);
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
		i_sw				: in  std_logic							:= '0';
		-- Horizontal and vertical counters
		hcount_o			: out unsigned(8 downto 0);
		vcount_o			: out unsigned(8 downto 0);
		pixel_clock_o 	: out std_logic
	);
end entity;

architecture behave of zxula is

	signal clock_turbo_s				: std_logic;
	signal cpu_clk_s					: std_logic;
	signal clk7_s						: std_logic								:= '0';
--	signal clkhalf14_s				: std_logic								:= '0';
	signal hc_s 						: unsigned(8 downto 0)				:= (others => '0');
	signal vc_s 						: unsigned(8 downto 0)				:= (others => '0');
	signal hblank_n_s 				: std_logic								:= '1';
	signal hsync_n_s 					: std_logic								:= '1';
	signal vblank_n_s 				: std_logic								:= '1';
	signal vsync_n_s 					: std_logic								:= '1';
	signal vint_n_s					: std_logic								:= '1';

	signal bitmap_addr_s				: std_logic;
	signal bitmap_data_load_s		: std_logic;
	signal attr_addr_s				: std_logic;
	signal attr_data_load_s			: std_logic;
	signal serializer_load_s		: std_logic;
	signal attr_output_load_s		: std_logic;
	signal ca_load_s					: std_logic;
	signal ca_s							: std_logic_vector(4 downto 0);
	signal video_en_s					: std_logic;
	signal hcd_s 						: unsigned(8 downto 0);

	signal bitmap_data_r				: std_logic_vector(7 downto 0);
	signal bitmap_serial_r			: std_logic_vector(7 downto 0);
	signal serial_output_s			: std_logic;
	signal bitmap_serial_hr_r		: std_logic_vector(15 downto 0);
	signal serial_hr_output_s		: std_logic;
	signal attr_data_r				: std_logic_vector(7 downto 0)	:= (others => '1');
	signal border_data_s				: std_logic_vector(2 downto 0)	:= "010";
	signal input_to_attr_out_s		: std_logic_vector(7 downto 0);
	-- Timex
	signal timex_reg_r				: std_logic_vector(7 downto 0);
	 alias timex_pg_a					: std_logic is timex_reg_r(0);
	 alias timex_hcl_a				: std_logic is timex_reg_r(1);
	 alias timex_hr_a					: std_logic is timex_reg_r(2);
	 alias timex_hrink_a				: std_logic_vector(2 downto 0) is timex_reg_r(5 downto 3);

	-- 
	signal pixel_s						: std_logic;
	signal pixel_with_flash_s		: std_logic;
	signal attr_output_r				: std_logic_vector(7 downto 0);
	 alias attr_flash_a				: std_logic                    is attr_output_r(7);
	 alias attr_bright_a				: std_logic                    is attr_output_r(6);
	 alias std_paper_color_a		: std_logic_vector(2 downto 0) is attr_output_r(5 downto 3);
	 alias std_ink_color_a			: std_logic_vector(2 downto 0) is attr_output_r(2 downto 0);
	-- Flash
	signal flash_cnt_s				: unsigned(4 downto 0)				:= (others => '0');
	 alias flash_ff_a					: std_logic is flash_cnt_s(4);
	-- Enhanced ULA
	signal enh_ula_addr_portsel_s	: std_logic;
	signal enh_ula_data_portsel_s	: std_logic;
	signal cpu_write_palette_s		: std_logic;
	signal enh_ula_addr_reg_s		: std_logic_vector(6 downto 0);
	signal enh_ula_soft_en_s		: std_logic;
	signal enh_ula_config_s			: std_logic;
	signal enh_ula_palette_dout_s	: std_logic_vector(7 downto 0);
	signal enh_ula_paper_s			: std_logic_vector(7 downto 0);
	signal enh_ula_paper_out_s		: std_logic_vector(7 downto 0);
	signal enh_ula_ink_s				: std_logic_vector(7 downto 0);
	signal enh_ula_ink_out_s		: std_logic_vector(7 downto 0);
	signal enh_ula_pixel_s			: std_logic_vector(7 downto 0);
	signal enh_ula_palette_addr_s	: std_logic_vector(5 downto 0);
	signal enh_ula_pal_cpu_dout_s	: std_logic_vector(7 downto 0);
	
	-- Radastan Mode
	signal zxuno_fc3b_en_s			: std_logic;
	signal zxuno_fd3b_en_s			: std_logic;
	signal zxuno_regaddr_q			: std_logic_vector( 7 downto 0);
	signal radas_en_s					: std_logic;

	-- Contention
	signal iorequla_s					: std_logic;
	signal iorequlaplus_s			: std_logic;
	signal ioreqall_n_s				: std_logic;
	signal mem_contend_s				: std_logic;
	signal maycontend_n_s			: std_logic;
	signal causecontention_n_s		: std_logic;
	signal cancelcontention_s		: std_logic;
	signal cpucontention_s			: std_logic;

	signal border_n_s					: std_logic;
	signal port255_en_s				: std_logic;
	signal port255_dis_en_s			: std_logic;
	signal ear_s						: std_logic;
	signal speaker_s					: std_logic;
	signal mem_cs_s					: std_logic;
	signal floatingbus_s				: std_logic_vector( 7 downto 0);

	constant BHPIXEL_C				: integer 			:=  0;
	constant EHPIXEL_C				: integer 			:=  255;
	constant BVPIXEL_C				: integer 			:=  0;
	constant EVPIXEL_C				: integer 			:=  191;

begin

	-- Timing generator
	timing: entity work.zxula_timing
	port map (
		clock_i			=> clk7_s,
		mode_i			=> mode_i,
		vf50_60_i		=> vf50_60_i,
		hcount_o			=> hc_s,
		vcount_o			=> vc_s,
		hsync_n_o		=> hsync_n_s,
		vsync_n_o		=> vsync_n_s,
		hblank_n_o		=> hblank_n_s,
		vblank_n_o		=> vblank_n_s,
		int_n_o			=> vint_n_s,
		rint_ctrl_i		=> rint_ctrl_i,
		rint_line_i		=> rint_line_i
	);

	-- RAM palette
	rp: entity work.dpram2
	generic map (
		addr_width_g	=> 6,
		data_width_g	=> 8
	)
	port map (
		clk_a_i		=> clock_28_i,
		we_i			=> cpu_write_palette_s,
		addr_a_i		=> enh_ula_addr_reg_s(5 downto 0),
		data_a_i		=> cpu_data_i,
		data_a_o		=> enh_ula_pal_cpu_dout_s,
		clk_b_i		=> clock_28_i,
		addr_b_i		=> enh_ula_palette_addr_s,
		data_b_o		=> enh_ula_palette_dout_s
	);

	-- Pixel clock
	process (clock_i)
	begin
		if rising_edge(clock_i) then
			clk7_s		<= not clk7_s;
--			clkhalf14_s	<= not clkhalf14_s;
		end if;
	end process;
	
	pixel_clock_o <= clk7_s;

	-- bitmap_data_r register
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if bitmap_data_load_s = '1' then
				bitmap_data_r <= mem_data_i;
			end if;
		end if;
	end process;

	-- attr_data_r register
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if attr_data_load_s = '1' then
				attr_data_r <= mem_data_i;
			end if;
		end if;
	end process;

	-- bitmap_serial_r register
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if serializer_load_s = '1' then
				bitmap_serial_r <= bitmap_data_r;
			else
				bitmap_serial_r <= bitmap_serial_r(6 downto 0) & '0';
			end if;
		end if;
	end process;

	serial_output_s <= bitmap_serial_r(7);

	-- bitmap_serial_hr_r register
	process (clock_i)
	begin
		if rising_edge(clock_i) then
			if serializer_load_s = '1' and clk7_s = '1' then
				bitmap_serial_hr_r <= bitmap_data_r & attr_data_r;
			else
				bitmap_serial_hr_r <= bitmap_serial_hr_r(14 downto 0) & '0';
			end if;
		end if;
	end process;

	serial_hr_output_s <= bitmap_serial_hr_r(15);

	input_to_attr_out_s <=
				"01" & not timex_hrink_a & timex_hrink_a	when timex_hr_a = '1'	else
				attr_data_r											when video_en_s = '1'	else
				'0' & border_data_s & '0' & border_data_s	when radas_en_s = '1'	else
				"00" & border_data_s & "000";

	-- AttrOutput register
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if attr_output_load_s = '1' then
				attr_output_r <= input_to_attr_out_s;
			end if;
		end if;
	end process;

	-- Combinational logic to generate pixel bit
	pixel_s <=	serial_hr_output_s	when timex_hr_a = '1'	else
					serial_output_s;

	-- Flash counter
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if hc_s = 0 and vc_s = 0 then
				flash_cnt_s	<= flash_cnt_s + 1;
			end if;
		end if;
	end process;

	-- Pixel generation
	pixel_with_flash_s <= pixel_s xor (attr_flash_a and flash_ff_a);

	-- RGB generation
	process (hblank_n_s, vblank_n_s, attr_bright_a, pixel_with_flash_s)
	begin
		if hblank_n_s = '1' and vblank_n_s = '1' then
			rgb_i_o	<= attr_bright_a;
			if pixel_with_flash_s = '1' then
				rgb_g_o	<= std_ink_color_a(2);
				rgb_r_o	<= std_ink_color_a(1);
				rgb_b_o	<= std_ink_color_a(0);
			else
				rgb_g_o	<= std_paper_color_a(2);
				rgb_r_o	<= std_paper_color_a(1);
				rgb_b_o	<= std_paper_color_a(0);
			end if;
		else
			rgb_i_o	<= '0';
			rgb_r_o	<= '0';
			rgb_g_o	<= '0';
			rgb_b_o	<= '0';
		end if;
	end process;

	rgb_hsync_o		<= hsync_n_s;
	rgb_vsync_o		<= vsync_n_s;
	rgb_hblank_o	<= hblank_n_s;
	rgb_vblank_o	<= vblank_n_s;
	cpu_int_n_o		<= vint_n_s;

	-- Enhanced ULA
	rgb_enh_en_o <= enh_ula_config_s;

	enh_ula_addr_portsel_s	<= '1' when enh_ula_en_i = '1' and cpu_iorq_n_i = '0' and cpu_addr_i = X"BF3B"		else '0';						-- port 0xBF3B

	enh_ula_data_portsel_s	<= '1' when enh_ula_en_i = '1' and cpu_iorq_n_i = '0' and cpu_addr_i = X"FF3B"		else '0';						-- port 0xFF3B

	cpu_write_palette_s		<= '1' when enh_ula_data_portsel_s = '1' and cpu_wr_n_i = '0' and
													enh_ula_addr_reg_s(6) = '0'									else '0';	-- =1 if CPU wants to write a palette entry to RAM

	-- Enhanced ULA: palette management
	process (reset_i, clk7_s)
	begin
		if reset_i = '1' then 
			enh_ula_soft_en_s	<= '0';
		elsif rising_edge(clk7_s) then
			if enh_ula_addr_portsel_s = '1' and cpu_wr_n_i = '0' then
				enh_ula_addr_reg_s	<= cpu_data_i(6 downto 0);
			elsif enh_ula_data_portsel_s = '1' and cpu_wr_n_i = '0' and enh_ula_addr_reg_s(6) = '1' then
				enh_ula_soft_en_s	<= cpu_data_i(0);
			end if;
		end if;
	end process;

	enh_ula_config_s	<= enh_ula_soft_en_s or radas_en_s;

	-- Radastan (ZX-Uno) I/O ports
	zxuno_fc3b_en_s	<= '1' when cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_addr_i = X"FC3B"		else '0';
	zxuno_fd3b_en_s	<= '1' when cpu_iorq_n_i = '0' and                      cpu_addr_i = X"FD3B"		else '0';

	-- Register address
	process (reset_i, clk7_s)
	begin
		if reset_i = '1' then
			zxuno_regaddr_q <= X"00";
		elsif rising_edge(clk7_s) then
			if zxuno_fc3b_en_s = '1' and cpu_wr_n_i = '0' then
				zxuno_regaddr_q <= cpu_data_i;
			end if;
		end if;
	end process;

g1: if not DEBUG generate
	-- Register data
	process (reset_i, clk7_s)
	begin
		if reset_i = '1' then
			radas_en_s <= '0';
		elsif rising_edge(clk7_s) then
			if zxuno_fd3b_en_s = '1' and cpu_wr_n_i = '0' and zxuno_regaddr_q = X"40" then
				radas_en_s <= cpu_data_i(1) and cpu_data_i(0);
			end if;
		end if;
	end process;
end generate;

g2: if DEBUG generate
	radas_en_s <= i_sw;
end generate;


	-- Enhanced ULA: palette RAM address and control bus multiplexing
	process (hc_s, input_to_attr_out_s, radas_en_s, clk7_s)
	begin
		if radas_en_s = '0' then
			if (hc_s(3 downto 0) = X"C" or hc_s(3 downto 0) = X"0") and clk7_s = '1' then		--  => present address of paper to palette RAM
				enh_ula_palette_addr_s	<= input_to_attr_out_s(7 downto 6) & '1' & input_to_attr_out_s(5 downto 3);
			else
				enh_ula_palette_addr_s	<= input_to_attr_out_s(7 downto 6) & '0' & input_to_attr_out_s(2 downto 0);
			end if;
		else
			-- Radastan mode enabled
			if    hc_s(1 downto 0) = "10" then
				enh_ula_palette_addr_s	<= "00" & input_to_attr_out_s(7 downto 4);
			else
				enh_ula_palette_addr_s	<= "00" & input_to_attr_out_s(3 downto 0);                              
			end if;
		end if;
	end process;

   -- Enhanced ULA: palette reading and attribute generation
	-- First buffers for paper and ink
	process(clock_i)
	begin
		if falling_edge(clock_i) then
			if radas_en_s = '0' then
				if    (hc_s(3 downto 0) = X"C" or hc_s(3 downto 0) = X"0") and clk7_s = '1' then	-- this happens 1/2 clk7 after address is settled
					enh_ula_paper_s	<= enh_ula_palette_dout_s;
				else
					enh_ula_ink_s		<= enh_ula_palette_dout_s;
				end if;
			else
				-- Radastan mode enabled
				if    hc_s(1 downto 0) = "10" and clk7_s = '0' then		-- this happens 1/2 clk7 after address is settled TODO: acertar esse valor
					enh_ula_paper_s	<= enh_ula_palette_dout_s;
				else
					enh_ula_ink_s		<= enh_ula_palette_dout_s;
				end if;
			end if;
		end if;
	end process;

	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if attr_output_load_s = '1' then
				enh_ula_paper_out_s	<= enh_ula_paper_s;
				enh_ula_ink_out_s		<= enh_ula_ink_s;
			end if;
		end if;
	end process;
	
	-- Enhanced ULA RGB out enh_ula_pixel_s
	process (radas_en_s, pixel_s, hc_s, hblank_n_s, vblank_n_s,
				enh_ula_paper_out_s, enh_ula_ink_out_s, clk7_s)
	begin
		rgb_enh_o	<= (others => '0');
		if hblank_n_s = '1' and vblank_n_s = '1' then
			if radas_en_s = '0' then
				if pixel_s = '0' then
					rgb_enh_o	<= enh_ula_paper_out_s;
				else
					rgb_enh_o	<= enh_ula_ink_out_s;
				end if;
			else
				-- Radastan mode enabled
				if hc_s(1) = '0' then
					rgb_enh_o	<= enh_ula_paper_out_s;
				else
					rgb_enh_o	<= enh_ula_ink_out_s;
				end if;
			end if;
		end if;
	end process;

	-- Column address register (CA)
	process (clk7_s)
	begin
		if rising_edge(clk7_s) then
			if ca_load_s = '1' then
				ca_s <= std_logic_vector(hc_s(7 downto 3));
			end if;
		end if;
	end process;

	-- VRAM address generation

	hcd_s	<= hc_s - 8;	-- hc delayed 8 ticks

	-- Address and control line multiplexor ULA/CPU
	process (radas_en_s, bitmap_addr_s, attr_addr_s, cpu_addr_i, hc_s, vc_s, ca_s, vram_shadow_i, hcd_s,
				timex_pg_a, timex_hcl_a)
		variable vc_std_v : std_logic_vector(8 downto 0);
	begin
		vc_std_v := std_logic_vector(vc_s);

		if radas_en_s = '0' then
			if bitmap_addr_s = '1' then
				mem_addr_o <= vram_shadow_i & '1' & timex_pg_a & vc_std_v(7 downto 6) & vc_std_v(2 downto 0) & vc_std_v(5 downto 3) & ca_s;
				mem_cs_s		<= '1';
				mem_oe_o		<= not hc_s(0);
			elsif attr_addr_s = '1' then
				if timex_hcl_a = '1' then																																		-- (cycles 9 and 13 load attr byte)
					mem_addr_o	<= vram_shadow_i & "11" & vc_std_v(7 downto 6) & vc_std_v(2 downto 0) & vc_std_v(5 downto 3) & ca_s;
				else
					mem_addr_o	<= vram_shadow_i & '1' & timex_pg_a & "110" & vc_std_v(7 downto 3) & ca_s;
				end if;
				mem_cs_s		<= '1';
				mem_oe_o		<= not hc_s(0);
			else
				mem_addr_o	<= (others => '0');
				mem_cs_s		<= '0';
				mem_oe_o		<= '0';
			end if;
		else
			-- Radastan mode enabled
			mem_addr_o <= vram_shadow_i & '1' & timex_pg_a & vc_std_v(7 downto 1) & (std_logic_vector(hcd_s(7 downto 2)));
			if hc_s(1) = '0' then
				mem_cs_s		<= '1';
				mem_oe_o		<= not hc_s(0);
			else
				mem_cs_s		<= '0';
				mem_oe_o		<= '0';
			end if;
		end if;
	end process;

	mem_cs_o <= mem_cs_s;

	process (radas_en_s, hc_s, vc_s)
	begin
		bitmap_data_load_s	<= '0';
		attr_data_load_s		<= '0';
		serializer_load_s		<= '0';
		video_en_s				<= '0';
		attr_output_load_s	<= '0';
		bitmap_addr_s			<= '0';
		attr_addr_s				<= '0';
		ca_load_s				<= '0';

		if radas_en_s = '0' then
			-- 
			if hc_s(2 downto 0) = "100" then				-- 4
				attr_output_load_s <= '1';
			end if;
			-- 
			if hc_s(2 downto 0) = "011" then				-- 3
				ca_load_s <= '1';
			end if;
			if hc_s >= (BHPIXEL_C+8) and hc_s <= (EHPIXEL_C+8) and vc_s >= BVPIXEL_C and vc_s <= EVPIXEL_C then -- VidEN_n is low here: paper area
				video_en_s <= '1';
				if hc_s(2 downto 0) = "100" then			-- 4
					serializer_load_s <= '1';							-- updated every 8 pixel clocks, if we are in paper area
				end if;
			end if;
			if hc_s >= BHPIXEL_C and hc_s <= EHPIXEL_C and vc_s >= BVPIXEL_C and vc_s <= EVPIXEL_C then
				if hc_s(3 downto 0) = X"8" or hc_s(3 downto 0) = X"C" then		-- 8 and 12
					bitmap_addr_s <= '1';
				end if;
				if hc_s(3 downto 0) = X"9" or hc_s(3 downto 0) = X"D" then		-- 9 and 13
					bitmap_addr_s <= '1';
					bitmap_data_load_s <= '1';
				end if;
				if hc_s(3 downto 0) = X"A" or hc_s(3 downto 0) = X"E" then		-- 10 and 14
					attr_addr_s <= '1';
				end if;
				if hc_s(3 downto 0) = X"B" or hc_s(3 downto 0) = X"F" then		-- 11 and 15
					attr_addr_s <= '1';
					attr_data_load_s <= '1';
				end if;
			end if;
		else
			-- Radastan mode enabled
			if hc_s(1 downto 0) = "11" then
				attr_output_load_s <= '1';
			end if;
			if hc_s >= (BHPIXEL_C+8) and hc_s <= (EHPIXEL_C+8) and vc_s >= BVPIXEL_C and vc_s <= EVPIXEL_C then -- VidEN_n is low here: paper area
				video_en_s <= '1';
				if hc_s(1 downto 0) = "01" then
					attr_data_load_s <= '1';
				end if;
			end if;
		end if;
	end process;

	--
	port255_en_s		<= '1' when cpu_iorq_n_i = '0' and cpu_addr_i(7 downto 0) = X"FF" and timex_en_i = '1'	else '0';		--
	port255_dis_en_s	<= '1' when cpu_iorq_n_i = '0' and cpu_addr_i(7 downto 0) = X"FF" and timex_en_i = '0'	else '0';		--

	-- Write in ports
	process (reset_i, clk7_s)
	begin
		if reset_i = '1' then
			timex_reg_r		<= (others => '0');
			speaker_s		<= '0';
			mic_o				<= '0';
		elsif falling_edge(clk7_s) then
			if    port255_en_s = '1' and cpu_wr_n_i = '0' then					-- port 255
				timex_reg_r <= cpu_data_i;
			elsif iocs_i = '1' and cpu_wr_n_i = '0' then							-- port 254
				speaker_s		<= cpu_data_i(4);
				mic_o				<= cpu_data_i(3);
				border_data_s	<= cpu_data_i(2 downto 0);
			end if;
		end if;
	end process;

	ear_s <= ear_i xor speaker_s;	-- Issue 3
	speaker_o <= speaker_s;

	-- Simulates floating-bus on I/O port 0xFF
	--floatingbus_s <= mem_data_i when bitmap_addr_s = '1' or attr_addr_s = '1'	else (others => '1');
	floatingbus_s <= mem_data_i when mem_cs_s = '1'	else (others => '1');

	-- ULA-CPU interface
	cpu_data_o <=
					'1' & ear_s & '1' & kb_columns_i		when iocs_i = '1' and cpu_rd_n_i = '0'									else	-- CPU reads keyboard and EAR state
					timex_reg_r									when port255_en_s = '1' and cpu_rd_n_i = '0'							else	-- Timex config port.
					floatingbus_s								when port255_dis_en_s = '1' and cpu_rd_n_i = '0'					else	-- Floating Bus in FF port
					'0' & enh_ula_addr_reg_s				when enh_ula_addr_portsel_s = '1' and cpu_rd_n_i = '0'			else	-- enh_ula addr register
					"0000000" & enh_ula_soft_en_s			when enh_ula_data_portsel_s = '1' and cpu_rd_n_i = '0' and enh_ula_addr_reg_s(6) = '1'	else
					enh_ula_pal_cpu_dout_s					when enh_ula_data_portsel_s = '1' and cpu_rd_n_i = '0' and enh_ula_addr_reg_s(6) = '0'	else
					cpu_data_i									when bitmap_addr_s = '1' or attr_addr_s = '1'						else
					(others => '1');

	has_data_o	<= '1' when iocs_i = '1'         		  and cpu_rd_n_i = '0'	else
						'1' when port255_en_s = '1'           and cpu_rd_n_i = '0'	else
						'1' when port255_dis_en_s = '1'       and cpu_rd_n_i = '0'	else
						'1' when enh_ula_addr_portsel_s = '1' and cpu_rd_n_i = '0'	else
						'1' when enh_ula_data_portsel_s = '1' and cpu_rd_n_i = '0'	else
						'0';

	-- 
	process (hc_s, vc_s)
	begin
		border_n_s				<= '0';
		if hc_s >= BHPIXEL_C and hc_s <= EHPIXEL_C and vc_s >= BVPIXEL_C and vc_s <= EVPIXEL_C then
			border_n_s <= '1';
		end if;
	end process;

	-- CPU contention
	iorequla_s		<= not cpu_iorq_n_i and not cpu_addr_i(0);
	iorequlaplus_s	<= enh_ula_addr_portsel_s or enh_ula_data_portsel_s;
	ioreqall_n_s	<= not (iorequla_s or iorequlaplus_s);	-- ioreqbank
	mem_contend_s	<= '1' when cpu_addr_i(15 downto 14) = "01"								else
							'1' when cpu_addr_i(15 downto 14) = "11" and ram_bank_i = '1'	else
							'0';

	process (clk7_s)
	begin
		if falling_edge(clk7_s) then
			if hc_s(3 downto 0) > 3 and border_n_s = '1' then
				maycontend_n_s <= '0';
			else
				maycontend_n_s	<= '1';
			end if;
		end if;
	end process;

	causecontention_n_s <= '0' when (ioreqall_n_s = '0' or mem_contend_s = '1') and radas_en_s = '0'		else '1';

	-- Gerar clock para a CPU
	clock_turbo_s	<= clock_i	when turbo_en_i = '1' else clk7_s;

	process (cpu_clk_s)
	begin
		if rising_edge(cpu_clk_s) then
			if cpu_mreq_n_i = '0' or ioreqall_n_s = '0' then
				cancelcontention_s <= '1';
			else
				cancelcontention_s <= '0';
			end if;
		end if;
	end process;

	cpucontention_s <= not (maycontend_n_s or causecontention_n_s or cancelcontention_s);

	process (clock_turbo_s)
	begin
		if rising_edge(clock_turbo_s) then
			if cpu_clk_s = '1' and cpucontention_s = '0' then		-- if there's no contention, the clock can go low
				cpu_clk_s <= '0';
			else
				cpu_clk_s <= '1';
			end if;
		end if;
	end process;

	cpu_clock_o 	<= cpu_clk_s;
	
	--external counters to overlay
	hcount_o <= hc_s;
	vcount_o <= vc_s;

end architecture;