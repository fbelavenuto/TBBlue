--
-- TBBlue / ZX Spectrum Next project
--
-- -----------------------------------------------------------------------
--
--                                 FPGA 64
--
--     A fully functional commodore 64 implementation in a single FPGA
--
-- -----------------------------------------------------------------------
--
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
-- Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
-- -----------------------------------------------------------------------
--
-- fpga64_scandoubler.vhd
--
-- -----------------------------------------------------------------------
--
-- Converts 15.6 Khz PAL/NTSC screen to 31 Khz VGA screen by doubling
-- each scanline.
--
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity scandoubler is
	generic (
		hSyncLength : integer := 31;
		vSyncLength	: integer := 31;
		ramBits		: integer := 11
	);
	port (
		clk				: in    std_logic;
		hSyncPolarity	: in    std_logic := '0';
		vSyncPolarity	: in    std_logic := '0';
		enable_in		: in    std_logic;
		scanlines_in	: in    std_logic := '0';
		video_in			: in    std_logic_vector(7 downto 0);
		vsync_in			: in    std_logic;
		hsync_in			: in    std_logic;
		video_out		: out   std_logic_vector(7 downto 0);
		vsync_out		: out   std_logic;
		hsync_out		: out   std_logic;
		blank_o			: out   std_logic
	);
end scandoubler;

architecture rtl of scandoubler is

--	constant hSyncLength : integer := 31;
	constant lineLengthBits : integer := 11;

	signal prescale		: unsigned(0 downto 0);
	signal impar			: std_logic;
	signal impar_15		: std_logic := '0';
	signal blank_s			: std_logic := '0';
	
	signal startIndex		: unsigned((ramBits-1) downto 0) := (others => '0');
	signal endIndex		: unsigned((ramBits-1) downto 0) := (others => '0');
	signal readIndex		: unsigned((ramBits-1) downto 0) := (others => '0');
	signal writeIndex 	: unsigned((ramBits-1) downto 0) := (others => '0');
	signal oldHSync		: std_logic             := '0';
	signal oldVSync		: std_logic             := '0';
	signal hSyncCount		: integer range 0 to hSyncLength;
	signal vSyncCount		: integer range 0 to vSyncLength;
	signal lineLength		: unsigned(lineLengthBits downto 0);
	signal lineLengthCnt	: unsigned((lineLengthBits+1) downto 0);
	signal nextLengthCnt	: unsigned((lineLengthBits+1) downto 0);

	signal ramD          : unsigned(7 downto 0);
	signal ramQ          : unsigned(7 downto 0);
	signal ramQReg       : unsigned(7 downto 0);
	signal video_r_s		: unsigned(2 downto 0);
	signal video_g_s		: unsigned(2 downto 0);
	signal video_b_s		: unsigned(1 downto 0);

