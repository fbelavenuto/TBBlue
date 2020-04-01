--
-- TBBlue / ZX Spectrum Next project
-- Copyrights:
-- (C) 2011 Mike Stirling
-- (C) 2015 Fabio Belavenuto
-- (C) 2015 Victor Trucco
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

entity tbblue is
	generic (
		usar_turbo		: boolean					:= true;
		num_maquina    : unsigned(7 downto 0)	:= "00000000";
		versao			: unsigned(7 downto 0)	:= "00000000";
		usar_kempjoy	: std_logic					:= '0';
		usar_keyjoy		: std_logic					:= '0';
		use_turbosnd_g	: boolean					:= false;
		use_overlay_g	: boolean					:= false;
		use_sprites_g	: boolean					:= false;
		use_sid_g		: boolean					:= true
	);
	port (
		-- Clock
		iClk_master			: in  std_logic;								-- 28 MHz
		oClk_vid				: out std_logic;								-- 14 MHz

		-- Reset
		iPowerOn				: in  std_logic;
		iHardReset			: in  std_logic;
		iSoftReset			: in  std_logic;
		oSoftReset			: out std_logic;

		-- Keys
		iKey50_60hz			: in  std_logic;
		iKeyScanDoubler	: in  std_logic;
		iKeyScanlines		: in  std_logic;
		iKeyDivMMC			: in  std_logic;
		iKeyM1				: in  std_logic;
		iKeyTurbo			: in  std_logic;
		iKeysHard			: in  std_logic_vector(1 downto 0) := "00";

		-- Keyboard
		oRows					: out std_logic_vector(7 downto 0);
		iColumns				: in  std_logic_vector(4 downto 0);
		port254_cs_o		: out std_logic;

		-- RGB
		oRGB_r				: out std_logic_vector(2 downto 0);
		oRGB_g				: out std_logic_vector(2 downto 0);
		oRGB_b				: out std_logic_vector(1 downto 0);
		oRGB_hs_n			: out std_logic;
		oRGB_vs_n			: out std_logic;
		oRGB_cs_n			: out std_logic;
		oRGB_hb_n			: out std_logic;
		oRGB_vb_n			: out std_logic;
		oScandbl_en			: out std_logic;
		oScandbl_sl			: out std_logic;
		oMachTiming			: out std_logic_vector(1 downto 0);
		oNTSC_PAL			: out std_logic;

		-- VRAM
		oVram_a				: out std_logic_vector(18 downto 0);
		iVram_dout			: in  std_logic_vector(7 downto 0);
		oVram_cs				: out std_logic;
		oVram_rd				: out std_logic;

		-- Bootrom
		oBootrom_en			: out std_logic;
		oRom_a				: out std_logic_vector(13 downto 0);
		iRom_dout			: in  std_logic_vector(7 downto 0);
		oMultiboot			: out std_logic;

		-- RAM
		oRam_a				: out std_logic_vector(18 downto 0);
		oRam_din				: out std_logic_vector(7 downto 0);
		iRam_dout			: in  std_logic_vector(7 downto 0);
		oRam_cs				: out std_logic;
		oRam_rd				: out std_logic;
		oRam_wr				: out std_logic;

		-- SPI (SD and Flash)
		oSpi_mosi			: out std_logic;
		oSpi_sclk			: out std_logic;
		oSD_cs_n				: out std_logic;
		iSD_miso				: in  std_logic;
		oFlash_cs_n			: out std_logic;
		iFlash_miso			: in  std_logic;

		-- Sound
		iEAR					: in  std_logic;
		oSPK					: out std_logic;
		oMIC					: out std_logic;
		oPSG					: out unsigned( 9 downto 0);
		oSID					: out unsigned(17 downto 0);
		oDAC					: out std_logic;

		-- Joystick
		-- order: Fire2, Fire, Up, Down, Left, Right
		iJoy0					: in  std_logic_vector(5 downto 0);
		iJoy1					: in  std_logic_vector(5 downto 0);

		-- Mouse
		iMouse_en			: in std_logic								:= '0';
		iMouse_x				: in std_logic_vector(7 downto 0);
		iMouse_y				: in std_logic_vector(7 downto 0);
		iMouse_bts			: in std_logic_vector(2 downto 0);
		iMouse_wheel		: in std_logic_vector(3 downto 0);
		oPS2mode				: out std_logic;

		-- Lightpen
		iLp_signal			: in  std_logic;
		oLp_en				: out std_logic;

		-- RTC
		ioRTC_sda			: inout std_logic;
		ioRTC_scl			: inout std_logic;

		-- Serial
		iRs232_rx			: in  std_logic							:= '0';
		oRs232_tx			: out std_logic;
		iRs232_dtr			: in  std_logic							:= '0';
		oRs232_cts			: out std_logic;

		-- BUS
		oCpu_a				: out std_logic_vector(15 downto 0);
		oCpu_do				: out std_logic_vector( 7 downto 0);
		iCpu_di				: in  std_logic_vector( 7 downto 0);
		oCpu_mreq			: out std_logic;
		oCpu_ioreq			: out std_logic;
		oCpu_rd				: out std_logic;
		oCpu_wr				: out std_logic;
		oCpu_m1				: out std_logic;
		iCpu_Wait_n			: in  std_logic;
		iCpu_nmi				: in  std_logic								:= '1';
		iCpu_int_n			: in  std_logic								:= '1';
		iCpu_romcs			: in  std_logic								:= '0';
		iCpu_ramcs			: in  std_logic								:= '0';
		iCpu_busreq_n		: in  std_logic								:= '1';
		oCpu_busack_n		: out std_logic;
		oCpu_clock			: out std_logic;
		oCpu_halt_n			: out std_logic;
		oCpu_rfsh_n			: out std_logic;
		iCpu_iorqula		: in  std_logic								:= '0';

		-- Overlay
		oOverlay_addr 		: out std_logic_vector(18 downto 0);
		iOverlay_data		: in  std_logic_vector( 7 downto 0);
		pixel_clock_o     : out std_logic;

		-- Debug
		oD_leds				: out std_logic_vector( 7 downto 0);
		oD_reg_o				: out std_logic_vector( 7 downto 0);
		oD_others			: out std_logic_vector( 7 downto 0)
	);
end entity;

architecture Behavior of tbblue is

	-- Clock control
	signal clk_psg				: std_logic;							-- Clock 1.75 MHz para o AY (Clock Enable)
	signal clk_cpu				: std_logic;							-- Clock  3.5 MHz para a CPU (contida pela ULA)
	signal clk_vid				: std_logic;							-- Clock   14 MHz para a ULA
	signal counter				: unsigned(3 downto 0);				-- Contador para dividir o clock master
	signal pixel_clock_s		: std_logic;

	-- Portas config, reset e bootrom
	signal port243B_en_s		: std_logic;
	signal port253B_en_s		: std_logic;
	signal register_q			: std_logic_vector(7 downto 0)	:= (others => '0');
	signal bootrom_s			: std_logic								:= '1';
	signal register_data_s	: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg00_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg01_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg02_data_s		: std_logic_vector(7 downto 0)	:= "00000100";
	signal reg05_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg07_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg10_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg21_data_s		: std_logic_vector(7 downto 0);
	signal reg22_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal reg23_data_s		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal sprite_border_q	: std_logic								:= '0';
	signal sprite_visible_q	: std_logic								:= '0';

	-- Turbo
	signal turbo				: std_logic;
	signal s_ena_turbo		: std_logic;

	-- Reset signals
	signal poweron_n			: std_logic;
	signal softreset_s		: std_logic;
	signal hardreset_s		: std_logic;
	signal reset_s				: std_logic;
	signal reset_n				: std_logic;
	signal multiboot_q		: std_logic								:= '0';
	signal softreset_q		: std_logic;
	signal hardreset_q		: std_logic;
	signal softreset_p_q		: std_logic;
	signal hardreset_p_q		: std_logic;
	signal poweron_cnt		: unsigned(3 downto 0)				:= (others => '1');
	signal softreset_cnt		: unsigned(3 downto 0)				:= (others => '0');
	signal hardreset_cnt		: unsigned(3 downto 0)				:= (others => '0');

	signal transparency_q	: std_logic_vector(7 downto 0)	:= "00001000"; --black with bright


	-- CPU signals
	signal cpu_wait_n			: std_logic;								-- /WAIT
	signal cpu_irq_n			: std_logic;								-- /IRQ
	signal cpu_nmi_n			: std_logic;								-- /NMI
