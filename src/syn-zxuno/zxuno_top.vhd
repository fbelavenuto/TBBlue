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
-- ID 9 = ZX-Uno
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity zxuno_top is
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- SRAM (AS7C34096)
		sram_addr_o			: out   std_logic_vector(18 downto 0)	:= (others => '0');
		sram_data_io		: inout std_logic_vector(7 downto 0)	:= (others => 'Z');
		sram_we_n_o			: out   std_logic								:= '1';

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

		-- Flash
		flash_cs_n_o		: out   std_logic								:= '1';
		flash_sclk_o		: out   std_logic								:= '0';
		flash_mosi_o		: out   std_logic								:= '0';
		flash_miso_i		: in    std_logic;
		flash_wp_o			: out   std_logic								:= '0';
		flash_hold_o		: out   std_logic								:= '1';

		-- Joystick
		joy_up_i				: in    std_logic;
		joy_down_i			: in    std_logic;
		joy_left_i			: in    std_logic;
		joy_right_i			: in    std_logic;
		joy_fire1_i			: in    std_logic;
		joy_fire2_i			: in    std_logic;
		joy_fire3_i			: in    std_logic;

		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;

		-- VGA
		vga_rgb_o			: out   std_logic_vector(8 downto 0)	:= (others => '0');		-- Saida RRRGGGBBB
		vga_csync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';
		vga_ntsc_o			: out   std_logic								:= '0';
		vga_pal_o			: out   std_logic								:= '1';

		-- GPIO
--		gpio_io				: inout std_logic_vector(35 downto 6)	:= (others => 'Z');

		-- Debug
		led_o					: out   std_logic								:= '0'
	);
end entity;

architecture behavior of zxuno_top is

	-- Master clock
	signal clock_master_s	: std_logic;
--	signal clock_video_s		: std_logic;

	-- Resets
	signal poweron_cnt_s		: unsigned(3 downto 0)				:= (others => '1');
	signal poweron_s			: std_logic								:= '0';
	signal hard_reset_s		: std_logic;
	signal soft_reset_s		: std_logic;
	signal int_soft_reset_s	: std_logic;
	signal reset_s				: std_logic;
	signal core_reload_s		: std_logic;
		
	-- Memory buses
	signal vram_a_s			: std_logic_vector(19 downto 0);
	signal vram_dout_s		: std_logic_vector(7 downto 0);
	signal vram_cs_s			: std_logic;
	signal vram_oe_s			: std_logic;
	signal ram_a_s				: std_logic_vector(19 downto 0);
	signal ram_din_s			: std_logic_vector(7 downto 0);
	signal ram_dout_s			: std_logic_vector(7 downto 0);
	signal ram_cs_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;
	signal rom_a_s				: std_logic_vector(13 downto 0);		-- 16K
	signal rom_dout_s			: std_logic_vector(7 downto 0);

	-- Audio
	signal spk_s				: std_logic;	
	signal mic_s				: std_logic;
	signal psg_L_s				: unsigned( 7 downto 0);
	signal psg_R_s				: unsigned( 7 downto 0);
	signal sid_L_s				: unsigned(17 downto 0);
	signal sid_R_s				: unsigned(17 downto 0);

	-- Keyboard
	signal kb_rows_s			: std_logic_vector(7 downto 0);
	signal kb_columns_s		: std_logic_vector(4 downto 0);
	signal FKeys_s				: std_logic_vector(12 downto 1);

	-- SPI
	signal sd_cs_n_s			: std_logic;
	signal spi_mosi_s			: std_logic;
	signal spi_sclk_s			: std_logic;

	-- Joystick
	signal joy1_s				: std_logic_vector(5 downto 0);
	signal joy2_s           : std_logic_vector(5 downto 0);

	-- Video and scandoubler
	signal rgb_r_s				: std_logic_vector(2 downto 0);
	signal rgb_g_s				: std_logic_vector(2 downto 0);
	signal rgb_b_s				: std_logic_vector(1 downto 0);
	signal rgb_hs_n_s			: std_logic;
	signal rgb_vs_n_s			: std_logic;
	signal rgb_out_s			: std_logic_vector(7 downto 0);
	signal rgb_comb_s			: std_logic_vector(7 downto 0);
	signal scartmode_s		: std_logic;
	signal ntsc_pal_s			: std_logic;
	signal scandbl_en_s		: std_logic;
	signal scandbl_sl_s		: std_logic;
	signal hsync_out_s		: std_logic;
	signal vsync_out_s		: std_logic;
	
	-- Mouse
	signal mouse_x_s			: std_logic_vector(7 downto 0);	
	signal mouse_y_s			: std_logic_vector(7 downto 0);			
	signal mouse_bts_s		: std_logic_vector(2 downto 0);		
	signal mouse_wheel_s		: std_logic_vector(3 downto 0);		
		
