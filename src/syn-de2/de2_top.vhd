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

-- altera message_off 10540 10541

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de2_top is
	port (
		-- Clocks
		CLOCK_27       : in    std_logic;
		CLOCK_50       : in    std_logic;
		EXT_CLOCK      : in    std_logic;

		-- Switches
		SW             : in    std_logic_vector(17 downto 0);
		-- Buttons
		KEY            : in    std_logic_vector(3 downto 0);

		-- 7 segment displays
		HEX0           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX1           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX2           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX3           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX4           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX5           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX6           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX7           : out   std_logic_vector(6 downto 0)		:= (others => '1');

		-- Red LEDs
		LEDR           : out   std_logic_vector(17 downto 0)		:= (others => '0');
		-- Green LEDs
		LEDG           : out   std_logic_vector(8 downto 0)		:= (others => '0');

		-- Serial
		UART_RXD       : in    std_logic;
		UART_TXD       : out   std_logic									:= '1';

		-- IRDA
		IRDA_RXD       : in    std_logic;
		IRDA_TXD       : out   std_logic									:= '0';

		-- SDRAM
		DRAM_ADDR      : out   std_logic_vector(11 downto 0)		:= (others => '0');
		DRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
		DRAM_BA_0      : out   std_logic									:= '1';
		DRAM_BA_1      : out   std_logic									:= '1';
		DRAM_CAS_N     : out   std_logic									:= '1';
		DRAM_CKE       : out   std_logic									:= '1';
		DRAM_CLK       : out   std_logic									:= '1';
		DRAM_CS_N      : out   std_logic									:= '1';
		DRAM_LDQM      : out   std_logic									:= '1';
		DRAM_RAS_N     : out   std_logic									:= '1';
		DRAM_UDQM      : out   std_logic									:= '1';
		DRAM_WE_N      : out   std_logic									:= '1';

		-- Flash
		FL_ADDR        : out   std_logic_vector(21 downto 0)		:= (others => '0');
		FL_DQ          : inout std_logic_vector(7 downto 0)		:= (others => 'Z');
		FL_RST_N       : out   std_logic									:= '1';
		FL_OE_N        : out   std_logic									:= '1';
		FL_WE_N        : out   std_logic									:= '1';
		FL_CE_N        : out   std_logic									:= '1';

		-- SRAM
		SRAM_ADDR      : out   std_logic_vector(17 downto 0)		:= (others => '0');
		SRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
		SRAM_CE_N      : out   std_logic									:= '1';
		SRAM_OE_N      : out   std_logic									:= '1';
		SRAM_WE_N      : out   std_logic									:= '1';
		SRAM_UB_N      : out   std_logic									:= '1';
		SRAM_LB_N      : out   std_logic									:= '1';

		--	ISP1362 Interface
		OTG_ADDR       : out   std_logic_vector(1 downto 0)		:= (others => '0');	--	ISP1362 Address 2 Bits
		OTG_DATA       : inout std_logic_vector(15 downto 0)		:= (others => 'Z');	--	ISP1362 Data bus 16 Bits
		OTG_CS_N       : out   std_logic									:= '1';					--	ISP1362 Chip Select
		OTG_RD_N       : out   std_logic									:= '1';					--	ISP1362 Write
		OTG_WR_N       : out   std_logic									:= '1';					--	ISP1362 Read
		OTG_RST_N      : out   std_logic									:= '1';					--	ISP1362 Reset
		OTG_FSPEED     : out   std_logic									:= 'Z';					--	USB Full Speed,	0 = Enable, Z = Disable
		OTG_LSPEED     : out   std_logic									:= 'Z';					--	USB Low Speed, 	0 = Enable, Z = Disable
		OTG_INT0       : in    std_logic;															--	ISP1362 Interrupt 0
		OTG_INT1       : in    std_logic;															--	ISP1362 Interrupt 1
		OTG_DREQ0      : in    std_logic;															--	ISP1362 DMA Request 0
		OTG_DREQ1      : in    std_logic;															--	ISP1362 DMA Request 1
		OTG_DACK0_N    : out   std_logic									:= '1';					--	ISP1362 DMA Acknowledge 0
		OTG_DACK1_N    : out   std_logic									:= '1';					--	ISP1362 DMA Acknowledge 1

		--	LCD Module 16X2
		LCD_ON         : out   std_logic									:= '0';					--	LCD Power ON/OFF, 0 = Off, 1 = On
		LCD_BLON       : out   std_logic									:= '0';					--	LCD Back Light ON/OFF, 0 = Off, 1 = On
		LCD_DATA       : inout std_logic_vector(7 downto 0)		:= (others => '0');	--	LCD Data bus 8 bits
		LCD_RW         : out   std_logic									:= '1';					--	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN         : out   std_logic									:= '1';					--	LCD Enable
		LCD_RS         : out   std_logic									:= '1';					--	LCD Command/Data Select, 0 = Command, 1 = Data

		--	SD_Card Interface
		SD_DAT         : inout std_logic									:= 'Z';					--	SD Card Data (SPI MISO)
		SD_DAT3        : inout std_logic									:= 'Z';					--	SD Card Data 3 (SPI /CS)
		SD_CMD         : inout std_logic									:= 'Z';					--	SD Card Command Signal (SPI MOSI)
		SD_CLK         : out   std_logic									:= '1';					--	SD Card Clock (SPI SCLK)

		-- I2C
		I2C_SCLK       : inout std_logic									:= 'Z';
		I2C_SDAT       : inout std_logic									:= 'Z';

		-- PS/2 Keyboard
		PS2_CLK        : inout std_logic									:= 'Z';
		PS2_DAT        : inout std_logic									:= 'Z';

		-- VGA
		VGA_R          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_G          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_B          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_HS         : out   std_logic									:= '0';
		VGA_VS         : out   std_logic									:= '0';
		VGA_BLANK		: out   std_logic									:= '1';
		VGA_SYNC			: out   std_logic									:= '0';
		VGA_CLK		   : out   std_logic									:= '0';

		-- Ethernet Interface
		ENET_CLK       : out   std_logic									:= '0';					--	DM9000A Clock 25 MHz
		ENET_DATA      : inout std_logic_vector(15 downto 0)		:= (others => 'Z');	--	DM9000A DATA bus 16Bits
		ENET_CMD       : out   std_logic									:= '0';					--	DM9000A Command/Data Select, 0 = Command, 1 = Data
		ENET_CS_N      : out   std_logic									:= '1';					--	DM9000A Chip Select
		ENET_WR_N      : out   std_logic									:= '1';					--	DM9000A Write
		ENET_RD_N      : out   std_logic									:= '1';					--	DM9000A Read
		ENET_RST_N     : out   std_logic									:= '1';					--	DM9000A Reset
		ENET_INT       : in    std_logic;															--	DM9000A Interrupt

		-- Audio
		AUD_XCK        : out   std_logic									:= '0';
		AUD_BCLK       : out   std_logic									:= '0';
		AUD_ADCLRCK    : out   std_logic									:= '0';
		AUD_ADCDAT     : in    std_logic;
		AUD_DACLRCK    : out   std_logic									:= '0';
		AUD_DACDAT     : out   std_logic									:= '0';

		-- TV Decoder
		TD_DATA        : in    std_logic_vector(7 downto 0);									--	TV Decoder Data bus 8 bits
		TD_HS          : in    std_logic;															--	TV Decoder H_SYNC
		TD_VS          : in    std_logic;															--	TV Decoder V_SYNC
		TD_RESET       : out   std_logic									:= '1';					--	TV Decoder Reset

		-- GPIO
		GPIO_0         : inout std_logic_vector(35 downto 0)		:= (others => 'Z');
		GPIO_1         : inout std_logic_vector(35 downto 0)		:= (others => 'Z')
	);
