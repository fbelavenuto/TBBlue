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
-- Terasic DE1 top-level
--

-- altera message_off 10540 10541

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Generic top-level entity for Altera DE1 board
entity de1_top is
	generic (
		usar_sdram		: boolean	:= false
	);
	port (
		-- Clocks
		CLOCK_24       : in    std_logic_vector(1 downto 0);
		CLOCK_27       : in    std_logic_vector(1 downto 0);
		CLOCK_50       : in    std_logic;
		EXT_CLOCK      : in    std_logic;

		-- Switches
		SW             : in    std_logic_vector(9 downto 0);
		-- Buttons
		KEY            : in    std_logic_vector(3 downto 0);

		-- 7 segment displays
		HEX0           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX1           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX2           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX3           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		-- Red LEDs
		LEDR           : out   std_logic_vector(9 downto 0)		:= (others => '0');
		-- Green LEDs
		LEDG           : out   std_logic_vector(7 downto 0)		:= (others => '0');

		-- VGA
		VGA_R          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_G          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_B          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_HS         : out   std_logic									:= '1';
		VGA_VS         : out   std_logic									:= '1';

		-- Serial
		UART_RXD       : in    std_logic;
		UART_TXD       : out   std_logic									:= '1';

		-- PS/2 Keyboard
		PS2_CLK        : inout std_logic									:= '1';
		PS2_DAT        : inout std_logic									:= '1';

		-- I2C
		I2C_SCLK       : inout std_logic									:= '1';
		I2C_SDAT       : inout std_logic									:= '1';

		-- Audio
		AUD_XCK        : out   std_logic									:= '0';
		AUD_BCLK       : out   std_logic									:= '0';
		AUD_ADCLRCK    : out   std_logic									:= '0';
		AUD_ADCDAT     : in    std_logic;
		AUD_DACLRCK    : out   std_logic									:= '0';
		AUD_DACDAT     : out   std_logic									:= '0';

		-- SRAM
		SRAM_ADDR      : out   std_logic_vector(17 downto 0)		:= (others => '0');
		SRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
		SRAM_CE_N      : out   std_logic									:= '1';
		SRAM_OE_N      : out   std_logic									:= '1';
		SRAM_WE_N      : out   std_logic									:= '1';
		SRAM_UB_N      : out   std_logic									:= '1';
		SRAM_LB_N      : out   std_logic									:= '1';

		-- SDRAM
		DRAM_ADDR      : out   std_logic_vector(11 downto 0)		:= (others => '0');
		DRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
		DRAM_BA_0      : out   std_logic									:= '1';
		DRAM_BA_1      : out   std_logic									:= '1';
		DRAM_CAS_N     : out   std_logic									:= '1';
		DRAM_CKE       : out   std_logic									:= '0';
		DRAM_CLK       : out   std_logic									:= '1';
		DRAM_CS_N      : out   std_logic									:= '1';
		DRAM_LDQM      : out   std_logic									:= '1';
		DRAM_RAS_N     : out   std_logic									:= '1';
		DRAM_UDQM      : out   std_logic									:= '1';
		DRAM_WE_N      : out   std_logic									:= '1';

		-- Flash
		FL_ADDR        : out   std_logic_vector(21 downto 0)		:= (others => '0');
		FL_DQ          : inout std_logic_vector(7 downto 0)		:= (others => '0');
		FL_RST_N       : out   std_logic									:= '1';
		FL_OE_N        : out   std_logic									:= '1';
		FL_WE_N        : out   std_logic									:= '1';
		FL_CE_N        : out   std_logic									:= '1';

		-- SD card (SPI mode)
		SD_nCS         : out   std_logic									:= '1';
		SD_MOSI        : out   std_logic									:= '1';
		SD_SCLK        : out   std_logic									:= '1';
		SD_MISO        : in    std_logic;

		-- GPIO
		GPIO_0         : inout std_logic_vector(35 downto 0)		:= (others => 'Z');
		GPIO_1         : inout std_logic_vector(35 downto 0)		:= (others => 'Z')
	);
end entity;

architecture Behavior of de1_top is

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
	signal clock_sdram		: std_logic;