--	signal cpu_busreq_n		: std_logic;								-- /BUSREQ
	signal cpu_m1_n			: std_logic;								-- /M1
	signal cpu_mreq_n			: std_logic;								-- /MREQ
	signal cpu_ioreq_n		: std_logic;								-- /IOREQ
	signal cpu_rd_n			: std_logic;								-- /RD
	signal cpu_wr_n			: std_logic;								-- /WR
	signal cpu_a				: std_logic_vector(15 downto 0);		-- A
	signal cpu_di				: std_logic_vector(7 downto 0);		-- D in
	signal cpu_do				: std_logic_vector(7 downto 0);		-- D out
	signal cpu_d_s				: std_logic_vector(7 downto 0);

	-- ULA
	signal ula_din				: std_logic_vector(7 downto 0);
	signal ula_dout			: std_logic_vector(7 downto 0);
	signal ula_hd_s			: std_logic;								-- ULA has data to send
	signal vram_a				: std_logic_vector(15 downto 0);
	signal vram_dout			: std_logic_vector(7 downto 0);
	signal vram_oe				: std_logic;
	signal vram_cs				: std_logic;
	signal vram_shadow      : std_logic;
	signal rampage_cont_s	: std_logic;
	signal ula_ear				: std_logic;
	signal ula_mic				: std_logic;
	signal ula_spk				: std_logic;
	signal ula_r				: std_logic;
	signal ula_g				: std_logic;
	signal ula_b				: std_logic;
	signal ula_i				: std_logic;
	signal ula_rgbenh			: std_logic_vector(7 downto 0);
	signal ulaenh_en			: std_logic;
	signal ulaenh_enable		: std_logic;
	signal ula50_60hz			: std_logic;
	signal ula_hsync_n		: std_logic;
	signal ula_vsync_n		: std_logic;
	signal ula_int_n			: std_logic;
	signal s_ula_timex_en	: std_logic;

	-- Joystick
	signal joy0_mode			: std_logic_vector(1 downto 0);
	signal joy1_mode			: std_logic_vector(1 downto 0);
	signal joy_columns		: std_logic_vector(4 downto 0);

	-- Sound
	signal psg_do				: std_logic_vector(7 downto 0)	:= "11111111";
	signal psg_dout			: std_logic;
	signal psg_mode			: std_logic_vector(1 downto 0)	:= "10";
	signal s_dac				: std_logic 							:= '0'; -- 0 = I2S, 1 = JAP
	signal s_turbosound		: std_logic								:= '0';
	signal exp_psg_s			: std_logic_vector(7 downto 0);

	-- Memory buses
	signal ram_addr			: std_logic_vector(18 downto 0);				-- RAM absolute address
	signal ram_din				: std_logic_vector(7 downto 0);
	signal ram_dout			: std_logic_vector(7 downto 0);
	signal rom_dout			: std_logic_vector(7 downto 0);				-- ROM boot

	-- Memory and I/Os enables
	-- RAM bank actually being accessed
	signal ram_page			: std_logic_vector(2 downto 0);				-- Bits altos do endereco absoluto da RAM
	signal iocs_en				: std_logic;
	signal iord_en				: std_logic;										-- Leitura em alguma porta de I/O
	signal iowr_en				: std_logic;										-- Escrita em alguma porta de I/O
	signal romboot_en			: std_logic;										-- BOOTROM acessada
	signal romram_en			: std_logic;										-- ROM emulada em RAM acessada
	signal romram_wr_en		: std_logic;										-- ROM emulada em RAM acessada (escrita somente modo config)
	signal ram_en				: std_logic;										-- RAM acessada (R/W)
	signal vram_en				: std_logic;										-- VRAM acessada na pagina 1 (0x4000 a 0x5FFF)
	signal ula_en				: std_logic;										-- Porta 254 da ULA acessada
	signal port7FFD_en		: std_logic;										-- Escrita na porta 7FFD (controle do speccy 128)
	signal port7FFD_reg		: std_logic_vector(7 downto 0);				-- Registro que guarda o valor escrito na porta 7FFD
	signal port1FFD_en		: std_logic;										-- Escrita na porta 1FFD (controle do speccy +3)
	signal port1FFD_reg		: std_logic_vector(7 downto 0);				-- Registro que guarda o valor escrito na porta 1FFD
	signal s_ntsc_pal			: std_logic								:= '0';	-- NTSC

	-- Modo config
	signal romram_page		: std_logic_vector(4 downto 0);				-- Pagina de 16K mapeada na area da ROM (0000-3FFF)

	-- Speccy 128K
	signal s128_disable		: std_logic;										-- Bit 5 porta 7FFD - Desabilitar a escrita na porta 7FFD
	signal s128_rom_page		: std_logic;										-- Bit 4 porta 7FFD - Qual pagina da ROM do speccy128 mapear
	signal s128_shadow		: std_logic;										-- Bit 3 porta 7FFD - Qual pagina de vi­deo a ULA deve mostrar
	signal s128_ram_page		: std_logic_vector(2 downto 0);				-- Bits 2..0 porta 7FFD - Banco da RAM para ser mapeada na pagina 3 (0xC000 - 0xFFFF)

	-- Speccy +3e:
	signal plus3_page					: std_logic_vector(1 downto 0);		-- bits 2..1 da porta 1FFD
	signal plus3_special				: std_logic;								-- bit 0 da porta 1FFD

	-- Machine type and timing
	type machine_type_t is (s_config, s_speccy48, s_speccy128, s_speccy3e);
	signal machine        			: machine_type_t;
	signal machine_timing			: std_logic_vector(1 downto 0);

	-- Divmmc
	signal s_divmmc_enabled			: std_logic		:= '0';
	signal divmmc_no_automap		: std_logic;
	signal divmmc_do					: std_logic_vector(7 downto 0);
	signal divmmc_ram_en				: std_logic;
	signal divmmc_disable_nmi		: std_logic;
	signal divmmc_bank				: std_logic_vector(5 downto 0);
	signal divmmc_rom_en				: std_logic;
	signal divmmc_dout				: std_logic;
	signal s_nmi						: std_logic;
	signal s_button_divmmc			: std_logic;

	-- SPI
	signal sd_cs_n						: std_logic;
	signal spi_cs_n					: std_logic;
	signal spi_mosi					: std_logic;
	signal spi_miso					: std_logic;
	signal spi_sclk					: std_logic;

	-- Scandoubler
	signal scandbl_sl					: std_logic;
	signal scandbl_en					: std_logic;

	-- Debounce chaves externas
	signal db1							: std_logic_vector(1 downto 0);
	signal db2							: std_logic_vector(1 downto 0);
	signal db3							: std_logic_vector(1 downto 0);
	signal db4							: std_logic_vector(1 downto 0);

	-- Kempston
	signal kempjoy_enable_s			: std_logic;
	signal kempston_dout				: std_logic_vector(7 downto 0);
	signal joy_pins 					: std_logic_vector(7 downto 0);
	signal s_kj_out					: std_logic;

	-- Multiface One
	signal s_m1_enabled				: std_logic := '0';
	signal s_m1_rom_cs				: std_logic := '1';
	signal s_m1_ram_cs				: std_logic := '1';
	signal s_nmi_m1					: std_logic := 'Z';
	signal s_multiface_en			: std_logic := '0';
	signal s_button_m1				: std_logic := '1';
	signal s_m1_do						: std_logic_vector(7 downto 0);
	signal s_m1_dout					: std_logic := '0';

	-- Mouse
	signal s_mouse_d 					: std_logic_vector(7 downto 0);
	signal s_mouse_out				: std_logic :='0';
	signal s_ps2_dat					: std_logic;
	signal s_ps2_clk					: std_logic;
	signal s_ps2_mode					: std_logic				:= '0';

	-- Light Pen
	signal s_lp_d0						: std_logic;
	signal s_lp_out					: std_logic;
	signal s_lp_enabled				: std_logic				:= '0';