end entity;

architecture behavior of de2_top is

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
	signal clk_14				: std_logic;
	signal clock_video		: std_logic;
	signal clock_audio		: std_logic;
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
	signal s_sid				: unsigned(17 downto 0);

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

	signal data_enable		: std_logic;
	signal rgb_lcd				: std_logic_vector(7 downto 0);
	signal lcd_hb_n			: std_logic;
	signal lcd_vb_n			: std_logic;
	signal hsync_lcd_n		: std_logic;
	signal vsync_lcd_n		: std_logic;
	signal hcount				: std_logic_vector(8 downto 0);
	signal vcount				: std_logic_vector(8 downto 0);

	signal temp_hs				: std_logic;
	signal temp_vs				: std_logic;

	-- Joystick (Minimig standard)
	signal s_joy0				: std_logic_vector(5 downto 0);
	signal s_joy1				: std_logic_vector(5 downto 0);
	alias J0_UP					: std_logic						is GPIO_1(34);
	alias J0_DOWN				: std_logic						is GPIO_1(32);
	alias J0_LEFT				: std_logic						is GPIO_1(30);
	alias J0_RIGHT				: std_logic						is GPIO_1(28);
	alias J0_BTN				: std_logic						is GPIO_1(35);
	alias J0_BTN2				: std_logic						is GPIO_1(29);
	alias J0_MMB				: std_logic						is GPIO_1(26);
	alias J1_UP					: std_logic						is GPIO_1(24);
	alias J1_DOWN				: std_logic						is GPIO_1(22);
	alias J1_LEFT				: std_logic						is GPIO_1(20);
	alias J1_RIGHT				: std_logic						is GPIO_1(23);
	alias J1_BTN				: std_logic						is GPIO_1(25);
	alias J1_BTN2				: std_logic						is GPIO_1(21);
	alias J1_MMB				: std_logic						is GPIO_1(27);

	-- Mouse
	signal mouse_x				: std_logic_vector(7 downto 0);
	signal mouse_y				: std_logic_vector(7 downto 0);
	signal mouse_bts			: std_logic_vector(2 downto 0);
	signal mouse_wheel		: std_logic_vector(3 downto 0);

	-- debug
	signal D_cpu_a				: std_logic_vector(15 downto 0);
	signal D_cpu_di			: std_logic_vector(7 downto 0);
	signal D_cpu_do			: std_logic_vector(7 downto 0);
	signal s_cpu_a				: std_logic_vector(15 downto 0);
	signal s_cpu_d				: std_logic_vector(7 downto 0);
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
	-- 100 MHz memory clock output
	--  28 MHz master clock output
	--------------------------------
	pll: entity work.pll1
	port map (
		inclk0		=> CLOCK_50,
		c0				=> clock_master,			-- 28 MHz
		locked		=> pll_locked
	);

	pllaudio: entity work.pll2
	port map (
		inclk0		=> CLOCK_27,
		c0				=> clock_audio
	);

	-- TB-Blue
	tbblue1 : entity work.tbblue
	generic map (
		usar_turbo		=> true,
		num_maquina		=> X"02",		-- 2 = DE-2
		versao			=> X"18",		-- 1.08
		usar_kempjoy	=> '0',
		usar_keyjoy		=> '0',
		use_turbosnd_g	=> true,
		use_overlay_g	=> true,
		use_sprites_g	=> true
	)
	port map (
		-- Clock
		iClk_master			=> clock_master,
		oClk_vid				=> clk_14,

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
		iKeysHard			=> "00",

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
		oSD_cs_n				=> SD_DAT3,
		iSD_miso				=> SD_DAT,
		oFlash_cs_n			=> flash_cs_n_s,
		iFlash_miso			=> flash_miso_s,

		-- Sound
		iEAR					=> s_ear,
		oSPK					=> s_spk,
		oMIC					=> s_mic,
		oPSG					=> s_psg,
		oSID					=> s_sid,
		oDAC					=> open,

		-- Joystick
		-- order: Fire2, Fire, Up, Down, Left, Right
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
		oCpu_do				=> s_cpu_d,
		iCpu_di				=> (others => '1'),
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

		-- Overlay
		oOverlay_addr		=> overlay_addr_s,
		iOverlay_data		=> overlay_data_s,
		pixel_clock_o		=> pixel_clock_s,

		-- Debug
		oD_leds				=> LEDR(7 downto 0),
		oD_reg_o				=> open,
		oD_others			=> open
	);
	
	clock_video <= not clk_14;
	
	-- SRAM IS61WV25616BLL (ou EDBLL)