begin

	--------------------------------
	-- PLL
	--  50 MHz input
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		CLK_IN1	=> clock_50_i,
		CLK_OUT1	=> clock_master_s
	);

	-- The TBBlue
	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"09",			-- 9 = ZXUNO
		versao			=> X"18",			-- 1.08
		usar_kempjoy	=> '1',
		usar_keyjoy		=> '1',
		use_turbosnd_g	=> false,
		use_sid_g		=> false,
		use_1024kb_g	=> false
	)
	port map (
		-- Clock
		iClk_master			=> clock_master_s,
		oClk_vid				=> open,--clock_video_s,

		-- Reset
		iPowerOn				=> poweron_s,
		iHardReset			=> hard_reset_s,
		iSoftReset			=> soft_reset_s,
		oSoftReset			=> int_soft_reset_s,

		-- Keys
		iKey50_60hz			=> FKeys_s(3),
		iKeyScanDoubler	=> FKeys_s(2),
		iKeyScanlines		=> FKeys_s(7),
		iKeyDivMMC			=> FKeys_s(10),
		iKeyMF				=> FKeys_s(9),
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
		oScandbl_sl			=> scandbl_sl_s,
		oMachTiming			=> open,
		oNTSC_PAL			=> ntsc_pal_s,

		-- VRAM
		oVram_a				=> vram_a_s,
		iVram_dout			=> vram_dout_s,
		oVram_cs				=> vram_cs_s,
		oVram_rd				=> vram_oe_s,

		-- Bootrom
		oBootrom_en			=> open,
		oRom_a				=> rom_a_s,
		iRom_dout			=> rom_dout_s,
		oMultiboot			=> open,

		-- RAM
		oRam_a				=> ram_a_s,
		oRam_din				=> ram_din_s,
		iRam_dout			=> ram_dout_s,
		oRam_cs				=> ram_cs_s,
		oRam_rd				=> ram_oe_s,
		oRam_wr				=> ram_we_s,

		-- SPI (SD and Flash)
		oSpi_mosi			=> spi_mosi_s,
		oSpi_sclk			=> spi_sclk_s,
		oSD_cs_n				=> sd_cs_n_s,
		iSD_miso				=> sd_miso_i,
		oFlash_cs_n			=> flash_cs_n_o,
		iFlash_miso			=> flash_miso_i,

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
		iLp_signal			=> '0',--lightpen_i,
		oLp_en				=> open,

		-- RTC
		ioRTC_sda			=> open,
		ioRTC_scl			=> open,

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

		-- Debug
		oD_leds				=> open,
		oD_reg_o				=> open,
		oD_others			=> open
	);

	-- SRAM AS7C34096-10
	ram : entity work.dpSRAM_5128
	port map(
		clk					=> clock_master_s,
		-- Porta 0 = VRAM
		porta0_addr			=> vram_a_s(18 downto 0),
		porta0_ce			=> vram_cs_s,
		porta0_oe			=> vram_oe_s,
		porta0_we			=> '0',
		porta0_din			=> (others => '0'),
		porta0_dout			=> vram_dout_s,
		-- Porta 1 = Upper RAM
		porta1_addr			=> ram_a_s(18 downto 0),
		porta1_ce			=> ram_cs_s,
		porta1_oe			=> ram_oe_s,
		porta1_we			=> ram_we_s,
		porta1_din			=> ram_din_s,
		porta1_dout			=> ram_dout_s,
		-- Outputs to SRAM on board
		sram_addr			=> sram_addr_o,
		sram_data			=> sram_data_io,
		sram_ce_n			=> open,
		sram_oe_n			=> open,
		sram_we_n			=> sram_we_n_o
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
		dac_l_o	=> dac_l_o
	);

	-- PS/2 emulating speccy keyboard
	kb: entity work.keyboard
	generic map (
		clkfreq_g			=> 28000,
		use_ps2_alt_g		=> false
	)
	port map (
		enable				=> '1',
		clock					=> clock_master_s,
		reset					=> poweron_s,
		--
		ps2_clk				=> ps2_clk_io,
		ps2_data				=> ps2_data_io,
		--
		rows					=> kb_rows_s,
		cols					=> kb_columns_s,
		functionkeys_o	=> FKeys_s,
		core_reload_o		=> core_reload_s
	);

	-- Mouse control
	mousectrl : entity work.mouse_ctrl 
	generic map 
	(
		clkfreq 		=> 28000,
		SENSIBILITY	=> 1						-- Bigger values, less speed
	) 
	port map
	(
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
	scandbl: entity work.scandoubler
	generic map (
		hSyncLength	=> 61,								-- 29 for 14MHz and 61 for 28MHz
		vSyncLength	=> 13,
		ramBits		=> 11									-- 10 for 14MHz and 11 for 28MHz
	)
	port map(
		clk					=> clock_master_s,		-- minimum 2x pixel clock
		hSyncPolarity		=> '0',
		vSyncPolarity		=> '0',
		enable_in			=> scartmode_s,
		scanlines_in		=> scandbl_sl_s,
		video_in				=> rgb_comb_s,
		hsync_in				=> rgb_hs_n_s,
		vsync_in				=> rgb_vs_n_s,
		video_out			=> rgb_out_s,
		hsync_out			=> hsync_out_s,
		vsync_out			=> vsync_out_s
	);

	-- Boot ROM
	boot_rom: entity work.bootrom
	port map (
		clk		=> clock_master_s,
		addr		=> rom_a_s(12 downto 0),
		data		=> rom_dout_s
	);

	-- Multiboot
	mb: entity work.multiboot
	port map (
		reset_i		=> poweron_s,
		clock_i		=> clock_master_s,
		start_i		=> core_reload_s,
		spiaddr_i	=> X"6B000000"
	);


	-- Glue logic
	-- Power-on counter
	process (clock_master_s)
	begin
		if rising_edge(clock_master_s) then
			if poweron_cnt_s /= 0 then
				poweron_cnt_s <= poweron_cnt_s - 1;
			end if;
		end if;
	end process;

	poweron_s		<= '1' when poweron_cnt_s /= 0							else '0';
	hard_reset_s	<= '1' when FKeys_s(1) = '1' 								else '0';
	soft_reset_s	<= '1' when FKeys_s(4) = '1' or int_soft_reset_s = '1'				else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD and Flash
	sd_mosi_o		<= spi_mosi_s;
	sd_sclk_o		<= spi_sclk_s;
	sd_cs_n_o		<= sd_cs_n_s;
	flash_mosi_o	<= spi_mosi_s;
	flash_sclk_o	<= spi_sclk_s;
	flash_wp_o		<= '0';
	flash_hold_o	<=	'1';
	led_o				<= not sd_cs_n_s;

	-- Joystick
	-- order: Fire2, Fire, Up, Down, Left, Right
	joy1_s	<= not (joy_fire2_i  & joy_fire1_i  & joy_up_i  & joy_down_i  & joy_left_i  & joy_right_i);
	joy2_s	<= (others => '0');

	-- VGA (ULA and ULA+ mixer)
	rgb_comb_s <= rgb_r_s & rgb_g_s & rgb_b_s;

	scartmode_s		<= not scandbl_en_s;
	vga_rgb_o		<= rgb_out_s & rgb_out_s(0);
	vga_csync_n_o	<= hsync_out_s		when scandbl_en_s = '0'		else (hsync_out_s and vsync_out_s);
	vga_vsync_n_o	<= vsync_out_s		when scandbl_en_s = '0'		else '1';
	vga_ntsc_o		<= ntsc_pal_s;
	vga_pal_o		<= not ntsc_pal_s;

end architecture;