--	signal s_ay_select : std_logic				:= '1';

	-- BUS
	signal bus_int_n_s				: std_logic;
	signal bus_romcs_s				: std_logic;
	signal bus_ramcs_s				: std_logic;
	signal bus_busreq_n_s			: std_logic;
	signal bus_iorqula_s				: std_logic;

	-- RTC
	signal port103B_en_s				: std_logic;
	signal port113B_en_s				: std_logic;
	signal rtc_scl_s					: std_logic;
	signal rtc_sda_s					: std_logic;

	-- Overlay
	signal overlay_addr_s			: std_logic_vector(15 downto 0);

	signal overlay_X_s				: unsigned(8 downto 0);
	signal overlay_Y_s				: unsigned(8 downto 0);
	signal overlay_off_X_s			: std_logic_vector(7 downto 0);
	signal overlay_off_Y_s			: std_logic_vector(5 downto 0);
	signal overlay_R_s				: std_logic_vector(2 downto 0);
	signal overlay_G_s				: std_logic_vector(2 downto 0);
	signal overlay_B_s				: std_logic_vector(1 downto 0);
	signal overlay_pixel_s			: std_logic								:= '0';

	signal overlay_page_s			: std_logic_vector(1 downto 0)	:= "00";
	signal overlay_order_s			: std_logic_vector(1 downto 0)	:= "00";
	signal overlay_access_type_s	: std_logic								:= '0';
	signal overlay_visible_en_s	: std_logic								:= '0';
	signal overlay_access_en_s 	: std_logic								:= '0';
	signal overlay_rgb_transp_s 	: std_logic								:= '0';
	signal s_new_vram_en				: std_logic;

	-- Sprite
	signal sprite_hc_s				: unsigned( 8 downto 0);
	signal sprite_vc_s				: unsigned( 8 downto 0);
	signal sprite_RGB_s				: std_logic_vector( 7 downto 0);
	signal sprite_pixel_s			: std_logic								:= '0';
	signal sprite_hd_s				: std_logic								:= '0';
	signal sprite_data_s				: std_logic_vector( 7 downto 0);

	-- RGB
	signal rgb_r_s						: std_logic_vector(2 downto 0);
	signal rgb_g_s						: std_logic_vector(2 downto 0);
	signal rgb_b_s						: std_logic_vector(1 downto 0);
	signal hblank_n_s					: std_logic;
	signal vblank_n_s					: std_logic;

