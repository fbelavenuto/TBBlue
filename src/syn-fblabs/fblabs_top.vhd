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
-- ID 5 = FBLabs
--
-- EP2C5T144C8 = 86 pins free
--

-- altera message_off 10540 10541

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Ligar /CE da SRAM no GND
--
-- RGB:
-- 
-- 7 - R (MSB) - Ligar resistor de  500 ohms (510)
-- 6 - R       - Ligar resistor de 1000 ohms
-- 5 - R (LSB) - Ligar resistor de 2000 ohms (2200)

-- 4 - G (MSB) - Ligar resistor de  500 ohms (510)
-- 3 - G       - Ligar resistor de 1000 ohms
-- 2 - G (LSB) - Ligar resistor de 2000 ohms (2200)

-- 1 - B (MSB) - Ligar resistor de  500 ohms (510)
-- 0 - B (LSB) - Ligar resistor de  666 ohms (680)
--

entity fblabs_top is
	port (
		-- Clocks
		clock_50				: in    std_logic;								-- Entrada 50 MHz

		-- Botões
		btn_reset_n			: in    std_logic;								-- /RESET externo

		-- VGA
		vga_rgb				: out   std_logic_vector(7 downto 0);		-- Saida RRRGGGBB
		vga_hsync			: out   std_logic;								-- H-Sync
		vga_vsync			: out   std_logic;								-- V-Sync

		-- Audio DAC TDA1543
		dac_bclk				: out   std_logic;
		dac_ws				: out   std_logic;
		dac_dout				: out   std_logic;

		-- SRAM (AS7C34096)
		sram_addr			: out   std_logic_vector(18 downto 0);		-- 19 bits = 512K
		sram_data			: inout std_logic_vector(7 downto 0);
		sram_oe_n			: out   std_logic;								-- SRAM /OE
		sram_we_n			: out   std_logic;								-- SRAM /WE

		-- Keyboard
		ps2_clk				: inout std_logic;								-- Teclado PS/2
		ps2_data				: inout std_logic;								-- Teclado PS/2

		-- Cassete port
		ear_port				: in    std_logic;								-- Entrada EAR
		mic_port				: out   std_logic;								-- Saida MIC

		-- SD Card
		spi_cs0				: out   std_logic;								-- /CS do cartão SD
		spi_sclk				: out   std_logic;								-- Clock do cartão SD
		spi_miso				: in    std_logic;								-- Entrada serial vinda do cartão SD
		spi_mosi				: out   std_logic;								-- Saída serial para o cartão SD
		sd_access_n			: out   std_logic;								-- /CS do cartão para acionar LED

		-- Joystick
		joy0_up				: in    std_logic;
		joy0_down			: in    std_logic;
		joy0_left			: in    std_logic;
		joy0_right			: in    std_logic;
		joy0_fire			: in    std_logic;
		joy0_fire2			: in    std_logic;
		joy1_up				: inout std_logic						:= 'Z';	-- Compartilhada com mouse ps2
		joy1_down			: inout std_logic						:= 'Z';	-- Compartilhada com mouse ps2
		joy1_left			: in    std_logic;
		joy1_right			: in    std_logic;
		joy1_fire			: in    std_logic;
		joy1_fire2			: in    std_logic
	);
end entity;

architecture behavior of fblabs_top is

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

	-- Master clock
	signal clock_master		: std_logic;
--	signal clock_video		: std_logic;
	signal pll_locked			: std_logic;					-- PLL travado quando 1

	-- Resets
	signal poweron_s			: std_logic;
	signal hard_reset_s		: std_logic;
	signal soft_reset_s		: std_logic;
	signal int_soft_reset_s	: std_logic;
	signal reset_s				: std_logic;

	-- Memory buses
	signal vram_a				: std_logic_vector(18 downto 0);
	signal vram_dout			: std_logic_vector(7 downto 0);
	signal vram_cs				: std_logic;
	signal vram_oe				: std_logic;
	signal ram_a				: std_logic_vector(18 downto 0);		-- 512K
	signal ram_din				: std_logic_vector(7 downto 0);
	signal ram_dout			: std_logic_vector(7 downto 0);
	signal ram_cs				: std_logic;
	signal ram_oe				: std_logic;
	signal ram_we				: std_logic;
	signal rom_a				: std_logic_vector(13 downto 0);		-- 16K
	signal rom_dout			: std_logic_vector(7 downto 0);

	-- Audio
	signal s_ear				: std_logic;	
	signal s_spk				: std_logic;	
	signal s_mic				: std_logic;
	signal s_psg				: unsigned( 9 downto 0);