--	ram : entity work.dpSRAM_25616
--	port map(
--		clk				=> clock_master,
--		-- Porta0 (VRAM)
--		porta0_addr		=> vram_addr_s,
--		porta0_ce		=> vram_cs,
--		porta0_oe		=> vram_oe,
--		porta0_we		=> '0',
--		porta0_din		=> (others => '0'),
--		porta0_dout		=> vram_dout,
--		-- Porta1 (Upper RAM)
--		porta1_addr		=> ram_a,
--		porta1_ce		=> ram_cs,
--		porta1_oe		=> ram_oe,
--		porta1_we		=> ram_we,
--		porta1_din		=> ram_din,
--		porta1_dout		=> ram_dout,
--		-- Outputs to SRAM on board
--		sram_addr		=> SRAM_ADDR,					-- SRAM on board address bus
--		sram_data		=> SRAM_DQ,						--	SRAM on board data bus
--		sram_ub			=> SRAM_UB_N,					--	SRAM on board /UB
--		sram_lb			=> SRAM_LB_N,					--	SRAM on board /LB
--		sram_ce_n		=> SRAM_CE_N,					--	SRAM on board /CE
--		sram_oe_n		=> SRAM_OE_N,					--	SRAM on board /OE
--		sram_we_n		=> SRAM_WE_N					--	SRAM on board /WE
--	);

	ram : entity work.tpSRAM_25616
	port map(
		clk				=> clock_master,
		
		-- Porta0 (VRAM)
		porta0_addr		=> vram_a,
		porta0_ce		=> vram_cs,
		porta0_oe		=> vram_oe,
		porta0_we		=> '0',
		porta0_din		=> (others => '0'),
		porta0_dout		=> vram_dout,
		
		-- Porta1 (Upper RAM)
		porta1_addr		=> ram_a,
		porta1_ce		=> ram_cs,
		porta1_oe		=> ram_oe,
		porta1_we		=> ram_we,
		porta1_din		=> ram_din,
		porta1_dout		=> ram_dout,
		
		-- Porta2 (Overlay)
		porta2_addr		=> overlay_addr_s,
		porta2_ce		=> not pixel_clock_s, --not clock_video,
		porta2_oe		=> not pixel_clock_s, --not clock_video,
		porta2_we		=> '0',
		porta2_din		=> (others => '0'),
		porta2_dout		=> overlay_data_s,
		
		-- Outputs to SRAM on board
		sram_addr		=> SRAM_ADDR,					-- SRAM on board address bus
		sram_data		=> SRAM_DQ,						--	SRAM on board data bus
		sram_ub			=> SRAM_UB_N,					--	SRAM on board /UB
		sram_lb			=> SRAM_LB_N,					--	SRAM on board /LB
		sram_ce_n		=> SRAM_CE_N,					--	SRAM on board /CE
		sram_oe_n		=> SRAM_OE_N,					--	SRAM on board /OE
		sram_we_n		=> SRAM_WE_N					--	SRAM on board /WE
	);

	----------------
	-- Gerenciador de audio com CODEC WM8731
	----------------
	sound: entity work.Audio_WM8731
	port map (
		reset			=> reset_s,
		clock			=> clock_audio,
		ear			=> s_ear,
		spk			=> s_spk,
		mic			=>	s_mic,
		psg			=>	s_psg,
		sid_i			=> s_sid,

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
		clkfreq_g		=> 28000,
		use_ps2_alt_g	=> false
	)
	port map (
		enable			=> '1',
		clock				=> clock_master,
		reset				=> poweron_s,
		ps2_clk			=> PS2_CLK,
		ps2_data			=> PS2_DAT,
		rows				=> kb_rows,
		cols				=> kb_columns,
		teclasF			=> FKeys_s
	);

	-- Mouse control
	mousectrl : entity work.mouse_ctrl
	generic map
	(
		clkfreq 		=> 28000,
		SENSIBILITY	=> 1		 -- Bigger values, less speed
	)
	port map
	(
		enable		=> '0',				-- 1 to enable
		clock			=> clock_master,
		reset			=> reset_s,
		ps2_data		=> open,
		ps2_clk		=> open,
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
	hard_reset_s	<= '1' when Fkeys_s(1) = '1' 								else '0';
	soft_reset_s	<= '1' when int_soft_reset_s = '1' or Fkeys_s(4) = '1' or KEY(0) = '0' 		else '0';
	reset_s			<= poweron_s or hard_reset_s or soft_reset_s;

	-- SD
	SD_CMD	<= spi_mosi_s;
	SD_CLK	<= spi_sclk_s;

	-- Flash
	FL_OE_N	<= '1';
	FL_WE_N	<= '1';
	FL_CE_N	<= '1';

	-- VGA
	rgb_comb <= rgb_r & rgb_g & rgb_b;

	VGA_R  <= rgb_out (7 downto 5) & "0000000";
	VGA_G  <= rgb_out (4 downto 2) & "0000000";
	VGA_B  <= rgb_out (1 downto 0) & rgb_out (0) & "0000000";	
	
	VGA_HS <= hsync_out;
	VGA_VS <= vsync_out;

	VGA_BLANK	<=	'1';
	VGA_CLK	   <= clock_master;

	-- Joystick
	-- ordem: Fire2, Fire, Up, Down, Left, Right
	s_joy0 <= not (J0_BTN2 & J0_BTN & J0_UP & J0_DOWN & J0_LEFT & J0_RIGHT);
	s_joy1 <= not (J1_BTN2 & J1_BTN & J1_UP & J1_DOWN & J1_LEFT & J1_RIGHT);


	HEX0 <= "0000111"; --T
	HEX1 <= "0001001"; --X H
	HEX2 <= "0000110"; --E
	HEX3 <= "1001000"; --N

	-- Debug

	D_cpu_a	<= s_cpu_a;
	D_cpu_di	<= s_cpu_d;
	D_cpu_do	<= s_cpu_d;

--	ld7: entity work.seg7
--	port map(
--		D		=> D_cpu_di(7 downto 4),
--		Q		=> HEX7
--	);

--	ld6: entity work.seg7
--	port map(
--		D		=> D_cpu_di(3 downto 0),
--		Q		=> HEX6
--	);

--	ld5: entity work.seg7
--	port map(
--		D		=> D_cpu_do(7 downto 4),
--		Q		=> HEX5
--	);

--	ld4: entity work.seg7
--	port map(
--		D		=> D_cpu_do(3 downto 0),
--		Q		=> HEX4
--	);

--	ld3: entity work.seg7
--	port map(
--		D		=> D_cpu_a(15 downto 12),
--		Q		=> HEX3
--	);

--	ld2: entity work.seg7
--	port map(
--		D		=> D_cpu_a(11 downto 8),
--		Q		=> HEX2
--	);

--	ld1: entity work.seg7
--	port map(
--		D		=> D_cpu_a(7 downto 4),
--		Q		=> HEX1
--	);

--	ld0: entity work.seg7
--	port map(
--		D		=> D_cpu_a(3 downto 0),
--		Q		=> HEX0
--	);

	--LEDG(7)		<= s_ear;
	--LEDG(6)		<= poweron;
	--LEDG(5)		<= reset;
	--LEDG(4)		<= key_wait;
--	--LEDG(3)		<= nmi;
	--LEDG(2)		<= ulap_en;
	--LEDG(1)		<= scandbl_en;
	--LEDG(0)		<= CLOCK_27;

end architecture;
