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
-- ID 11 = Multicore
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
 
entity multicore_top is
	generic (
		hdmi_output_g		: boolean	:= false
	);
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- Buttons
		btn_n_i				: in    std_logic_vector(4 downto 1);
		btn_oe_n_i			: in    std_logic;
		btn_clr_n_i			: in    std_logic;

		-- SRAM (AS7C34096)
		sram_addr_o			: out   std_logic_vector(18 downto 0)	:= (others => '0');
		sram_data_io		: inout std_logic_vector(7 downto 0)	:= (others => 'Z');
		sram_we_n_o			: out   std_logic								:= '1';
		sram_ce_n_o			: out   std_logic_vector(1 downto 0)	:= (others => '1');
		sram_oe_n_o			: out   std_logic								:= '1';

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
		ps2_mouse_clk_io  : inout std_logic								:= 'Z';
		ps2_mouse_data_io : inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;

		-- Joystick
		joy1_up_i			: in    std_logic;
		joy1_down_i			: in    std_logic;
		joy1_left_i			: in    std_logic;
		joy1_right_i		: in    std_logic;
		joy1_p6_i			: in    std_logic;
		joy1_p7_o			: out   std_logic								:= '1';
		joy1_p9_i			: in    std_logic;
		joy2_up_i			: in    std_logic;
		joy2_down_i			: in    std_logic;
		joy2_left_i			: in    std_logic;
		joy2_right_i		: in    std_logic;
		joy2_p6_i			: in    std_logic;
		joy2_p7_o			: out   std_logic								:= '1';
		joy2_p9_i			: in    std_logic;

		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;
		mic_o					: out   std_logic								:= '0';

		-- VGA
		vga_r_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_g_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_b_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_hsync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';

		-- HDMI
--		hdmi_d_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
--		hdmi_clk_o			: out   std_logic								:= '0';
--		hdmi_cec_o			: out   std_logic								:= '0';

		-- Debug
		leds_n_o				: out   std_logic_vector(7 downto 0)	:= (others => '1')
	);
end entity;

architecture behavior of multicore_top is

	-- ASMI (Altera specific component)
	component cyclone_asmiblock
	port (
		dclkin      : in    std_logic;      -- DCLK
		scein       : in    std_logic;      -- nCSO
		sdoin       : in    std_logic;      -- ASDO
		oe          : in    std_logic;      --(1=disable(Hi-Z))
		data0out    : out   std_logic       -- DATA0
	);
	end component;

	-- Clocks
	signal clock_master_s	: std_logic;
	signal clock_video_s		: std_logic;
	signal clock_hdmi_s		: std_logic;
	signal pll_locked_s		: std_logic;

	-- Resets
	signal poweron_s			: std_logic;
	signal hard_reset_s		: std_logic;
	signal soft_reset_s		: std_logic;
	signal int_soft_reset_s	: std_logic;
	signal reset_s				: std_logic;

	-- Memory buses
	signal vram_addr_s		: std_logic_vector(19 downto 0);
	signal vram_dout_s		: std_logic_vector(7 downto 0);
	signal vram_cs_s			: std_logic;
	signal vram_oe_s			: std_logic;
	signal ram_addr_s			: std_logic_vector(19 downto 0);
	signal ram_din_s			: std_logic_vector(7 downto 0);
	signal ram_dout_s			: std_logic_vector(7 downto 0);
	signal ram_cs_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;
	signal rom_addr_s			: std_logic_vector(13 downto 0);		-- 16K
	signal rom_data_s			: std_logic_vector(7 downto 0);
	
	-- Audio
	signal spk_s				: std_logic;
	signal mic_s				: std_logic;
	signal psg_L_s				: unsigned( 7 downto 0);
	signal psg_R_s				: unsigned( 7 downto 0);
	signal sid_L_s				: unsigned(17 downto 0);
	signal sid_R_s				: unsigned(17 downto 0);
	signal tapein_s			: std_logic_vector(7 downto 0);
	signal pcm_out_L_s		: std_logic_vector(13 downto 0);
	signal pcm_out_R_s		: std_logic_vector(13 downto 0);

	-- Keyboard
	signal kb_rows_s			: std_logic_vector(7 downto 0);
	signal kb_columns_s		: std_logic_vector(4 downto 0);
	signal FKeys_s				: std_logic_vector(12 downto 1);

	-- Mouse
	signal mouse_x_s			: std_logic_vector(7 downto 0);	
	signal mouse_y_s			: std_logic_vector(7 downto 0);			
	signal mouse_bts_s		: std_logic_vector(2 downto 0);		
	signal mouse_wheel_s		: std_logic_vector(3 downto 0);

	-- SPI e EPCS
	signal spi_mosi_s			: std_logic;
	signal spi_sclk_s			: std_logic;
	signal flash_miso_s		: std_logic;
	signal flash_cs_n_s		: std_logic;

	-- Joystick
	signal joy1_s				: std_logic_vector(5 downto 0);
	signal joy2_s           : std_logic_vector(5 downto 0);

	-- Video and scandoubler
	signal rgb_r_s				: std_logic_vector(2 downto 0);
	signal rgb_g_s				: std_logic_vector(2 downto 0);
	signal rgb_b_s				: std_logic_vector(1 downto 0);
	signal rgb_i_s				: std_logic;
	signal rgb_hs_n_s			: std_logic;
	signal rgb_vs_n_s			: std_logic;
	signal ulap_en_s			: std_logic;
	signal rgb_ulap_s			: std_logic_vector(7 downto 0);
	signal rgb_comb_s			: std_logic_vector(7 downto 0);
	signal rgb_out_s			: std_logic_vector(7 downto 0);
	signal scandbl_en_s		: std_logic;
	signal hsync_out_s		: std_logic;
	signal vsync_out_s		: std_logic;
	signal scanlines_s		: std_logic								:= '0';
	signal mach_timing_s		: std_logic_vector(1 downto 0);
	signal ha_value_s	: integer;
	
	signal tdms_r_s			: std_logic_vector( 9 downto 0);
	signal tdms_g_s			: std_logic_vector( 9 downto 0);
	signal tdms_b_s			: std_logic_vector( 9 downto 0);
	signal hdmi_p_s			: std_logic_vector( 3 downto 0);
	signal hdmi_n_s			: std_logic_vector( 3 downto 0);
	
	signal blank_s		: std_logic;