--	signal clock_video		: std_logic;
	signal pll_locked			: std_logic;

	-- Resets
	signal poweron_s			: std_logic;
	signal hard_reset_s		: std_logic;
	signal soft_reset_s		: std_logic;
	signal int_soft_reset_s	: std_logic;
	signal reset_s				: std_logic;

	-- Memory buses
	signal vram_a				: std_logic_vector(19 downto 0);
	signal vram_dout			: std_logic_vector(7 downto 0);
	signal vram_cs				: std_logic;
	signal vram_oe				: std_logic;
	signal ram_a				: std_logic_vector(19 downto 0);		-- 512K
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
	signal s_sid_L				: unsigned(17 downto 0);
	signal s_sid_R				: unsigned(17 downto 0);

	-- Keyboard
	signal kb_rows				: std_logic_vector(7 downto 0);
	signal kb_columns			: std_logic_vector(4 downto 0);
	signal FKeys_s				: std_logic_vector(12 downto 1);

	-- SPI and EPCS
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
	signal s_scanlines		: std_logic := '0';

	-- Joystick (Minimig standard)
	signal s_joy0				: std_logic_vector(5 downto 0);
	signal s_joy1				: std_logic_vector(5 downto 0);
	alias J0_UP					: std_logic						is GPIO_0(34);
	alias J0_DOWN				: std_logic						is GPIO_0(32);
	alias J0_LEFT				: std_logic						is GPIO_0(30);
	alias J0_RIGHT				: std_logic						is GPIO_0(28);
	alias J0_BTN				: std_logic						is GPIO_0(35);
	alias J0_BTN2				: std_logic						is GPIO_0(29);
	alias J0_MMB				: std_logic						is GPIO_0(26);
	alias J1_UP					: std_logic						is GPIO_0(24);
	alias J1_DOWN				: std_logic						is GPIO_0(22);
	alias J1_LEFT				: std_logic						is GPIO_0(20);
	alias J1_RIGHT				: std_logic						is GPIO_0(23);
	alias J1_BTN				: std_logic						is GPIO_0(25);
	alias J1_BTN2				: std_logic						is GPIO_0(21);
	alias J1_MMB				: std_logic						is GPIO_0(27);

	-- Mouse
	signal mouse_x				: std_logic_vector(7 downto 0);
	signal mouse_y				: std_logic_vector(7 downto 0);
	signal mouse_bts			: std_logic_vector(2 downto 0);
	signal mouse_wheel		: std_logic_vector(3 downto 0);
	alias  MOUSE_PS2_CLK		: std_logic						is GPIO_0(18);
	alias  MOUSE_PS2_DAT		: std_logic						is GPIO_0(19);

	-- Debug
	signal D_display	: std_logic_vector(15 downto 0);
--	signal D_cpu_a		: std_logic_vector(15 downto 0);
	signal s_cpu_a				: std_logic_vector(15 downto 0);
	signal s_cpu_d				: std_logic_vector(7 downto 0);
	signal s_cpu_iorq			: std_logic;
	signal s_cpu_mreq			: std_logic;
	signal s_cpu_rd			: std_logic;
	signal s_cpu_wr			: std_logic;
	signal s_cpu_m1			: std_logic;
--	signal s_ear_key			: std_logic;
--	signal contador			: unsigned(7 downto 0)		:= (others=>'0');
--	signal D_keyb_valid		: std_logic;
--	signal D_keyb_data		: std_logic_vector(7 downto 0);

	-- Raspberry Pi in GPIO_1
 	alias D0				: std_logic						is GPIO_1(24); --PI GPIO 0
 	alias D1				: std_logic						is GPIO_1(25);	--PI GPIO 1
 	alias D2				: std_logic						is GPIO_1(2);	--PI GPIO 2
 	alias D3				: std_logic						is GPIO_1(4);	--PI GPIO 3
 	alias D4				: std_logic						is GPIO_1(6);	--PI GPIO 4
 	alias D5				: std_logic						is GPIO_1(3);	--PI GPIO 5
 	alias D6				: std_logic						is GPIO_1(26);	--PI GPIO 6
 	alias D7				: std_logic						is GPIO_1(23);	--PI GPIO 7

 	alias A0				: std_logic						is GPIO_1(21);	--PI GPIO 8
 	alias A1				: std_logic						is GPIO_1(18);	--PI GPIO 9
 	alias A2				: std_logic						is GPIO_1(16);	--PI GPIO 10
 	alias A3				: std_logic						is GPIO_1(20);	--PI GPIO 11
 	alias A4				: std_logic						is GPIO_1(27);	--PI GPIO 12
 	alias A5				: std_logic						is GPIO_1(28);	--PI GPIO 13
 	alias A6				: std_logic						is GPIO_1(7);	--PI GPIO 14
 	alias A7				: std_logic						is GPIO_1(9);	--PI GPIO 15
 	alias A8				: std_logic						is GPIO_1(31);	--PI GPIO 16
 	alias A9				: std_logic						is GPIO_1(1);	--PI GPIO 17
 	alias A10			: std_logic						is GPIO_1(8);	--PI GPIO 18
 	alias A11			: std_logic						is GPIO_1(30);	--PI GPIO 19
 	alias A12			: std_logic						is GPIO_1(33);	--PI GPIO 20
 	alias A13			: std_logic						is GPIO_1(35);	--PI GPIO 21
 	alias A14			: std_logic						is GPIO_1(12);	--PI GPIO 22
 	alias A15			: std_logic						is GPIO_1(13);	--PI GPIO 23

 	alias MRQ			: std_logic						is GPIO_1(15);	--PI GPIO 24
 	alias IORQ			: std_logic						is GPIO_1(19);	--PI GPIO 25
 	alias RD				: std_logic						is GPIO_1(32);	--PI GPIO 26
 	alias WR				: std_logic						is GPIO_1(10);	--PI GPIO 27

	signal latch_a		: std_logic_vector(15 downto 0);
	signal latch_d		: std_logic_vector(7 downto 0)		:= (others => '0');