begin

	---------
	-- CPU
	---------
	cpu: entity work.T80a
	generic map (
		Mode 			=> 0
	)
	port map (
		RESET_n		=> reset_n,
		CLK_n			=> clk_cpu,
		WAIT_n		=> cpu_wait_n,
		INT_n			=> cpu_irq_n,
		NMI_n			=> cpu_nmi_n,
		BUSRQ_n		=> bus_busreq_n_s,
		M1_n			=> cpu_m1_n,
		MREQ_n		=> cpu_mreq_n,
		IORQ_n		=> cpu_ioreq_n,
		RD_n			=> cpu_rd_n,
		WR_n			=> cpu_wr_n,
		RFSH_n		=> oCpu_rfsh_n,
		HALT_n		=> oCpu_halt_n,
		BUSAK_n		=> oCpu_busack_n,
		A				=> cpu_a,
		D				=> cpu_d_s
	);
	cpu_do	<= cpu_d_s;
	cpu_d_s	<= cpu_di				when (cpu_mreq_n = '0' or cpu_ioreq_n = '0') and cpu_rd_n = '0'	else
					(others => 'Z')	when (cpu_mreq_n = '0' or cpu_ioreq_n = '0') and cpu_wr_n = '0'	else
					(others => '1')	when cpu_m1_n = '0' and cpu_ioreq_n = '0'									else	-- IM 2
					iCpu_di;

	cpu_wait_n	<= iCpu_Wait_n when machine /= s_config else '1';

	cpu_nmi_n	<= '0' when iCpu_nmi = '0'                             and reset_s = '0' and machine /= s_config	else
						 '0' when s_nmi = '0'    and divmmc_no_automap = '0' and reset_s = '0' and machine /= s_config	else
						 '0' when s_nmi_m1 = '0' and divmmc_no_automap = '1' and reset_s = '0' and machine /= s_config  else
					    '1';
	bus_int_n_s <= iCpu_int_n when machine /= s_config else '1';
	cpu_irq_n	<= bus_int_n_s and ula_int_n;

	-----------
	-- Sound
	-----------
	ts1: if not use_turbosnd_g generate
		explorer: entity work.explorer
		port map (
			clk						=> iClk_master,
			clk_psg					=> clk_psg,
			rst_n						=> reset_n,
			cpu_a						=> cpu_a,
			cpu_di					=> cpu_do,
			cpu_do					=> psg_do,
			cpu_iorq_n				=> cpu_ioreq_n,
			cpu_rd_n					=> cpu_rd_n,
			cpu_wr_n					=> cpu_wr_n,
			cpu_m1_n					=> cpu_m1_n,

			-- audio
			out_audio_mix		=> exp_psg_s,

			-- controles
			enable					=> not psg_mode(1),
			selected					=> '1',
			psg_out  				=> psg_dout,					-- "1" se temos dados prontos para o barramento
			ctrl_aymode				=> psg_mode(0),				-- 0 = YM, 1 = AY

			-- pinos para controle de AY externo
			BDIR						=> open,
			BC1						=> open,
			-- Serial
			rs232_rx					=> iRs232_rx,
			rs232_tx					=> oRs232_tx,
			rs232_cts				=> oRs232_cts,
			rs232_dtr				=> iRs232_dtr
		);
		oPSG <= "00" & unsigned(exp_psg_s);
	end generate;

	ts2: if use_turbosnd_g generate
		turbosound: entity work.turbosound
		generic map (
			use_sid_g 	=> use_sid_g
		)
		port map (
			clk						=> iClk_master,
			clk_psg					=> clk_psg,
			rst_n						=> reset_n,
			cpu_a						=> cpu_a,
			cpu_di					=> cpu_do,
			cpu_do					=> psg_do,
			cpu_iorq_n				=> cpu_ioreq_n,
			cpu_rd_n					=> cpu_rd_n,
			cpu_wr_n					=> cpu_wr_n,
			cpu_m1_n					=> cpu_m1_n,

			-- audio
			audio_psg_o				=> oPSG,
			audio_sid_o				=> oSID,

			-- controls
			enable					=> not psg_mode(1),     -- "1" to enable first AY
			enable_turbosound		=> s_turbosound,			-- "1" to enable second AY
			turbosound_out  		=> psg_dout,				-- "1" if we have data to collect
			ctrl_aymode				=> psg_mode(0),			-- 0 = YM, 1 = AY
			-- Serial
			rs232_rx					=> iRs232_rx,
			rs232_tx					=> oRs232_tx,
			rs232_cts				=> oRs232_cts,
			rs232_dtr				=> iRs232_dtr
		);
	end generate;

	----------
	-- The ULA
	----------
	ula_inst: entity work.zxula
	port map (
		clock_28_i		=> iClk_master,
		clock_i			=> clk_vid,
		reset_i			=> reset_s,
		mode_i			=> machine_timing,
		turbo_en_i		=> turbo,
		enh_ula_en_i	=> ulaenh_enable,
		timex_en_i		=> s_ula_timex_en,
		vf50_60_i		=> ula50_60hz,
		iocs_i			=> ula_en,
		cpu_addr_i		=> cpu_a,
		cpu_data_i		=> ula_din,
		cpu_data_o		=> ula_dout,
		has_data_o		=> ula_hd_s,
		cpu_mreq_n_i	=> cpu_mreq_n,
		cpu_iorq_n_i	=> cpu_ioreq_n,
		cpu_rd_n_i		=> cpu_rd_n,
		cpu_wr_n_i		=> cpu_wr_n,
		cpu_clock_o		=> clk_cpu,
		cpu_int_n_o		=> ula_int_n,
		-- vram
		vram_shadow_i	=> vram_shadow,
		ram_bank_i		=> rampage_cont_s,
		mem_addr_o		=> vram_a,
		mem_data_i		=> vram_dout,
		mem_cs_o			=> vram_cs,
		mem_oe_o			=> vram_oe,
		-- I/O
		ear_i				=> ula_ear,
		speaker_o		=> ula_spk,
		mic_o				=> ula_mic,
		kb_columns_i	=> iColumns and joy_columns,
		-- RGB
		rgb_r_o			=> ula_r,
		rgb_g_o			=> ula_g,
		rgb_b_o			=> ula_b,
		rgb_i_o			=> ula_i,
		rgb_enh_o		=> ula_rgbenh,
		rgb_enh_en_o	=> ulaenh_en,
		rgb_hsync_o		=> ula_hsync_n,
		rgb_vsync_o		=> ula_vsync_n,
		rgb_hblank_o	=> hblank_n_s,
		rgb_vblank_o	=> vblank_n_s,

		hcount_o			=> overlay_X_s,
		vcount_o			=> overlay_Y_s,
		pixel_clock_o  => pixel_clock_s,
		-- Sprites
		spt_hcount_o	=> sprite_hc_s,
		spt_vcount_o	=> sprite_vc_s
	);

	pixel_clock_o <= pixel_clock_s;

	oRows				<= cpu_a(15 downto 8);

	-------------
	-- DivMMC  --
	-------------
	mmc: entity work.divmmc
	port map (
		clk_master_i	=> iClk_master,
		clock				=> not clk_cpu,				-- Entrada do clock da CPU
		reset_i			=> hardreset_s,				-- Reset Power-on
		cpu_a				=> cpu_a,						-- Barramento de enderecos da CPU
		cpu_wr_n			=> cpu_wr_n,					-- Sinal de escrita da CPU
		cpu_rd_n			=> cpu_rd_n,					-- Sinal de leitura da CPU
		cpu_mreq_n		=> cpu_mreq_n,					-- CPU acessando memoria
		cpu_ioreq_n		=> cpu_ioreq_n,
		cpu_m1_n			=> cpu_m1_n,					-- /M1 da CPU
		di					=> cpu_do,						-- Barramento de dados de entrada
		do					=> divmmc_do,					-- Barramento de dados de sai­da

		spi_cs			=> spi_cs_n,					-- Saida Chip Select para a flash
		sd_cs0			=> sd_cs_n,						-- Saida Chip Select para o cartao
		sd_sclk			=> spi_sclk,					-- Saida SCL
		sd_mosi			=> spi_mosi,					-- Master Out Slave In
		sd_miso			=> spi_miso,					-- Master In Slave Out

		nmi_button_n	=> s_button_divmmc,	  		-- Botao de NMI da DivMMC
		nmi_to_cpu_n	=> s_nmi,						-- Sinal de NMI para a CPU

		no_automap		=> divmmc_no_automap or (not s_divmmc_enabled),		-- Entrada para desabilitar o Auto Mapeamento
		ram_bank			=> divmmc_bank,				-- Sai­da informando qual banco de 8K da RAM deve mapear entre 2000 e 3FFF

		--sinais pra rom e ram
		ram_en_o			=> divmmc_ram_en,
		rom_en_o	 		=> divmmc_rom_en,
		dout				=> divmmc_dout,
		-- Debug
		D_mapterm_o		=> oD_others(6),
		D_automap_o		=> oD_others(7)
	);

	--
	oSpi_sclk	<= spi_sclk;
	oSpi_mosi	<= spi_mosi;
	spi_miso		<= iFlash_miso	when spi_cs_n = '0'	else iSD_miso;
	oSD_cs_n		<= sd_cs_n;
	oFlash_cs_n	<= spi_cs_n;

	--
	kmouse : entity work.kempston_mouse
	port map
	(
		clk					=> clk_cpu,						-- Entrada do clock da CPU
		rst_n					=> reset_n,						-- Reset Power-on
		cpu_a					=> cpu_a,						-- Barramento de enderecos da CPU
		cpu_iorq_n			=> cpu_ioreq_n,				-- CPU acessando portas
		cpu_rd_n				=> cpu_rd_n,					-- Sinal de leitura da CPU

		enable				=> iMouse_en,					-- 1 habilita

		-- entrada
		mouse_x 				=> iMouse_x,
		mouse_y 				=> iMouse_y,
		mouse_bts 			=> iMouse_bts,
		mouse_wheel 		=> iMouse_wheel,

		--saida
		mouse_d				=> s_mouse_d,
		mouse_out			=> s_mouse_out

	);

	lp: entity work.light_pen
	port map
	(
		cpu_a						=> cpu_a,
		cpu_iorq_n				=> cpu_ioreq_n,
		cpu_rd_n					=> cpu_rd_n,

		-- pinos da Light pen
		lp_in						=> iLP_signal,				-- necessita hardware externo neste pino

		-- controle
		enable					=> s_lp_enabled,			-- '1' habilita o modulo

		-- Saida
		lp_do						=> s_lp_d0,
		lp_out					=> s_lp_out					-- "1" se a interface esta disponibilizando dados

	);

	kjoy: entity work.kempston_joystick
	port map
	(
		cpu_a					=> cpu_a,
		cpu_iorq_n			=> cpu_ioreq_n,
		cpu_rd_n				=> cpu_rd_n,

		-- pinos do joystick
		joy_pins				=> joy_pins,

		-- controle
		enable				=> kempjoy_enable_s,

		-- Saida
		kj_do					=> kempston_dout,
		kj_out				=> s_kj_out 				-- "1" se a interface esta disponibilizando dados

	);

	-- Kempston joy
	kempjoy_enable_s <= '1' when usar_kempjoy = '1' and (joy0_mode = "01" or joy1_mode = "01")	else '0';

	joy_pins <= "000" & iJoy0(4 downto 0) when joy0_mode = "01" else
					"000" & iJoy1(4 downto 0) when joy1_mode = "01" else
					(others => '0');

	-- Keyboard joy have 2 buttons
	joys: entity work.joystick_keys
	port map
	(
		-- controle
		cpu_a					=> cpu_a,
		enable				=> usar_keyjoy,			-- 1 habilita

		-- modos
		joy0_mode			=> joy0_mode,
		joy1_mode			=> joy1_mode,

		-- pinos do joystick
		joy0_pins				=> "00" & iJoy0,
		joy1_pins				=> "00" & iJoy1,

		-- Saida
		joy_columns			=> joy_columns

	);

	multiface_inst : entity work.multiface
	port map (
		clock_i					=> clk_cpu,
		reset_n_i				=> reset_n,
		cpu_addr_i				=> cpu_a,
		data_i					=> cpu_do,
		data_o					=> s_m1_do,
		has_data_o				=> s_m1_dout,
		cpu_mreq_n_i			=> cpu_mreq_n,
		cpu_iorq_n_i			=> cpu_ioreq_n,
		cpu_rd_n_i				=> cpu_rd_n,
		cpu_wr_n_i				=> cpu_wr_n,
		cpu_m1_n_i				=> cpu_m1_n,
		nmi_button_n_i			=> s_button_m1,
		nmi_to_cpu_n_o			=> s_nmi_m1,
		-- Multiface interface control
		enable_i					=> s_multiface_en,
		mode_i					=> machine_type_t'pos(machine),
		zxromcs_o				=> open,
		-- RAM and ROM
		m1_rom_cs_n_o			=> s_m1_rom_cs,
		m1_ram_cs_n_o			=> s_m1_ram_cs,
		m1_ram_we_n_o			=> open,
		m1_7ffd_i				=> port7FFD_reg,
		m1_1ffd_i				=> port1FFD_reg
	);

	s_button_divmmc <= (not iKeyDivMMC) when s_divmmc_enabled = '1' else '1';
	s_button_m1 	 <= (not iKeyM1)     when s_m1_enabled = '1' 	 else '1';

	divmmc_no_automap <= '0' when reset_s = '1' or s_button_divmmc = '0' else
								'1' when falling_edge(s_button_m1);

	--so a multiface ou a divmmc pode estar habilitado
	-- na pratica podem ter o mesmo valor, ja que a m1 habilita em 1 e automap em 0
	s_multiface_en <= divmmc_no_automap;

	uov: if use_overlay_g generate
		overlay1 : entity work.overlay
		port map
		(
			clock_28_i		=> iClk_master,
			reset_n_i		=> reset_n,

			overlay_en_i	=> overlay_visible_en_s,

			overlay_X_i		=> overlay_X_s,
			overlay_Y_i		=> overlay_Y_s,
			offset_x_i		=> overlay_off_X_s,
			offset_y_i		=> overlay_off_Y_s,

			overlay_addr_o => overlay_addr_s,
			overlay_data_i => iOverlay_data,

			overlay_R_o		=> overlay_R_s,
			overlay_G_o		=> overlay_G_s,
			overlay_B_o		=> overlay_B_s,

			pixel_en_o		=> overlay_pixel_s

		);
	end generate;

	uspt: if use_sprites_g generate
		-- Sprites
		sprite1 : entity work.sprites
		port map (
			clock_master_i	=> iClk_master,
			clock_pixel_i	=> pixel_clock_s,
			reset_i			=> reset_s,
			over_border_i	=> sprite_border_q,
			hcounter_i		=> sprite_hc_s,
			vcounter_i		=> sprite_vc_s,
			-- CPU
			cpu_a_i			=> cpu_a,
			cpu_d_i			=> cpu_do,
			cpu_d_o			=> sprite_data_s,
			has_data_o		=> sprite_hd_s,
			cpu_iorq_n_i	=> cpu_ioreq_n,
			cpu_rd_n_i		=> cpu_rd_n,
			cpu_wr_n_i		=> cpu_wr_n,
			-- Video out
			rgb_o				=> sprite_RGB_s,
			pixel_en_o		=> sprite_pixel_s
		);
	end generate;

	----------------
	-- Glue logic --
	----------------

	-- Power-on
	process (iPowerOn, iClk_master)
	begin
		if iPowerOn = '1' then
			poweron_cnt <= (others => '1');
		elsif rising_edge(iClk_master) then
			if poweron_cnt /= "0000" then
				poweron_cnt <= poweron_cnt - 1;
			end if;
		end if;
	end process;

	-- Resets
	poweron_n	<= '0' when poweron_cnt /= 0 									else '1';	-- Negative logic
	hardreset_s	<= '1' when iHardReset = '1' or hardreset_q = '1'		else '0';
	oSoftReset	<= softreset_q;
	softreset_s	<= iSoftReset;
	reset_s		<= not poweron_n or hardreset_s or softreset_s;
	reset_n		<= not reset_s;																	-- Negative logic

	-- Geracao dos clocks
	process(iClk_master)
	begin
		if falling_edge(iClk_master) then --must be FALLING !!!!
			counter <= counter + 1;
		end if;
	end process;
	-- counter(0) = /2	= 14
	-- counter(1) = /4	= 7
	-- counter(2) = /8	= 3.5
	-- counter(3) = /16	= 1.75
	-- counter(4) = /32
	-- counter(5) = /64
	clk_vid	<= counter(0);
	clk_psg	<= '1' when counter(3 downto 0) = "1110" else '0';

	oClk_vid	<= clk_vid;

	-- Register number
	process (reset_s, clk_cpu)
	begin
		if reset_s = '1' then
			register_q <= (others => '0');
		elsif falling_edge(clk_cpu) then
			if port243B_en_s = '1' and cpu_wr_n = '0' then
				register_q <= cpu_do;
			end if;
		end if;
	end process;

	-- Write Registers
	process (iclk_master)
	begin

		if rising_edge(iclk_master) then
			if reset_s = '1' then

				softreset_p_q 	<= '0';
				transparency_q	<= "00001000"; --black with bright
				sprite_border_q	<= '0';
				sprite_visible_q	<= '0';
				overlay_off_X_s	<= (others => '0');
				overlay_off_Y_s	<= (others => '0');

				if machine = s_config then
					bootrom_s			<= '1';
				end if;

				if hardreset_s = '1' or poweron_n = '0' then
					multiboot_q			<= '0';
					hardreset_p_q		<= '0';
					machine				<= s_config;
					bootrom_s			<= '1';
					romram_page			<= (others => '0');
					ulaenh_enable		<= '0';
					s_divmmc_enabled	<= '0';
					s_m1_enabled		<= '0';
					psg_mode				<= "00";
					scandbl_en			<= '1';
					scandbl_sl			<= '0';
					s_lp_enabled		<= '0';
					ula50_60hz			<= '0';
					joy0_mode			<= "00";
					joy1_mode			<= "00";
					turbo					<= '0';
					s_ula_timex_en		<= '0';

				end if;

			elsif port253B_en_s = '1' and cpu_wr_n = '0' then
				case register_q is

					when X"02" =>
						hardreset_p_q <= cpu_do(1);
						softreset_p_q <= cpu_do(0);

					when X"03" =>
						if machine = s_config then
							bootrom_s <= '0';
							machine_timing <= cpu_do(4 downto 3);
							case cpu_do(1 downto 0) is
								when "01"	=> machine <= s_speccy48;
								when "10"	=> machine <= s_speccy128;
								when "11"	=> machine <= s_speccy3e;
								when others	=> machine <= s_config;
							end case;
						end if;

					when X"04" =>
						if machine = s_config and bootrom_s = '0' then
							romram_page <= cpu_do(4 downto 0);
						end if;

					when X"05" =>
						if machine = s_config then
							joy0_mode			<= cpu_do(7 downto 6);
							joy1_mode			<= cpu_do(5 downto 4);
							ulaenh_enable		<= cpu_do(3);
							ula50_60hz			<= cpu_do(2);
							scandbl_sl 			<= cpu_do(1);
							scandbl_en			<= cpu_do(0);
						end if;

					when X"06" =>
						if machine = s_config then
							s_ena_turbo			<= cpu_do(7);
							s_dac					<= cpu_do(6);
							s_lp_enabled 		<= cpu_do(5);
							s_divmmc_enabled	<= cpu_do(4);
							s_m1_enabled		<= cpu_do(3);
							s_ps2_mode			<= cpu_do(2);
							psg_mode				<= cpu_do(1 downto 0);
						end if;

					when X"07" =>
						if usar_turbo then
							turbo					<= cpu_do(0);
						end if;

					when X"08" =>
						if machine = s_config then
							s_ula_timex_en		<= cpu_do(2);
							s_turbosound		<= cpu_do(1);
							s_ntsc_pal			<= cpu_do(0);
						end if;

					when X"10" =>
						multiboot_q	<= cpu_do(7);

					when X"14" => -- 20
						transparency_q	<= cpu_do;

					when X"15" => -- 21
						sprite_border_q	<= cpu_do(1);
						sprite_visible_q	<= cpu_do(0);

					when X"16" => -- 22
						overlay_off_X_s <= cpu_do;

					when X"17" => -- 23
						overlay_off_Y_s <= cpu_do(5 downto 0);

					-- Debug
					when X"FF" =>
						oD_leds <= cpu_do;
					when others =>
						null;
				end case;
			end if;

			-- config change on-the-fly
			db1	<= db1(0) & iKeyScanDoubler;
			db2	<= db2(0) & iKey50_60hz;
			db3	<= db3(0) & iKeyScanlines;
			db4	<= db4(0) & iKeyTurbo;

			if db1 = "01" then
				scandbl_en <= not scandbl_en;
			end if;

			if db2 = "01" then
				ula50_60hz <= not ula50_60hz;
			end if;

			if db3 = "01" then
				scandbl_sl <= not scandbl_sl;
			end if;

			if db4 = "01" and s_ena_turbo = '1' and usar_turbo then
				turbo <= not turbo;
			end if;

		end if;
	end process;

	-- Reset register
	process (iClk_master)
		variable reset_v : std_logic_vector(2 downto 0);
	begin
		if falling_edge(iClk_master) then
			reset_v := reset_v(1 downto 0) & reset_s;
			if reset_v = "011" then
				reg02_data_s <= "00000" & not poweron_n & hardreset_q & softreset_q;
			end if;
		end if;
	end process;

	-- Read registers
	process (register_q, reg00_data_s, reg01_data_s, reg02_data_s, reg05_data_s,
				reg07_data_s, reg10_data_s, transparency_q, reg21_data_s, reg22_data_s,
				reg23_data_s)
	begin
		case register_q is
			when X"00" =>
				register_data_s	<= reg00_data_s;
			when X"01" =>
				register_data_s	<= reg01_data_s;
			when X"02" =>
				register_data_s	<= reg02_data_s;
			when X"05" =>
				register_data_s	<= reg05_data_s;
			when X"07" =>
				register_data_s	<= reg07_data_s;
			when X"10" =>
				register_data_s	<= reg10_data_s;
			when X"14" => -- 20
				register_data_s	<= transparency_q;
			when X"15" =>
				register_data_s	<= reg21_data_s;
			when X"16" => -- 22
				register_data_s	<= reg22_data_s;
			when X"17" => -- 22
				register_data_s	<= reg23_data_s;
			when others =>
				register_data_s	<= (others => '0');
		end case;
	end process;

	reg00_data_s <= std_logic_vector(num_maquina);
	reg01_data_s <= std_logic_vector(versao);
	reg05_data_s <= "00000" & ula50_60hz & scandbl_sl & scandbl_en;
	reg07_data_s <= "0000000" & turbo;
	reg10_data_s <= "000000" & iKeysHard;
	reg21_data_s <= "000000" & sprite_border_q & sprite_visible_q;
	reg22_data_s <= overlay_off_X_s;
	reg23_data_s <= "00" & overlay_off_Y_s;

	-- Reset counters
	process (softreset_p_q, iClk_master)
	begin
		if softreset_p_q = '1' then
			softreset_cnt <= (others => '1');
			softreset_q	<= '1';
		elsif rising_edge(iClk_master) then
			if softreset_cnt /= "0000" then
				softreset_cnt <= softreset_cnt - 1;
			else
				softreset_q	<= '0';
			end if;
		end if;
	end process;

	process (hardreset_p_q, iClk_master)
	begin
		if hardreset_p_q = '1' then
			hardreset_cnt <= (others => '1');
			hardreset_q	<= '1';
		elsif rising_edge(iClk_master) then
			if hardreset_cnt /= "0000" then
				hardreset_cnt <= hardreset_cnt - 1;
			else
				hardreset_q	<= '0';
			end if;
		end if;
	end process;


	-- Send config to TOP
	oPS2mode		<= s_ps2_mode;
	oLp_en		<= s_lp_enabled;
	oMultiboot	<= multiboot_q;

	-- 7FFD port = Speccy 128K/+3e
	s128_disable			<= port7FFD_reg(5);
	s128_rom_page			<= port7FFD_reg(4);
	s128_shadow				<= port7FFD_reg(3);
	s128_ram_page			<= port7FFD_reg(2 downto 0);

	-- 1FFD port = Speccy +3e
	plus3_page				<= port1FFD_reg(2 downto 1);
	plus3_special			<= port1FFD_reg(0);

	-- ULA
	rampage_cont_s <= s128_ram_page(0)	when machine = s_speccy128	else		-- content odd pages
							s128_ram_page(2)	when machine = s_speccy3e	else		-- content pages >= 4
							'0';

	vram_shadow  <= s128_shadow			when machine = s_speccy128 or machine = s_speccy3e else '0';	-- bit indicando qual pagina mostrar se for speccy 128K

	bus_busreq_n_s	<= iCpu_busreq_n	when machine /= s_config else '1';
	bus_romcs_s		<= iCpu_romcs		when machine /= s_config else '0';
	bus_ramcs_s		<= iCpu_ramcs		when machine /= s_config else '0';
	bus_iorqula_s	<= iCpu_iorqula	when machine /= s_config else '0';

	-- Memory enables
	romboot_en		<= '1' when overlay_access_en_s = '0' and cpu_mreq_n = '0' and cpu_rd_n = '0' and cpu_a(15 downto 14) = "00" and bootrom_s = '1' else '0';

	romram_en		<= '1' when cpu_mreq_n = '0' and cpu_rd_n = '0' and cpu_a(15 downto 14) = "00" and bootrom_s = '0' and plus3_special = '0'  and bus_romcs_s = '0' else '0';

	romram_wr_en	<= '1' when overlay_access_en_s = '0' and cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_a(15 downto 14) = "00" and bootrom_s = '0' and machine = s_config else '0';

	ram_en			<= '1' when cpu_mreq_n = '0' and (cpu_a(15) = '1' or plus3_special = '1') and bus_ramcs_s = '0' else '0';

	vram_en			<= '1' when cpu_mreq_n = '0' and cpu_a(15 downto 14) = "01" else '0';		-- Ativa leitura e escrita

	-- writing in 0000-3fff when new VRAM is active
	s_new_vram_en 	<= '1' when (( overlay_access_en_s = '1' and overlay_access_type_s = '0' and cpu_wr_n = '0' ) or ( overlay_access_en_s = '1' and overlay_access_type_s = '1' ))
											and cpu_mreq_n = '0' and cpu_a(15 downto 14) = "00" else '0';


	-- Address decoding.  Z80 has separate IO and memory address space
	-- IO ports (nominal addresses - incompletely decoded):
	-- 0xXXFE R/W = ULA  -- Feito pelo modulo da ULA
	-- 0x7FFD W   = 128K paging register
	-- 0xFFFD W   = 128K AY-3-8912 register select
	-- 0xFFFD R   = 128K AY-3-8912 register read
	-- 0xBFFD W   = 128K AY-3-8912 register write
	-- 0x1FFD W   = +3 paging and control register
	-- 0x2FFD R   = +3 FDC status register
	-- 0x3FFD R/W = +3 FDC data register

	-- I/O Port enables
	iocs_en			<= '1' when cpu_ioreq_n = '0' and cpu_m1_n = '1'							else '0';
	iord_en        <= '1' when cpu_ioreq_n = '0' and cpu_m1_n = '1' and cpu_rd_n = '0'  else '0';					-- Leitura em alguma porta
	iowr_en        <= '1' when cpu_ioreq_n = '0' and cpu_m1_n = '1' and cpu_wr_n = '0'  else '0';					-- Escrita em alguma porta

	ula_en         <= '1' when iocs_en = '1' and cpu_a(0) = '0' and bus_iorqula_s = '0'	else '0';

	port7FFD_en    <= '1' when iowr_en = '1' and (machine = s_speccy128 or machine = s_speccy3e) and				-- Ativa somente se for escrita e speccy 128K ou +3e
										cpu_a(15 downto 14) = "01" and cpu_a(1 downto 0) = "01"		else '0';				-- Decodificacao parcial

	port1FFD_en		<= '1' when iowr_en = '1' and machine = s_speccy3e and													-- Ativa somente se for escrita e speccy +3e
	                           cpu_a(15 downto 12) = "0001" and cpu_a(1 downto 0) = "01"	else '0';				-- Decodificacao parcial

	port243B_en_s	<= '1' when iowr_en = '1' and
										cpu_a = X"243B"															else '0';
	port253B_en_s	<= '1' when cpu_ioreq_n = '0' and cpu_m1_n = '1' and
										cpu_a = X"253B"															else '0';

	port103B_en_s	<= '1' when iowr_en = '1' and cpu_a = X"103B"									else '0';	-- RTC SCL (W)
	port113B_en_s	<= '1' when iocs_en = '1' and cpu_a = X"113B"									else '0';	-- RTC SDA (R/W)

	-- Memory control
	-- 128K has pageable RAM at 0xc000
	-- +3 has various additional modes in addition to "normal" mode, which is
	-- the same as the 128K
	-- Extra modes assign RAM banks as follows:
	-- plus3_page    0000    4000    8000    C000
	-- 00            0       1       2       3
	-- 01            4       5       6       7
	-- 10            4       5       6       3
	-- 11            4       7       6       3
	-- NORMAL        ROM     5       2       PAGED

	ram_page <=
		s128_ram_page																						when cpu_a(15 downto 14) = "11" and machine = s_speccy3e and plus3_special = '0'									else
		"0" & cpu_a(15 downto 14)																		when 											machine = s_speccy3e and plus3_special = '1' and plus3_page = "00"	else
		"1" & cpu_a(15 downto 14)																		when 											machine = s_speccy3e and plus3_special = '1' and plus3_page = "01"	else
		(not(cpu_a(15) and cpu_a(14))) & cpu_a(15 downto 14)									when 											machine = s_speccy3e and plus3_special = '1' and plus3_page = "10" 	else
		(not(cpu_a(15) and cpu_a(14))) & (cpu_a(15) or cpu_a(14)) & cpu_a(14)			when 											machine = s_speccy3e and plus3_special = '1' and plus3_page = "11"	else
		s128_ram_page																						when cpu_a(15 downto 14) = "11" and machine = s_speccy128 																else		-- Selectable bank at 0xc000 somente se for speccy 128K
		cpu_a(14) & cpu_a(15 downto 14); -- A=bank: 00=XXX, 01=101, 10=010, 11=XXX							-- Pagina 1 mapeia para banco 5 mesmo se for speccy 48K


	-- Mapa da RAM
	-- 0x000000 a 0x01FFFF (128K) DivMMC	RAM  				A18..16 = 000, 001
	-- 0x020000 a 0x03FFFF (128K) New VRAM 					A18..16 = 010, 011
	-- 0x040000 a 0x05FFFF (128K) para a RAM do Spectrum	A18..16 = 100, 101
	-- 0x060000 a 0x06FFFF  (64K) para ESXDOS e M1			A18..16 = 110
	-- 0x060000 - ESXDOS rom 	- A18..14 = 11000
	-- 0x064000 - M1 rom			- A18..14 = 11001
	-- 0x068000 - M1 extra rom	- A18..14 = 11010
	-- 0x06c000 - M1 ram			- A18..14 = 11011
	-- 0x070000 a 0x07FFFF  (64K) para a ROM do Spectrum	A18..16 = 111

	process (machine, romram_en, cpu_a, s128_rom_page, plus3_page, divmmc_bank,
				divmmc_rom_en, vram_en, s_new_vram_en, overlay_page_s,
				ram_page, romram_page, divmmc_ram_en, s_m1_rom_cs, s_m1_ram_cs)
	begin
		if vram_en = '1' then
			ram_addr <= "10101" & cpu_a(13 downto 0);							-- VRAM access by CPU

		elsif s_new_vram_en = '1' then
			ram_addr <= "010" & overlay_page_s & cpu_a(13 downto 0);		-- new VRAM access by CPU

		elsif machine = s_config then
			if cpu_a(15) = '1' then
				ram_addr <= "10" & ram_page & cpu_a(13 downto 0);
			else
				ram_addr <= romram_page & cpu_a(13 downto 0);
			end if;

		elsif divmmc_ram_en = '1' then
				ram_addr <= "00" & divmmc_bank(3 downto 0) & cpu_a(12 downto 0);

		elsif s_m1_rom_cs = '0' then
				ram_addr <= "11001" & cpu_a(13 downto 0);

		elsif s_m1_ram_cs = '0' then
				ram_addr <= "11011" & cpu_a(13 downto 0);

		elsif romram_en = '1' then
			if divmmc_rom_en = '1' then
				ram_addr <= "11000" & cpu_a(13 downto 0);
			elsif machine = s_speccy48 then
				ram_addr <= "11100" & cpu_a(13 downto 0);
			elsif machine = s_speccy128 then
				ram_addr <= "1110" & s128_rom_page & cpu_a(13 downto 0);
			else -- speccy3e
				ram_addr <= "111" & plus3_page(1) & s128_rom_page & cpu_a(13 downto 0);
			end if;

		else	-- ram_en
			ram_addr <= "10" & ram_page & cpu_a(13 downto 0);

		end if;
	end process;

	-- escrita porta 7FFD (config speccy 128/+3e)
	process(reset_s, clk_cpu)
	begin
		if reset_s = '1' then
			port7FFD_reg <= (others => '0');
		elsif falling_edge(clk_cpu) then
			if port7FFD_en = '1' and s128_disable = '0' then						-- Se bit 5 da porta 7FFD for 1, desabilita escrita na porta
				port7FFD_reg <= cpu_do;														-- Ler 8 bits
			end if;
		end if;
	end process;

	-- escrita porta 1FFD (config speccy +3e)
	process(reset_s, clk_cpu)
	begin
		if reset_s = '1' then
			port1FFD_reg <= (others => '0');
		elsif falling_edge(clk_cpu) then
			if port1FFD_en = '1' and s128_disable = '0' then
				port1FFD_reg <= cpu_do;														-- Ler 8 bits
			end if;
		end if;
	end process;

	-- RTC SCL and SDA write
	process(reset_s, clk_cpu)
	begin
		if reset_s = '1' then
			rtc_scl_s <= '1';
			rtc_sda_s <= '1';
		elsif falling_edge(clk_cpu) then
			if port103B_en_s = '1' then
				rtc_scl_s <= cpu_do(0);
			elsif port113B_en_s = '1' and cpu_wr_n = '0' then
				rtc_sda_s <= cpu_do(0);
			end if;
		end if;
	end process;

	-- RTC
	ioRTC_scl	<= '0' when rtc_scl_s = '0' else 'Z';
	ioRTC_sda	<= '0' when rtc_sda_s = '0' else 'Z';

	-- Conexoes dos barramentos
	ula_din  <= cpu_do;
	ram_din  <= cpu_do;
	--psg_din  <= cpu_do;
	cpu_di <=
			-- Memory
			rom_dout						when romboot_en     = '1'        else		-- Leitura da bootrom interna
			ram_dout						when divmmc_ram_en  = '1'			else		-- Leitura e/ou escrita na RAM da DivMMC quando chaveada no lugar da ROM (0000 - 3FFF)
			ram_dout						when romram_en      = '1'			else		-- Leitura da ROM
			ram_dout						when vram_en        = '1'			else		-- Leitura da VRAM (pelo canal da CPU)
			ram_dout						when s_new_vram_en  = '1'			else		-- Leitura da new VRAM (pelo canal da CPU)
			ram_dout						when ram_en         = '1'			else		-- Leitura da RAM alta
			ram_dout						when s_m1_ram_cs    = '0'			else		-- Leitura da RAM m1
			ram_dout						when s_m1_rom_cs    = '0'			else		-- Leitura da ROM m1
			-- I/O
			ula_dout						when ula_hd_s       = '1'			else		-- Leitura da porta 254
			register_data_s			when port253B_en_s  = '1'			else		-- Register read
			psg_do						when psg_dout       = '1'			else		-- Leitura da porta FFFD (AY)
			s_mouse_d 					when s_mouse_out 	  = '1' 			else		-- Leitura portas do Mouse Kempston
			"0000000" & s_lp_d0 		when s_lp_out		  = '1'			else     -- Light Pen (3F)  (tem que ser antes de divmmc_en)
			kempston_dout				when s_kj_out       = '1'			else		-- Leitura da porta Kempston (1F) (tem que ser antes de divmmc_en)
			s_m1_do				 		when s_m1_dout		  = '1'			else     -- Multiface 128
			divmmc_do					when divmmc_dout    = '1'			else		-- Leitura das portas da interface DivMMC
			"0000000" & ioRTC_sda	when port113B_en_s  = '1'			else		-- RTC SDA reading
			sprite_data_s				when sprite_hd_s    = '1'			else		-- Sprites status flag reading
			iCpu_di;

	-- Ligacao dos sinais das memorias com o mundo externo
	oVram_a		<= "101" & vram_a;
	vram_dout	<= iVram_dout;
	oVram_cs		<= vram_cs;
	oVram_rd		<= vram_oe;

	oRam_a		<= ram_addr;
	oRam_din		<= ram_din;
	ram_dout		<= iRam_dout;
	oRam_cs		<= (romram_en or vram_en or s_new_vram_en or ram_en or divmmc_ram_en or romram_wr_en or (not s_m1_ram_cs) or (not s_m1_rom_cs));
	oRam_rd		<= not cpu_rd_n;
	oRam_wr		<= not cpu_wr_n;

	-- bootrom interna
	oBootrom_en	<= bootrom_s;
	oRom_a		<= cpu_a(13 downto 0);
	rom_dout		<= iRom_dout;

	oOverlay_addr <= "010" & overlay_addr_s;

	-- port 0x123B = 4667
	-- bit 7 and 6 = new vram page selection ("00", "01" or "10")
	-- bit 5 and 4 = layers order	"00" - new vram over vram (100% magenta is transparent)
	--										"01" - vram over new vram (black with bright is transparent)
	-- bit 3 = not used
	-- bit 2 = 	"0" page selected is write only, ZX ROM visible at 0000-3FFF
	--				"1" page selected is read and write, ZX ROM is disabled
	-- bit 1 = "0" new vram not visible
	-- bit 0 = "0" new vram read and write disabled

	process(reset_s, clk_cpu)
	begin
		if reset_s = '1' then
			overlay_page_s				<= "00";
			overlay_order_s			<= "00";
			overlay_access_type_s	<= '0';
			overlay_visible_en_s		<= '0';
			overlay_access_en_s 		<= '0';

		elsif falling_edge(clk_cpu) then
			if cpu_a = X"123b" and iowr_en = '1' and use_overlay_g then
				overlay_page_s				<= cpu_do(7 downto 6);
				overlay_order_s			<= cpu_do(5 downto 4);
				overlay_access_type_s	<= cpu_do(2);
				overlay_visible_en_s		<= cpu_do(1);
				overlay_access_en_s 		<= cpu_do(0);

			end if;
		end if;
	end process;

	-- RGB
	oRGB_hs_n	<= ula_hsync_n;
	oRGB_vs_n	<= ula_vsync_n;
	oRGB_cs_n	<= ula_hsync_n and ula_vsync_n;
	oScandbl_sl	<= scandbl_sl;
	oScandbl_en	<= scandbl_en;
	oMachTiming	<= machine_timing;
	oNTSC_PAL	<= s_ntsc_pal;

	-- RGB (ULA and ULA+ mixer)
	rgb_r_s <= ula_r & (ula_i and ula_r) & (ula_i and ula_r) 	when ulaenh_en = '0' else ula_rgbenh(4 downto 2);
	rgb_g_s <= ula_g & (ula_i and ula_g) & (ula_i and ula_g) 	when ulaenh_en = '0' else ula_rgbenh(7 downto 5);
	rgb_b_s <= ula_b & (ula_i and ula_b)								when ulaenh_en = '0' else ula_rgbenh(1 downto 0);
	oRGB_hb_n	<= hblank_n_s;
	oRGB_vb_n	<= vblank_n_s;

	overlay_rgb_transp_s <= '1' when ula_r = transparency_q(1) and ula_g = transparency_q(2) and ula_b = transparency_q(0) and ula_i = transparency_q(3) else '0';

	-- overlay with tranparent 100% Magenta
