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
-- ID 6 = VTrucco
--
-- EP2C5T144C8 = 86 free pins
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


entity vtrucco_top is
	port (
		-- Clocks
		clock_50				: in    std_logic;								-- Entrada 50 MHz

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

		-- PS2
		ps2_clk				: inout std_logic;								-- Teclado PS/2
		ps2_data				: inout std_logic;								-- Teclado PS/2

		-- Cassete port
		ear_key				: out    std_logic;								-- interrupcao para o teclado
		mic_port				: out   std_logic;								-- Saida MIC

		-- SD Card
		spi_cs0				: out   std_logic;								-- /CS do cartao SD
		spi_sclk				: out   std_logic;								-- Clock do cartao SD
		spi_miso				: in    std_logic;								-- Entrada serial vinda do cartao SD
		spi_mosi				: out   std_logic;								-- Sai­da serial para o cara£o SD

		-- CPU
		CPU_A					: out   std_logic_vector(15 downto 0);
		CPU_D					: inout std_logic_vector(7 downto 0);
		CPU_MREQ				: out   std_logic;
		CPU_IORQ				: out   std_logic;
		CPU_RD				: out   std_logic;
		CPU_WR				: out   std_logic;
		CPU_M1				: out   std_logic;

		-- Entradas
		CPU_RST				: in    std_logic;
		CPU_INT				: in    std_logic;
		CPU_NMI				: in    std_logic;
		CPU_ROMCS			: in    std_logic;

		NMI_MULTIFACE		: in    std_logic;
		NMI_DIVMMC			: in    std_logic;

		LightPen				: in    std_logic

	);
end entity;

architecture behavior of vtrucco_top is

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
	signal clock_sram			: std_logic;
	signal pll_locked			: std_logic;					-- PLL travado quando 1

	-- Resets
	signal poweron_s			: std_logic;
	signal hard_reset_s		: std_logic;
	signal soft_reset_s		: std_logic;
	signal int_soft_reset_s	: std_logic;
	signal reset_s				: std_logic;
	signal s_db_reset			: std_logic; -- botao de reset com debounce
	signal s_db_divmmc_n		: std_logic; -- botao da divmmc com debounce
	signal s_db_m1_n				: std_logic; -- botao da multiface com debounce

	-- Memory buses
	signal vram_a				: std_logic_vector(19 downto 0);
	signal vram_dout			: std_logic_vector(7 downto 0);
	signal vram_cs				: std_logic;
	signal vram_oe				: std_logic;
	signal ram_a				: std_logic_vector(19 downto 0);
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
	signal s_psg_L				: unsigned( 7 downto 0);
	signal s_psg_R				: unsigned( 7 downto 0);	
	signal s_dac				: std_logic 							:= '0'; -- 0 = I2S, 1 = JAP

	-- Keyboard
	signal kb_rows				: std_logic_vector(7 downto 0);
	signal kb_columns			: std_logic_vector(4 downto 0);
	signal FKeys_s				: std_logic_vector(12 downto 1);
	signal port254_cs_s		: std_logic;
	signal s_ear_key			: std_logic;
	signal s_ps2				: std_logic;
	signal s_columns			: std_logic_vector(4 downto 0);

	-- SPI e EPCS
	signal spi_mosi_s			: std_logic;
	signal spi_sclk_s			: std_logic;
	signal flash_miso_s		: std_logic;
	signal flash_cs_n_s		: std_logic;
	signal spi_cs_n			: std_logic			:= '1';

	-- Video and scandoubler
	signal rgb_r				: std_logic_vector(2 downto 0);
	signal rgb_g				: std_logic_vector(2 downto 0);
	signal rgb_b				: std_logic_vector(1 downto 0);
	signal rgb_i				: std_logic;
	signal rgb_hs_n			: std_logic;
	signal rgb_vs_n			: std_logic;
	signal ulap_en				: std_logic;
	signal rgb_ulap			: std_logic_vector(7 downto 0);
	signal rgb_comb			: std_logic_vector(7 downto 0);
	signal rgb_out				: std_logic_vector(7 downto 0);
	signal scandbl_en			: std_logic;
	signal scandbl_sl			: std_logic;
	signal hsync_out			: std_logic;
	signal vsync_out			: std_logic;
	signal s_scanlines		: std_logic := '0';

	-- Mouse
	signal mouse_x				: std_logic_vector(7 downto 0);
	signal mouse_y				: std_logic_vector(7 downto 0);
	signal mouse_bts			: std_logic_vector(2 downto 0);
	signal mouse_wheel		: std_logic_vector(3 downto 0);

	-- Sinais da CPU
	signal s_cpu_a				: std_logic_vector(15 downto 0);
	signal s_cpu_do			: std_logic_vector(7 downto 0);
	signal s_cpu_di			: std_logic_vector(7 downto 0);
	signal s_cpu_iorq			: std_logic;
	signal s_cpu_mreq			: std_logic;
	signal s_cpu_rd			: std_logic;
	signal s_cpu_wr			: std_logic;
	signal s_cpu_m1			: std_logic;

	-- overlay
	signal vram_addr_s		: std_logic_vector(18 downto 0);
	signal overlay_addr_s	: std_logic_vector(18 downto 0);
	signal overlay_data_s	: std_logic_vector(7 downto 0);
	signal pixel_clock_s		: std_logic;