begin

	lineRam: entity work.dpram
	generic map (
		addr_width_g => ramBits,
		data_width_g => 8
	)
	port map (
		clk_a_i  				=> clk,
		we_i     				=> '1',
		addr_a_i 				=> std_logic_vector(writeIndex),
		data_a_i 				=> std_logic_vector(ramD),
		clk_b_i  				=> clk,
		addr_b_i 				=> std_logic_vector(readIndex),
		unsigned(data_b_o)	=> ramQ
	);

	ramD <= unsigned(video_in);
	nextLengthCnt <= lineLengthCnt + 1;

	process(clk)
	begin
		if rising_edge(clk) then
				prescale <= prescale + 1;
				lineLengthCnt <= nextLengthCnt;

				if prescale(0) = '0' and hsync_in = '1' then
					if enable_in = '1' then
						writeIndex <= writeIndex + 1;
					end if;
				end if;

				if hSyncCount /= 0 then
					hSyncCount <= hSyncCount - 1;
				end if;

				if hSyncCount = 0 then
					readIndex <= readIndex + 1;
				end if;

				if lineLengthCnt = lineLength then
					readIndex <= startIndex;
					hSyncCount <= hSyncLength;
					prescale <= (others => '0');
					impar <= '1';
				end if;
				

				oldHSync <= hsync_in;
				if (oldHSync = '1') and (hsync_in = '0') then
					-- Calculate length of the scanline/2
					-- The scandoubler adds a second sync half way to double the lines.
					lineLength <= lineLengthCnt((lineLengthBits+1) downto 1);
					lineLengthCnt <= to_unsigned(0, lineLengthBits+2);

					readIndex   <= endIndex;
					startIndex  <= endIndex;
					endIndex    <= writeIndex;
					hSyncCount  <= hSyncLength;
					prescale    <= (others => '0');
					impar			<= '0';

					oldVSync <= vsync_in;
					if (vsync_in = '1') and (oldVSync = '0') then
						vSyncCount <= vSyncLength;
					elsif vSyncCount /= 0 then
						vSyncCount <= vSyncCount - 1;
					end if;
				end if;
			end if;
	end process;
	
	process(hsync_in,vsync_in)
	begin
		if falling_edge(hsync_in) then
			impar_15	 <= not impar_15 and vsync_in;
		end if;
	end process;

	-- Video out
	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				ramQReg   <= ramQ;
				--video_out <= std_logic_vector(ramQReg);
				video_r_s <= ramQReg(7 downto 5);
				video_g_s <= ramQReg(4 downto 2);
				video_b_s <= ramQReg(1 downto 0);
				blank_s <= '0';
				if vSyncCount /= 0 then 
					video_r_s <= (others => '0');
					video_g_s <= (others => '0');
					video_b_s <= (others => '0');
					blank_s <= '1';
				elsif (scanlines_in = '1' and impar = '1') then
					--if ramQReg(7 downto 5) > 1 then video_r_s <= ramQReg(7 downto 5) - 2; end if;
					--if ramQReg(4 downto 2) > 1 then video_g_s <= ramQReg(4 downto 2) - 2; end if;
					--if ramQReg(1 downto 0) > 1 then video_b_s <= ramQReg(1 downto 0) - 2; end if;
					video_r_s <= '0' & ramQReg(7 downto 6);
					video_g_s <= '0' & ramQReg(4 downto 3);
					video_b_s <= '0' & ramQReg(1);
				end if;
				video_out <= std_logic_vector(video_r_s & video_g_s & video_b_s);
			else
				video_r_s	<= unsigned(video_in(7 downto 5));
				video_g_s	<= unsigned(video_in(4 downto 2));
				video_b_s	<= unsigned(video_in(1 downto 0));
				if (scanlines_in = '1' and impar_15 = '1') then
					if unsigned(video_in(7 downto 5)) > 0 then video_r_s	<= unsigned(video_in(7 downto 5)) - 1; end if;
					if unsigned(video_in(4 downto 2)) > 0 then video_g_s	<= unsigned(video_in(4 downto 2)) - 1; end if;
					if unsigned(video_in(1 downto 0)) > 0 then video_b_s	<= unsigned(video_in(1 downto 0)) - 1; end if;
				end if;
				video_out <= std_logic_vector(video_r_s & video_g_s & video_b_s);
			end if;
		end if;
	end process;

	-- Horizontal sync
	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				hsync_out  <= not hSyncPolarity;
				if hSyncCount /= 0 then
					hsync_out <= hSyncPolarity;
				end if;
			else
				hsync_out <= hsync_in;
			end if;
		end if;
	end process;

	-- Vertical sync
	process(clk)
	begin
		if rising_edge(clk) then
			if enable_in = '1' then
				vsync_out <= not vSyncPolarity;
				if (vSyncCount = 9) or (vSyncCount = 10) then
					vsync_out <= vSyncPolarity;
				end if;
			else
				vsync_out <= vsync_in;
			end if;
		end if;
	end process;
	
	blank_o <= blank_s;

end architecture;