--	oRGB_r <= rgb_r_s when (overlay_pixel_s = '0' and overlay_order_s = "00") or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_R_s;
--	oRGB_g <= rgb_g_s when (overlay_pixel_s = '0' and overlay_order_s = "00") or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_G_s;
--	oRGB_b <= rgb_b_s when (overlay_pixel_s = '0' and overlay_order_s = "00") or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_B_s;
--	oRGB_r <= rgb_r_s when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_R_s;
--	oRGB_g <= rgb_g_s when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_G_s;
--	oRGB_b <= rgb_b_s when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else overlay_B_s;

	oRGB_r <= (others => '0')				when hblank_n_s = '0' or vblank_n_s = '0'					else
	          sprite_RGB_s(7 downto 5)  when sprite_pixel_s = '1' and sprite_visible_q = '1'	else
	          rgb_r_s     when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else
	          overlay_R_s;

	oRGB_g <= (others => '0') 				when hblank_n_s = '0' or vblank_n_s = '0'					else
	          sprite_RGB_s(4 downto 2)  when sprite_pixel_s = '1' and sprite_visible_q = '1'	else
	          rgb_g_s     when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else
	          overlay_G_s;

	oRGB_b <= (others => '0') 				when hblank_n_s = '0' or vblank_n_s = '0'					else
	          sprite_RGB_s(1 downto 0)  when sprite_pixel_s = '1' and sprite_visible_q = '1'	else
	          rgb_b_s     when (overlay_pixel_s = '0' ) or (overlay_rgb_transp_s = '0' and overlay_order_s = "01") or overlay_visible_en_s = '0' else
	          overlay_B_s;

	-- Audio
	ula_ear	<= iEAR;
	oSPK		<= ula_spk;
	oMIC		<=	ula_mic;
	oDAC		<= s_dac;

	-- Port 254 (to keyboard reading)
	port254_cs_o	<= '1'	when cpu_ioreq_n = '0' and cpu_m1_n = '1' and cpu_rd_n = '0' and cpu_a(0) = '0'	else '0';

	-- Bus
	oCpu_a 			<= cpu_a;		--when machine /= s_config else (others => '0');
	oCpu_do 			<= cpu_do		when machine /= s_config else (others => '0');
	oCpu_ioreq 		<= cpu_ioreq_n when machine /= s_config else '1';
	oCpu_wr			<= cpu_wr_n    when machine /= s_config else '1';
	oCpu_rd			<= cpu_rd_n    when machine /= s_config else '1';
	oCpu_mreq		<= cpu_mreq_n  when machine /= s_config else '1';
	oCpu_m1			<= cpu_m1_n    when machine /= s_config else '1';
	oCpu_clock		<= clk_cpu;

	----------------------------
	-- debugs
	----------------------------

	oD_others(0) <= hardreset_q;
	oD_others(1) <= softreset_q;
	oD_others(2) <= bootrom_s;
	oD_others(3) <= turbo;
	oD_others(4) <= divmmc_rom_en;
--	oD_others(5) <= ;
--	oD_others(6) <= ;
--	oD_others(7) <= ;
	oD_reg_o	<= reg02_data_s;

end architecture;