--	signal s_sid				: unsigned(17 downto 0);

	-- Keyboard
	signal kb_rows				: std_logic_vector(7 downto 0);
	signal kb_columns			: std_logic_vector(4 downto 0);
	signal FKeys_s				: std_logic_vector(12 downto 1);

	-- Joystick
	signal s_joy0				: std_logic_vector(5 downto 0);
	signal s_joy1				: std_logic_vector(5 downto 0);

	-- SPI and EPCS
	signal spi_cs_n			: std_logic;
	signal spi_mosi_s			: std_logic;
	signal spi_sclk_s			: std_logic;
	signal flash_miso_s		: std_logic;
	signal flash_cs_n_s		: std_logic;

	-- Video and scandoubler
	signal rgb_r				: std_logic_vector(2 downto 0);
	signal rgb_g				: std_logic_vector(2 downto 0);
	signal rgb_b				: std_logic_vector(1 downto 0);
	signal rgb_hs_n			: std_logic;
	signal rgb_vs_n			: std_logic;
	signal rgb_comb			: std_logic_vector(7 downto 0);
	signal rgb_out				: std_logic_vector(7 downto 0);
	signal scandbl_en			: std_logic;
	signal hsync_out			: std_logic;
	signal vsync_out			: std_logic;
	signal s_scanlines		: std_logic								:= '0';
	
	-- Mouse
	signal mouse_en			: std_logic								:= '0';
	signal mouse_x				: std_logic_vector(7 downto 0);
	signal mouse_y				: std_logic_vector(7 downto 0);
	signal mouse_bts			: std_logic_vector(2 downto 0);
	signal mouse_wheel		: std_logic_vector(3 downto 0);

	-- Lightpen
	signal lightpen_in		: std_logic;
	signal lightpen_en		: std_logic								:= '0';