begin

	--------------------------------
	-- PLL
	--  50 MHz input
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		inclk0	=> clock_50_i,
		c0			=> clock_master_s,		-- 28 MHz
		c1 		=> clock_hdmi_s,			-- master * 5
		locked	=> pll_locked_s
	);
	
	-- The TBBlue
	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"0B",		-- 11 = VTrucco Multicore
		versao			=> X"18",		-- 1.08
		usar_kempjoy	=> '1',
		usar_keyjoy		=> '1',
		use_turbosnd_g	=> false,
		use_sid_g		=> false,
		use_1024kb_g	=> false
	)
	port map (
		-- Clock
		iClk_master			=> clock_master_s,
		oClk_vid				=> clock_video_s,

		-- Reset
		iPowerOn				=> poweron_s,
		iHardReset			=> hard_reset_s,
		iSoftReset			=> soft_reset_s,
		oSoftReset			=> int_soft_reset_s,

		-- Keys
		iKey50_60hz			=> FKeys_s(3),
		iKeyScanDoubler	=> FKeys_s(2),
		iKeyScanlines		=> FKeys_s(7),
		iKeyDivMMC			=> FKeys_s(10) or not btn_n_i(2),
		iKeyMF				=> FKeys_s(9)  or not btn_n_i(3),
		iKeyTurbo			=> FKeys_s(8),
		iKeysHard			=> "00",

		-- Keyboard
		oRows					=> kb_rows_s,
		iColumns				=> kb_columns_s,

		-- RGB
		oRGB_r				=> rgb_r_s,
		oRGB_g				=> rgb_g_s,
		oRGB_b				=> rgb_b_s,
		oRGB_hs_n			=> rgb_hs_n_s,
		oRGB_vs_n			=> rgb_vs_n_s,
		oRGB_cs_n			=> open,
		oRGB_hb_n			=> open,
		oRGB_vb_n			=> open,
		oScandbl_en			=> scandbl_en_s,
		oScandbl_sl			=> scanlines_s,
		oMachTiming			=> mach_timing_s,
		oNTSC_PAL			=> open,

		-- VRAM
		oVram_a				=> vram_addr_s,
		iVram_dout			=> vram_dout_s,
		oVram_cs				=> vram_cs_s,
		oVram_rd				=> vram_oe_s,

		-- Bootrom
		oBootrom_en			=> open,
		oRom_a				=> rom_addr_s,
		iRom_dout			=> rom_data_s,
		oMultiboot			=> open,

		-- RAM
		oRam_a				=> ram_addr_s,
		oRam_din				=> ram_din_s,
		iRam_dout			=> ram_dout_s,
		oRam_cs				=> ram_cs_s,
		oRam_rd				=> ram_oe_s,
		oRam_wr				=> ram_we_s,

		-- SPI (SD and Flash)
		oSpi_mosi			=> spi_mosi_s,
		oSpi_sclk			=> spi_sclk_s,
		oSD_cs_n				=> sd_cs_n_o,
		iSD_miso				=> sd_miso_i,
		oFlash_cs_n			=> flash_cs_n_s,
		iFlash_miso			=> flash_miso_s,

		-- Sound
		iEAR					=> ear_i,
		oSPK					=> spk_s,
		oMIC					=> mic_s,
		oPSG_L				=> psg_L_s,
		oPSG_R				=> psg_R_s,
		oSID_L				=> sid_L_s,
		oSID_R				=> sid_R_s,
		oDAC					=> open,

		-- Joystick
		-- order: Fire2, Fire, Up, Down, Left, Right
		iJoy0					=> joy1_s,
		iJoy1					=> joy2_s,

		-- Mouse
		iMouse_en			=> '1',
		iMouse_x				=>	mouse_x_s,
		iMouse_y				=>	mouse_y_s,
		iMouse_bts			=>	mouse_bts_s,
		iMouse_wheel		=>	mouse_wheel_s,
		oPS2mode				=> open,

		-- Lightpen
		iLp_signal			=> '0',
		oLp_en				=> open,

		-- Serial
		iRs232_rx			=> '0',
		oRs232_tx			=> open,
		iRs232_dtr			=> '0',
		oRs232_cts			=> open,

		-- BUS
		oCpu_a				=> open,
		oCpu_do				=> open,
		iCpu_di				=> (others => '1'),
		oCpu_mreq			=> open,
		oCpu_ioreq			=> open,
		oCpu_rd				=> open,
		oCpu_wr				=> open,
		oCpu_m1				=> open,
		iCpu_Wait_n			=> '1',
		iCpu_nmi				=> '1',
		iCpu_int_n			=> '1',
		iCpu_romcs			=> '0',
		iCpu_ramcs			=> '0',
		iCpu_busreq_n		=> '1',
		oCpu_busack_n		=> open,
		oCpu_clock			=> open,
		oCpu_halt_n			=> open,
		oCpu_rfsh_n			=> open,
		iCpu_iorqula		=> '0',
		
		--Debug
		oD_leds				=> open,
		oD_reg_o				=> open,
		oD_others			=> open
	);
		
	-- SRAM AS7C34096-10
	ram : entity work.dpSRAM_2x512x8
	port map(
		clk					=> clock_master_s,
		-- Porta 0 = VRAM
		porta0_addr			=> vram_addr_s,
		porta0_ce			=> ram_cs_s,
		porta0_oe			=> vram_oe_s,
		porta0_we			=> '0',
		porta0_din			=> (others => '0'),
		porta0_dout			=> vram_dout_s,
		-- Porta 1 = Upper RAM
		porta1_addr			=> ram_addr_s,
		porta1_ce			=> ram_cs_s,
		porta1_oe			=> ram_oe_s,
		porta1_we			=> ram_we_s,
		porta1_din			=> ram_din_s,
		porta1_dout			=> ram_dout_s,
		-- Outputs to SRAM on board
		sram_addr			=> sram_addr_o,
		sram_data			=> sram_data_io,
		sram_ce_n			=> sram_ce_n_o,
		sram_oe_n			=> sram_oe_n_o,
		sram_we_n			=> sram_we_n_o
	);

	-- PS/2 emulating speccy keyboard
	kb: entity work.keyboard
	generic map (
		clkfreq_g		=> 28000
	)
	port map (
		enable			=> '1',
		clock				=> clock_master_s,
		reset				=> poweron_s,
		--
		ps2_clk			=> ps2_clk_io,
		ps2_data			=> ps2_data_io,
		--
		rows				=> kb_rows_s,
		cols				=> kb_columns_s,
		functionkeys_o	=> FKeys_s
	);
	
	-- Mouse control
	mousectrl: entity work.mouse_ctrl
	generic map (
		clkfreq 		=> 28000,
		SENSIBILITY	=> 1						-- Bigger values, less speed
	)
	port map (
		enable		=> '1',
		clock			=> clock_master_s,
		reset			=> reset_s,
		ps2_clk		=> ps2_mouse_clk_io,
		ps2_data		=> ps2_mouse_data_io,
		mouse_x 		=> mouse_x_s,
		mouse_y		=> mouse_y_s,
		mouse_bts	=> mouse_bts_s,
		mouse_wheel => mouse_wheel_s
	);

	-- Scandoubler with scanlines