begin

	--------------------------------
	-- PLL
	--  50 MHz input
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		inclk0	=> clock_50,
		c0			=> clock_master,
		c1			=> clock_sram,
		locked	=> pll_locked
	);

	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"06",		-- 6 = Vtrucco
		versao			=> X"18",		-- 1.08
		usar_kempjoy	=> '1',
		usar_keyjoy		=> '1',
		use_turbosnd_g	=> false,
		use_sid_g		=> false,
		use_1024kb_g	=> false
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
		iKeyDivMMC			=> FKeys_s(10) or not s_db_divmmc_n,
		iKeyMF				=> FKeys_s(9)  or not s_db_m1_n,
		iKeyTurbo			=> FKeys_s(8),
		iKeysHard			=> (others => '0'),

		-- Keyboard
		oRows					=> kb_rows,
		iColumns				=> s_columns,
		port254_cs_o		=> port254_cs_s,

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
		oSD_cs_n				=> spi_cs0,
		iSD_miso				=> spi_miso,
		oFlash_cs_n			=> flash_cs_n_s,
		iFlash_miso			=> flash_miso_s,

		-- Sound
		iEAR					=>	s_ear,
		oSPK					=>	s_spk,
		oMIC					=>	s_mic,
		oPSG_L				=>	s_psg_L,
		oPSG_R				=>	s_psg_R,
		oSID_L				=> open,
		oSID_R				=> open,
		oDAC					=> s_dac,

		-- Joystick
		-- order: Fire2, Fire, Up, Down, Left, Right
		iJoy0					=> (OTHERS => '0'),
		iJoy1					=> (OTHERS => '0'),

		-- Mouse
		iMouse_en			=> s_ps2,
		iMouse_x				=>	mouse_x,
		iMouse_y				=>	mouse_y,
		iMouse_bts			=>	mouse_bts,
		iMouse_wheel		=>	mouse_wheel,
		oPS2mode				=> s_ps2,

		-- Lightpen
		iLp_signal			=> LightPen,
		oLp_en				=> open,

		-- RTC
		ioRTC_sda			=> 'Z',
		ioRTC_scl			=> 'Z',

		-- Serial
		iRs232_rx			=> '0',
		oRs232_tx			=> open,
		iRs232_dtr			=> '0',
		oRs232_cts			=> open,

		-- BUS
		oCpu_a				=> s_cpu_a,
		oCpu_do				=> s_cpu_do,
		iCpu_di				=> s_cpu_di,
		oCpu_mreq			=> s_cpu_mreq,
		oCpu_ioreq			=> s_cpu_iorq,
		oCpu_rd				=> s_cpu_rd,
		oCpu_wr				=> s_cpu_wr,
		oCpu_m1				=> s_cpu_m1,
		iCpu_Wait_n			=> '1',
		iCpu_nmi				=> CPU_NMI,
		iCpu_int_n			=> '1',
		iCpu_romcs			=> CPU_ROMCS,
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

	-- SRAM AS7C34096-12 (-15)
	ram : entity work.dpSRAM_5128
	port map(
		clk				=> clock_master,
		-- Porta 0 = VRAM
		porta0_addr		=> vram_a(18 downto 0),
		porta0_ce		=> vram_cs,
		porta0_oe		=> vram_oe,
		porta0_we		=> '0',
		porta0_din		=> (others => '0'),
		porta0_dout		=> vram_dout,
		-- Porta 1 = Upper RAM
		porta1_addr		=> ram_a(18 downto 0),
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
		psg_L			=>	std_logic_vector(s_psg_L),
		psg_R			=>	std_logic_vector(s_psg_R),
		i2s_bclk		=> dac_bclk,
		i2s_ws		=> dac_ws,
		i2s_data		=> dac_dout,
		format		=> s_dac
	);

	-- Keyboard Speccy emulado com teclado PS/2
	kb: entity work.keyboard
	generic map (
		clkfreq_g		=> 28000,
		use_ps2_alt_g	=> true
	)
	port map (
		enable			=> not s_ps2,
		clock				=> clock_master,
		reset				=> poweron_s,
		--
		ps2_clk			=> ps2_clk,
		ps2_data			=> ps2_data,
		--
		rows				=> kb_rows,
		cols				=> kb_columns,
		functionkeys_o	=> FKeys_s
	);

	-- debounce para botao de reset
	db: entity work.debounce
	port map (
		clk				=> clock_master,
		button			=> CPU_RST,				-- input signal to be debounced
		result			=> s_db_reset			-- debounced signal
	);

	-- debounce para botao da divmmc
	db_2: entity work.debounce
	port map (
		clk				=> clock_master,
		button			=> NMI_DIVMMC,			-- input signal to be debounced
		result			=> s_db_divmmc_n			-- debounced signal
	);

		-- debounce para botao da multiface
	db_3: entity work.debounce
	port map (
		clk				=> clock_master,
		button			=> NMI_MULTIFACE,	-- input signal to be debounced
		result			=> s_db_m1_n			-- debounced signal
	);


	mousectrl : entity work.mouse_ctrl
	generic map
	(
		clkfreq 		=> 28000,
		SENSIBILITY	=> 1 -- Valores maiores, mais lento
	)
	port map
	(
		enable		=> s_ps2,				-- 1 para habilitar
		clock			=> clock_master,
		reset			=> reset_s,
		ps2_data		=> ps2_data,
		ps2_clk		=> ps2_clk,
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
	soft_reset_s	<= '1' when int_soft_reset_s = '1' or FKeys_s(4) = '1' or s_db_reset = '0' 	else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD
	spi_mosi	<= spi_mosi_s;
	spi_sclk	<= spi_sclk_s;

	-- VGA (ULA and ULA+ mixer)
	--rgb_comb <=
	--	rgb_r & (rgb_i and rgb_r) & (rgb_i and rgb_r) &
	--	rgb_g & (rgb_i and rgb_g) & (rgb_i and rgb_g) &
	--	rgb_b & (rgb_i and rgb_b)									when ulap_en = '0' else
	--	rgb_ulap;


	rgb_comb <= rgb_r & rgb_g & rgb_b;

	vga_rgb			<= rgb_out;
	vga_hsync		<= hsync_out;
	vga_vsync		<= vsync_out;

	-- EAR e MIC
	s_ear		<= not CPU_D(6) when s_ear_key = '0' else '0'; -- not ear_port;
	mic_port	<= s_mic;


	-- Sinais da CPU
	CPU_A 	<= s_cpu_a;
	CPU_D  <= (OTHERS=>'Z') when s_cpu_rd = '0' or port254_cs_s = '1' else s_cpu_do; --CPU_D 	<= (OTHERS=>'Z') when s_cpu_rd = '0' else s_cpu_do;
	
	s_cpu_di <= CPU_D;
	CPU_IORQ <= s_cpu_iorq;
	CPU_MREQ <= s_cpu_mreq;
	CPU_RD 	<= s_cpu_rd;
	CPU_WR 	<= s_cpu_wr;
	CPU_M1 	<= s_cpu_m1;

	-- Reads keyboard matrix via BUS
	s_ear_key <= not port254_cs_s;

	-- pino externo para o latch
	ear_key <= s_ear_key;

	-- kb_cols
	s_columns <= kb_columns and CPU_D(4 downto 0) when s_ear_key = '0' else kb_columns;

end architecture;