begin

	--------------------------------
	-- PLL
	--  50 MHz input
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		inclk0	=> clock_50,
		c0			=> clock_master,		-- 28 MHz
		locked	=> pll_locked
	);

	-- The TBBlue
	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"05",		-- 5 = FBLabs
		versao			=> X"18",		-- 1.08
		usar_kempjoy	=> '1',
		usar_keyjoy		=> '1',
		use_turbosnd_g	=> false,
		use_overlay_g	=> false,
		use_sprites_g	=> false
	)
	port map (
		-- Clock
		iClk_master			=> clock_master,
		oClk_vid				=> open,--clock_video,

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
		iKeyM1				=> FKeys_s(9),
		iKeyTurbo			=> FKeys_s(8),
		iKeysHard			=> (others => '0'),

		-- Keyboard
		oRows					=> kb_rows,
		iColumns				=> kb_columns,

		-- RGB
		oRGB_r				=> rgb_r,
		oRGB_g				=> rgb_g,
		oRGB_b				=> rgb_b,
		oRGB_hs_n			=> rgb_hs_n,
		oRGB_vs_n			=> rgb_vs_n,
		oRGB_cs_n			=> open,
		oRGB_hb_n			=> open,
		oRGB_vb_n			=> open,
		oScandbl_en			=> scandbl_en,
		oScandbl_sl			=> s_scanlines,
		oMachTiming			=> open,
		oNTSC_PAL			=> open,

		-- VRAM
		oVram_a				=> vram_a,
		iVram_dout			=> vram_dout,
		oVram_cs				=> vram_cs,
		oVram_rd				=> vram_oe,

		-- Bootrom
		oBootrom_en			=> open,
		oRom_a				=> rom_a,
		iRom_dout			=> rom_dout,
		oMultiboot			=> open,

		-- RAM
		oRam_a				=> ram_a,
		oRam_din				=> ram_din,
		iRam_dout			=> ram_dout,
		oRam_cs				=> ram_cs,
		oRam_rd				=> ram_oe,
		oRam_wr				=> ram_we,

		-- SPI (SD and Flash)
		oSpi_mosi			=> spi_mosi_s,
		oSpi_sclk			=> spi_sclk_s,
		oSD_cs_n				=> spi_cs_n,
		iSD_miso				=> spi_miso,
		oFlash_cs_n			=> flash_cs_n_s,
		iFlash_miso			=> flash_miso_s,

		-- Sound
		iEAR					=> s_ear,
		oSPK					=> s_spk,
		oMIC					=> s_mic,
		oPSG					=> s_psg,
		oSID					=> open,
		oDAC					=> open,

		-- Joystick
		-- order: Fire2, Fire, Up, Down, Left, Right
		iJoy0					=> s_joy0,
		iJoy1					=> s_joy1,

		-- Mouse
		iMouse_en			=> mouse_en,
		iMouse_x				=>	mouse_x,
		iMouse_y				=>	mouse_y,	
		iMouse_bts			=>	mouse_bts,
		iMouse_wheel		=>	mouse_wheel,
		oPS2mode				=> open,

		-- Lightpen
		iLp_signal			=> lightpen_in,
		oLp_en				=> lightpen_en,

		-- RTC
		ioRTC_sda			=> 'Z',
		ioRTC_scl			=> 'Z',

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

		-- Overlay
		oOverlay_addr 		=> open,
		iOverlay_data		=> (others => '0'),
		pixel_clock_o     => open,
	
		-- Debug
		oD_leds				=> open,
		oD_reg_o				=> open,
		oD_others			=> open
	);

	-- SRAM AS7C34096-12 (-15)
	ram : entity work.dpSRAM_5128
	port map(
		clk				=> clock_master,
		-- Porta 0 = VRAM
		porta0_addr		=> vram_a,
		porta0_ce		=> vram_cs,
		porta0_oe		=> vram_oe,
		porta0_we		=> '0',
		porta0_din		=> (others => '0'),
		porta0_dout		=> vram_dout,
		-- Porta 1 = Upper RAM
		porta1_addr		=> ram_a,
		porta1_ce		=> ram_cs,
		porta1_oe		=> ram_oe,
		porta1_we		=> ram_we,
		porta1_din		=> ram_din,
		porta1_dout		=> ram_dout,
		-- Outputs to SRAM on board
		sram_addr		=> sram_addr,
		sram_data		=> sram_data,
		sram_ce_n		=> open,
		sram_oe_n		=> sram_oe_n,
		sram_we_n		=> sram_we_n
	);

	sound: entity work.Audio_TDA1543
	port map (
		clock			=> clock_master,
		ear			=> s_ear,
		spk			=> s_spk,
		mic			=>	s_mic,
		psg			=>	std_logic_vector(s_psg(7 downto 0)),
		i2s_bclk		=> dac_bclk,
		i2s_ws		=> dac_ws,
		i2s_data		=> dac_dout,
		format		=> '0'
	);

	-- Keyboard Speccy emulado com teclado PS/2
	kb: entity work.keyboard
	generic map (
		clkfreq_g		=> 28000,
		use_ps2_alt_g	=> false
	)
	port map (
		enable			=> '1',
		clock				=> clock_master,
		reset				=> poweron_s,
		ps2_clk			=> ps2_clk,
		ps2_data			=> ps2_data,
		rows				=> kb_rows,
		cols				=> kb_columns,
		teclasF			=> FKeys_s
	);
	
	mousectrl : entity work.mouse_ctrl 
	generic map 
	(
		clkfreq 		=> 28000,
		SENSIBILITY	=> 1
	) 
	port map
	(
		enable		=> mouse_en,
		clock			=> clock_master,
		reset			=> reset_s,
		ps2_data		=> joy1_down,
		ps2_clk		=> joy1_up,
		mouse_x 		=> mouse_x,
		mouse_y		=> mouse_y,
		mouse_bts	=> mouse_bts,
		mouse_wheel => mouse_wheel
	);

	-- Scandoubler with scanlines
	scandbl: entity work.scandoubler
	generic map (
		hSyncLength	=> 61,								-- 29 for 14MHz and 61 for 28MHz
		vSyncLength	=> 13,
		ramBits		=> 11									-- 10 for 14MHz and 11 for 28MHz
	)
	port map(
		clk					=> clock_master,			-- minimum 2x pixel clock
		hSyncPolarity		=> '0',
		vSyncPolarity		=> '0',
		enable_in			=> scandbl_en,
		scanlines_in		=> s_scanlines,
		video_in				=> rgb_comb,
		hsync_in				=> rgb_hs_n,
		vsync_in				=> rgb_vs_n,
		video_out			=> rgb_out,
		vsync_out			=> vsync_out,
		hsync_out			=> hsync_out
	);

	-- Boot ROM
	boot_rom: entity work.bootrom
	port map (
		clk		=> clock_master,
		addr		=> rom_a(12 downto 0),
		data		=> rom_dout
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
	poweron_s		<= '1' when pll_locked = '0'								else '0';
	hard_reset_s	<= '1' when FKeys_s(1) = '1' 								else '0';
	soft_reset_s	<= '1' when int_soft_reset_s = '1' or FKeys_s(4) = '1' or btn_reset_n = '0'	else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD
	spi_mosi		<= spi_mosi_s;
	spi_sclk		<= spi_sclk_s;
	spi_cs0		<= spi_cs_n;
	sd_access_n	<= spi_cs_n;

	-- VGA (ULA and ULA+ mixer)
	rgb_comb <= rgb_r & rgb_g & rgb_b;

	vga_rgb			<= rgb_out;
	vga_hsync		<= hsync_out;
	vga_vsync		<= vsync_out;

	-- EAR e MIC
	s_ear		<= not ear_port;
	mic_port	<= s_mic;

	-- Joystick
	-- ordem: Fire2, Fire, Up, Down, Left, Right
	s_joy0	<= not (joy0_fire2 & joy0_fire & joy0_up & joy0_down & joy0_left & joy0_right);
	s_joy1	<= not (joy1_fire2 & joy1_fire & joy1_up & joy1_down & joy1_left & joy1_right)	when lightpen_en = '0' else (others => '0');

	-- Mouse e Lightpen
	lightpen_in <= joy1_fire2	when lightpen_en = '1'	else '0';
	mouse_en	<= lightpen_en;

end architecture;