--	scandbl: entity work.scandoubler
--	generic map (
--		hSyncLength	=> 61,								-- 29 for 14MHz and 61 for 28MHz
--		vSyncLength	=> 13,
--		ramBits		=> 11									-- 10 for 14MHz and 11 for 28MHz
--	)
--	port map(
--		clk					=> clock_master_s,		-- minimum 2x pixel clock
--		hSyncPolarity		=> '0',
--		vSyncPolarity		=> '0',
--		enable_in			=> scandbl_en_s,
--		scanlines_in		=> scanlines_s,
--		video_in				=> rgb_comb_s,
--		hsync_in				=> rgb_hs_n_s,
--		vsync_in				=> rgb_vs_n_s,
--		video_out			=> rgb_out_s,
--		vsync_out			=> vsync_out_s,
--		hsync_out			=> hsync_out_s,
--		blank_o				=> blank_s
--	);

	ha_value_s <= 24*2 when mach_timing_s(1) = '0' else 32*2;		-- ZX 48K = 00 or 01, ZX128K = 10 or 11

	-----------------------------------------------------------------
	-- video scan converter required to display video on VGA hardware
	-----------------------------------------------------------------
	-- active resolution 192x256
	-- take note: the values below are relative to the CLK period not standard VGA clock period
	inst_scan_conv : entity work.scan_convert
	generic map (
		-- mark active area of input video
		cstart	=>  38*2,  -- composite sync start
		clength	=> 352*2,  -- composite sync length
		-- output video timing
		hB			=>  32*2,	-- h sync
		hC			=>  40*2,	-- h back porch
		hD			=> 352*2,	-- visible video
		vB			=>   2*2,	-- v sync
		vC			=>  5*2,    -- v back porch
		vD			=> 284*2,	-- visible video
		hpad		=>   0*2,	-- create H black border
		vpad		=>   0*2    -- create V black border
	)
	port map (
		CLK			=> clock_video_s,
		CLK_x2		=> clock_master_s,
		--
		hA				=> ha_value_s,	-- h front porch
		I_VIDEO		=> rgb_comb_s,
		I_HSYNC		=> rgb_hs_n_s,
		I_VSYNC		=> rgb_vs_n_s,
		I_SCANLIN	=> scanlines_s,
		--
		O_VIDEO_15	=> open,
		O_VIDEO_31	=> rgb_out_s,
		O_HSYNC		=> hsync_out_s,
		O_VSYNC		=> vsync_out_s,
		O_BLANK		=> blank_s
	);

	-- Boot ROM
	boot_rom: entity work.bootrom
	port map (
		clk		=> clock_master_s,
		addr		=> rom_addr_s(12 downto 0),
		data		=> rom_data_s
	);

	-- Audio
	audio : entity work.Audio_DAC
	port map (
		clock_i	=> clock_master_s,
		reset_i	=> reset_s,
		ear_i		=> ear_i,
		spk_i		=> spk_s,
		mic_i		=> mic_s,
		psg_L_i	=> psg_L_s,
		psg_R_i	=> psg_R_s,
		sid_L_i	=> sid_L_s,
		sid_R_i	=> sid_R_s,
		dac_r_o	=> dac_r_o,
		dac_l_o	=> dac_l_o,
		pcm_L_o	=> pcm_out_L_s,
		pcm_R_o	=> pcm_out_R_s
	);

	-- EPCS4
	epcs4: cyclone_asmiblock
	port map (
		oe          => '0',
		scein       => flash_cs_n_s,
		dclkin      => spi_sclk_s,
		sdoin       => spi_mosi_s,
		data0out    => flash_miso_s
	);

	-- glue
	poweron_s		<= '1' when pll_locked_s = '0'							else '0';
	hard_reset_s	<= '1' when FKeys_s(1) = '1' or btn_n_i(1) = '0'	else '0';
	soft_reset_s	<= '1' when int_soft_reset_s = '1' or FKeys_s(4) = '1' or btn_n_i(4) = '0' 	else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD
	sd_mosi_o	<= spi_mosi_s;
	sd_sclk_o	<= spi_sclk_s;

	-- Audio
	mic_o		<= mic_s;

	-- Joystick
	-- order: Fire2, Fire, Up, Down, Left, Right
	joy1_s	<= not (joy1_p9_i & joy1_p6_i & joy1_up_i & joy1_down_i & joy1_left_i & joy1_right_i);
	joy2_s	<= not (joy2_p9_i & joy2_p6_i & joy2_up_i & joy2_down_i & joy2_left_i & joy2_right_i);

	rgb_comb_s <= rgb_r_s & rgb_g_s & rgb_b_s;

	uh: if hdmi_output_g generate
		-- HDMI
		hdmi: entity work.hdmi
		generic map (
			FREQ	=> 28000000,	-- pixel clock frequency 
			FS		=> 48000,		-- audio sample rate - should be 32000, 41000 or 48000 = 48KHz
			CTS	=> 28000,		-- CTS = Freq(pixclk) * N / (128 * Fs)
			N		=> 6144			-- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300 (Check HDMI spec 7.2 for details)
		)
		port map (
			I_CLK_PIXEL		=> clock_master_s,
			I_R				=> rgb_out_s (7 downto 5) & rgb_out_s (7 downto 5) & rgb_out_s (7 downto 6),
			I_G				=> rgb_out_s (4 downto 2) & rgb_out_s (4 downto 2) & rgb_out_s (4 downto 3),
			I_B				=> rgb_out_s (1 downto 0) & rgb_out_s (1 downto 0) & rgb_out_s (1 downto 0) & rgb_out_s (1 downto 0),
			I_BLANK			=> blank_s,
			I_HSYNC			=> hsync_out_s,
			I_VSYNC			=> vsync_out_s,
			-- PCM audio
			I_AUDIO_ENABLE	=> '1',
			I_AUDIO_PCM_L 	=> pcm_out_L_s & "00",
			I_AUDIO_PCM_R	=> pcm_out_R_s & "00",
			-- TMDS parallel pixel synchronous outputs (serialize LSB first)
			O_RED				=> tdms_r_s,
			O_GREEN			=> tdms_g_s,
			O_BLUE			=> tdms_b_s
		);

		hdmio: entity work.hdmi_out_altera
		port map (
			clock_pixel_i		=> clock_master_s,
			clock_tdms_i		=> clock_hdmi_s,
			red_i					=> tdms_r_s,
			green_i				=> tdms_g_s,
			blue_i				=> tdms_b_s,
			tmds_out_p			=> hdmi_p_s,
			tmds_out_n			=> hdmi_n_s
		);

		vga_r_o(1)		<= hdmi_p_s(3);	-- CLK+	113
		vga_r_o(2)		<= hdmi_n_s(3);	-- CLK-	112
		vga_hsync_n_o	<= hdmi_p_s(2);	-- 2+		10
		vga_vsync_n_o	<= hdmi_n_s(2);	-- 2-		11
		vga_b_o(2)		<= hdmi_p_s(1);	-- 1+		144	
		vga_b_o(1)		<= hdmi_n_s(1);	-- 1-		143
		vga_r_o(0)		<= hdmi_p_s(0);	-- 0+		133
		vga_g_o(2)		<= hdmi_n_s(0);	-- 0-		132
	end generate;
		
	nuh: if not hdmi_output_g generate
		vga_r_o	<= rgb_out_s(7 downto 5)						when scandbl_en_s = '1'	else rgb_comb_s(7 downto 5);
		vga_g_o	<= rgb_out_s(4 downto 2)						when scandbl_en_s = '1'	else rgb_comb_s(4 downto 2);
		vga_b_o	<= rgb_out_s(1 downto 0) & rgb_out_s(0)	when scandbl_en_s = '1'	else rgb_comb_s(1 downto 0) & rgb_comb_s(0);
		vga_hsync_n_o	<= hsync_out_s								when scandbl_en_s = '1'	else rgb_hs_n_s;
		vga_vsync_n_o	<= vsync_out_s								when scandbl_en_s = '1'	else rgb_vs_n_s;
	end generate;

end architecture;