begin

	--------------------------------
	-- PLL
	--  50 MHz input
	-- 100 MHz memory clock output
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		inclk0	=> CLOCK_50,
		c0			=> clock_master,			--  28 MHz
		c1			=> clock_sdram,			-- 100 MHz
		c2			=> DRAM_CLK,				-- 100 MHz 45º
		locked	=> pll_locked
	);

	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"01",		-- 1 = DE-1
		versao			=> X"18",		-- 1.08
		usar_kempjoy	=> '1',
		usar_keyjoy		=> '1',
		use_turbosnd_g	=> true,
		use_sid_g		=> true,
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
		iKeyDivMMC			=> FKeys_s(10),
		iKeyMF				=> FKeys_s(9),
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
		oSD_cs_n				=> SD_nCS,
		iSD_miso				=> SD_MISO,
		oFlash_cs_n			=> flash_cs_n_s,
		iFlash_miso			=> flash_miso_s,

		-- Sound
		iEAR					=> s_ear,
		oSPK					=> s_spk,
		oMIC					=> s_mic,
		oPSG_L				=> s_psg_L,
		oPSG_R				=> s_psg_R,
		oSID_L				=> s_sid_L,
		oSID_R				=> s_sid_R,
		oDAC					=> open,

		-- Joystick
		-- ordem: Fire2, Fire, Up, Down, Left, Right
		iJoy0					=> s_joy0,
		iJoy1					=> s_joy1,

		-- Mouse
		iMouse_en			=> '0',
		iMouse_x				=>	mouse_x,
		iMouse_y				=>	mouse_y,
		iMouse_bts			=>	mouse_bts,
		iMouse_wheel		=>	mouse_wheel,
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
		oCpu_a				=> s_cpu_a,
		oCpu_do				=> open,
		iCpu_di				=> ( others => '1'),
		oCpu_mreq			=> s_cpu_mreq,
		oCpu_ioreq			=> s_cpu_iorq,
		oCpu_rd				=> s_cpu_rd,
		oCpu_wr				=> s_cpu_wr,
		oCpu_m1				=> s_cpu_m1,
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
		oD_leds				=> LEDG,
		oD_reg_o				=> open,	
		oD_others			=> LEDR(7 downto 0)
	);

	-- SRAM IS61WV25616BLL
	usarsram: if usar_sdram = false generate
		ram : entity work.dpSRAM_25616
		port map(
			clk				=> clock_master,
			-- Porta0 (VRAM)
			porta0_addr		=> vram_a(18 downto 0),
			porta0_ce		=> vram_cs,
			porta0_oe		=> vram_oe,
			porta0_we		=> '0',
			porta0_din		=> (others => '0'),
			porta0_dout		=> vram_dout,
			-- Porta1 (Upper RAM)
			porta1_addr		=> ram_a(18 downto 0),
			porta1_ce		=> ram_cs,
			porta1_oe		=> ram_oe,
			porta1_we		=> ram_we,
			porta1_din		=> ram_din,
			porta1_dout		=> ram_dout,
			-- Outputs to SRAM on board
			sram_addr		=> SRAM_ADDR,					-- SRAM on board address bus
			sram_data		=> SRAM_DQ,						--	SRAM on board data bus
			sram_ub			=> SRAM_UB_N,					--	SRAM on board /UB
			sram_lb			=> SRAM_LB_N,					--	SRAM on board /LB
			sram_ce_n		=> SRAM_CE_N,					--	SRAM on board /CE
			sram_oe_n		=> SRAM_OE_N,					--	SRAM on board /OE
			sram_we_n		=> SRAM_WE_N					--	SRAM on board /WE
		);
	end generate;

	-- SDRAM
	usarsdram: if usar_sdram = true generate
		ram : entity work.dpSDRAM64Mb
		generic map (
			freq_g	=> 100
		)
		port map (
			clock_i			=> clock_sdram,
			reset_i			=> reset_s,
			refresh_i		=> '1',
			-- Porta 0
			port0_cs_i		=> vram_cs,
			port0_oe_i		=> vram_oe,
			port0_we_i		=> '0',
			port0_addr_i	=> "000" & vram_a,
			port0_data_i	=> (others => '0'),
			port0_data_o	=> vram_dout,
			-- Porta 1
			port1_cs_i		=> ram_cs,
			port1_oe_i		=> ram_oe,
			port1_we_i		=> ram_we,
			port1_addr_i	=> "000" & ram_a,
			port1_data_i	=> ram_din,
			port1_data_o	=> ram_dout,
			-- SD-RAM ports
			mem_cke_o		=> DRAM_CKE,
			mem_cs_n_o		=> DRAM_CS_N,
			mem_ras_n_o		=> DRAM_RAS_N,
			mem_cas_n_o		=> DRAM_CAS_N,
			mem_we_n_o		=> DRAM_WE_N,
			mem_udq_o		=> DRAM_UDQM,
			mem_ldq_o		=> DRAM_LDQM,
			mem_ba_o(1)		=> DRAM_BA_1,
			mem_ba_o(0)		=> DRAM_BA_0,
			mem_addr_o		=> DRAM_ADDR,
			mem_data_io		=> DRAM_DQ
		);
	end generate;

	----------------
	-- Audio manager with CODEC WM8731
	----------------
	sound: entity work.Audio_WM8731
	port map (
		reset			=> reset_s,
		clock			=> CLOCK_24(0),
		ear			=> s_ear,
		spk			=> s_spk,
		mic			=>	s_mic,
		psg_L			=>	s_psg_L,
		psg_R			=>	s_psg_R,
		sid_L_i		=> s_sid_L,
		sid_R_i		=> s_sid_R,

		i2s_xck		=>	AUD_XCK,
		i2s_bclk		=> AUD_BCLK,
		i2s_adclrck	=> AUD_ADCLRCK,
		i2s_adcdat	=> AUD_ADCDAT,
		i2s_daclrck	=> AUD_DACLRCK,
		i2s_dacdat	=> AUD_DACDAT,

		i2c_sda		=> I2C_SDAT,
		i2c_scl		=> I2C_SCLK,
		feedback		=> SW(0)
	);

	-- PS/2 emulating speccy keyboard
	kb: entity work.keyboard
	generic map (
		clkfreq_g		=> 28000
	)
	port map (
		enable			=> '1',
		clock				=> clock_master,
		reset				=> poweron_s,
		--
		ps2_clk			=> PS2_CLK,
		ps2_data			=> PS2_DAT,
		--
		rows				=> kb_rows,
		cols				=> kb_columns,
		functionkeys_o	=> FKeys_s
	);

	-- Mouse control
	mousectrl : entity work.mouse_ctrl
	generic map
	(
		clkfreq		=> 28000,
		SENSIBILITY	=> 1		 -- Bigger values, less speed
	)
	port map
	(
		enable		=> '1',				-- 1 to enable
		clock			=> clock_master,
		reset			=> reset_s,
		ps2_data		=> MOUSE_PS2_DAT,
		ps2_clk		=> MOUSE_PS2_CLK,
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
	poweron_s		<= '1' when pll_locked = '0' or KEY(3) = '0'			else '0';
	hard_reset_s	<= '1' when FKeys_s(1) = '1' 								else '0';
	soft_reset_s	<= '1' when int_soft_reset_s = '1' or FKeys_s(4) = '1' or KEY(0) = '0' 		else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD
	SD_MOSI	<= spi_mosi_s;
	SD_SCLK	<= spi_sclk_s;

	-- Flash
	FL_OE_N	<= '1';
	FL_WE_N	<= '1';
	FL_CE_N	<= '1';

	-- VGA (ULA and ULA+ mixer)
	rgb_comb <= rgb_r & rgb_g & rgb_b;

	VGA_R  <= rgb_out (7 downto 5) & '0';
	VGA_G  <= rgb_out (4 downto 2) & '0';
	VGA_B  <= rgb_out (1 downto 0) & rgb_out (0) & '0';
	VGA_HS <= hsync_out;
	VGA_VS <= vsync_out;

	-- Joystick
	-- ordem: Fire2, Fire, Up, Down, Left, Right
	s_joy0 <= "000000"; --not (J0_BTN2 & J0_BTN & J0_UP & J0_DOWN & J0_LEFT & J0_RIGHT);
	s_joy1 <= "000000"; --not (J1_BTN2 & J1_BTN & J1_UP & J1_DOWN & J1_LEFT & J1_RIGHT);

	----------------------------------------
	-- Raspberry Pi
	----------------------------------------

	A0  <= latch_a(0);
	A1  <= latch_a(1);
	A2  <= latch_a(2);
	A3  <= latch_a(3);
	A4  <= latch_a(4);
	A5  <= latch_a(5);
	A6  <= latch_a(6);
	A7  <= latch_a(7);
	A8  <= latch_a(8);
	A9  <= latch_a(9);
	A10 <= latch_a(10);
	A11 <= latch_a(11);
	A12 <= latch_a(12);
	A13 <= latch_a(13);
	A14 <= latch_a(14);
	A15 <= latch_a(15);

	D0 <= latch_d(0);
	D1 <= latch_d(1);
	D2 <= latch_d(2);
	D3 <= latch_d(3);
	D4 <= latch_d(4);
	D5 <= latch_d(5);
	D6 <= latch_d(6);
	D7 <= latch_d(7);

	--MRQ <= s_cpu_mreq;
	MRQ <= '0' when s_cpu_mreq = '0' and s_cpu_wr = '0' and s_cpu_a(15 downto 13) = "010" else '1';

	--IORQ <= s_cpu_iorq;
   IORQ <= '0' when s_cpu_iorq = '0' and s_cpu_wr = '0' and s_cpu_a(0) = '0' else '1';

--	RD <= s_cpu_rd;

	--ULAplus
	RD <= '0' when s_cpu_iorq = '0' and s_cpu_wr = '0' and s_cpu_a(15 downto 14) = "10"  and s_cpu_a(7 downto 6) = "00"  and s_cpu_a(2) = '0' and s_cpu_a(0) ='1' else '1';
	WR <= '0' when s_cpu_iorq = '0' and s_cpu_wr = '0' and s_cpu_a(15 downto 14) = "11"  and s_cpu_a(7 downto 6) = "00"  and s_cpu_a(2) = '0' and s_cpu_a(0) ='1' else '1';

--	WR <= rgb_vs_n; --GPIO27
--	RD <= rgb_hs_n; --GPIO26

	--WR <= s_cpu_wr;
--	WR <= rgb_hs_n;

	latch_d <= s_cpu_d when MRQ = '0' or IORQ = '0' or RD = '0' or WR = '0';
	latch_a <= s_cpu_a when MRQ = '0' or IORQ = '0' or RD = '0' or WR = '0';

	----------------------------------------
	-- Debugs
	----------------------------------------

	HEX0 <= "0000111"; --T
	HEX1 <= "0001001"; --X H
	HEX2 <= "0000110"; --E
	HEX3 <= "1001000"; --N

	-- debug interrupcao pro teclado
--	s_ear_key <= '0' when s_cpu_iorq = '0' and s_cpu_m1 = '1' and s_cpu_rd = '0' and s_cpu_a(0) = '0' else '1';

--	process (s_ear_key)
--	begin
--		if falling_edge(s_ear_key) then
--			contador	<= contador + 1;
--		end if;
--	end process;

--	D_display		<= "00000000" & std_logic_vector(contador);
--	D_display		<= "00000000" & D_keyb_data;
--	D_display		<= s_cpu_a;

--	ld3: entity work.seg7
--	port map(
--		D		=> D_display(15 downto 12),
--		Q		=> HEX3
--	);

--	ld2: entity work.seg7
--	port map(
--		D		=> D_display(11 downto 8),
--		Q		=> HEX2
--	);

--	ld1: entity work.seg7
--	port map(
--		D		=> D_display(7 downto 4),
--		Q		=> HEX1
--	);

--	ld0: entity work.seg7
--	port map(
--		D		=> D_display(3 downto 0),
--		Q		=> HEX0
--	);

--	LEDR(7)		<= s_ear_key;
--	LEDR(6)		<= s_cpu_iorq;
--	LEDR(5)		<= s_cpu_m1;
--	LEDR(4)		<= s_cpu_rd;
--	LEDR(2)		<= ulap_en;
--	LEDR(1)		<= scandbl_en;
--	LEDR(0)		<= J0_BTN2;

end architecture;
