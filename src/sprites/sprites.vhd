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

-- PORTS:
--				0x303B(R) - Read status flag
--				0x303B(W) - select the current sprite
--				0x53 - write sprite pallete (shared for all sprites)
--				0x55 - write sprite pattern (256 bytes auto increment, use after sprite selection)
--				0x57 - write sprite attributes:
--											1st - X coordinate
--											2nd - Y coordinate
--											3rd - (MSB X coordinate,0,0,0,0, mirror X, mirror Y, visible)
--											4th - Pattern number

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sprites is
	port (
		clock_master_i	: in  std_logic;
		clock_pixel_i	: in  std_logic;
		reset_i			: in  std_logic;
		over_border_i	: in  std_logic;
		hcounter_i		: in  unsigned( 8 downto 0);
		vcounter_i		: in  unsigned( 8 downto 0);
		-- CPU
		cpu_a_i			: in  std_logic_vector(15 downto 0);
		cpu_d_i			: in  std_logic_vector( 7 downto 0);
		cpu_d_o			: out std_logic_vector( 7 downto 0);
		has_data_o		: out std_logic;
		cpu_iorq_n_i	: in  std_logic;
		cpu_rd_n_i		: in  std_logic;
		cpu_wr_n_i		: in  std_logic;
		-- Out
		rgb_o				: out std_logic_vector(7 downto 0);
		pixel_en_o		: out std_logic
	);
end entity;

architecture rtl of sprites is

	constant SPRITE_SIZE_BITS		: integer := 4;	-- 2^4 = 16
	constant TOTAL_SPRITES_BITS	: integer := 6;	-- 2^5 = 32; 2^6 = 64; 2^7 = 128
	constant SPRITES_PER_LINE_BITS: integer := 4;	-- 2^3 = 8; 2^4 = 16

	constant SPRITE_SIZE			: integer := (2 ** SPRITE_SIZE_BITS);
	constant TOTAL_SPRITES		: integer := (2 ** TOTAL_SPRITES_BITS);
--	constant SPRITES_PER_LINE	: integer := (2 ** SPRITES_PER_LINE_BITS);
	constant SPRITES_PER_LINE	: integer := 12; -- Uses 12 instead 16 (2^4)

	signal clock_mem_s			: std_logic;

	type   state_t					is (S_IDLE, S_START, S_CHKY, S_READATTR, S_READDATA);
	signal state_s					: state_t;

	type   sprite_pallete_t		is array (natural range 0 to 255) of std_logic_vector(7 downto 0);
	signal sprite_pallete_q		: sprite_pallete_t := (
											x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"0F",
											x"10",x"11",x"12",x"13",x"14",x"15",x"16",x"17",x"18",x"19",x"1A",x"1B",x"1C",x"1D",x"1E",x"1F",
											x"20",x"21",x"22",x"23",x"24",x"25",x"26",x"27",x"28",x"29",x"2A",x"2B",x"2C",x"2D",x"2E",x"2F",
											x"30",x"31",x"32",x"33",x"34",x"35",x"36",x"37",x"38",x"39",x"3A",x"3B",x"3C",x"3D",x"3E",x"3F",
											x"40",x"41",x"42",x"43",x"44",x"45",x"46",x"47",x"48",x"49",x"4A",x"4B",x"4C",x"4D",x"4E",x"4F",
											x"50",x"51",x"52",x"53",x"54",x"55",x"56",x"57",x"58",x"59",x"5A",x"5B",x"5C",x"5D",x"5E",x"5F",
											x"60",x"61",x"62",x"63",x"64",x"65",x"66",x"67",x"68",x"69",x"6A",x"6B",x"6C",x"6D",x"6E",x"6F",
											x"70",x"71",x"72",x"73",x"74",x"75",x"76",x"77",x"78",x"79",x"7A",x"7B",x"7C",x"7D",x"7E",x"7F",
											x"80",x"81",x"82",x"83",x"84",x"85",x"86",x"87",x"88",x"89",x"8A",x"8B",x"8C",x"8D",x"8E",x"8F",
											x"90",x"91",x"92",x"93",x"94",x"95",x"96",x"97",x"98",x"99",x"9A",x"9B",x"9C",x"9D",x"9E",x"9F",
											x"A0",x"A1",x"A2",x"A3",x"A4",x"A5",x"A6",x"A7",x"A8",x"A9",x"AA",x"AB",x"AC",x"AD",x"AE",x"AF",
											x"B0",x"B1",x"B2",x"B3",x"B4",x"B5",x"B6",x"B7",x"B8",x"B9",x"BA",x"BB",x"BC",x"BD",x"BE",x"BF",
											x"C0",x"C1",x"C2",x"C3",x"C4",x"C5",x"C6",x"C7",x"C8",x"C9",x"CA",x"CB",x"CC",x"CD",x"CE",x"CF",
											x"D0",x"D1",x"D2",x"D3",x"D4",x"D5",x"D6",x"D7",x"D8",x"D9",x"DA",x"DB",x"DC",x"DD",x"DE",x"DF",
											x"E0",x"E1",x"E2",x"E3",x"E4",x"E5",x"E6",x"E7",x"E8",x"E9",x"EA",x"EB",x"EC",x"ED",x"EE",x"EF",
											x"F0",x"F1",x"F2",x"F3",x"F4",x"F5",x"F6",x"F7",x"F8",x"F9",x"FA",x"FB",x"FC",x"FD",x"FE",x"FF"
	);

	type   sprite_xpos_t			is array (natural range 0 to (SPRITES_PER_LINE-1)) of std_logic_vector(8 downto 0);
	signal sprite_xpos_q			: sprite_xpos_t;

	type   sprite_paddr_t		is array (natural range 0 to (SPRITES_PER_LINE-1)) of std_logic_vector((SPRITE_SIZE_BITS-1) downto 0);
	signal sprite_paddr_q		: sprite_paddr_t;

	type   sprite_pwe_t			is array (natural range 0 to (SPRITES_PER_LINE-1)) of std_logic;
	signal sprite_pwe_q			: sprite_pwe_t;

	type   sprite_pdata_t		is array (natural range 0 to (SPRITES_PER_LINE-1)) of std_logic_vector(7 downto 0);
	signal sprite_pdi_q			: sprite_pdata_t;
	signal sprite_pdo_q			: sprite_pdata_t;

	signal sprite_idx_q			: unsigned((TOTAL_SPRITES_BITS) downto 0)					:= (others => '0');
	signal sprite_cnt_q			: unsigned((SPRITES_PER_LINE_BITS+1) downto 0)			:= (others => '0');

	signal addr_pall_s			: unsigned(7 downto 0)											:= (others => '0');

	signal addr_attr_s			: std_logic_vector((TOTAL_SPRITES_BITS+1) downto 0)	:= (others => '0');
	signal data_attr_s			: std_logic_vector( 7 downto 0)								:= (others => '0');
	signal addr_pat_s				: std_logic_vector((TOTAL_SPRITES_BITS+7) downto 0)	:= (others => '0');
	signal data_pat_s				: std_logic_vector( 7 downto 0)								:= (others => '0');
	signal addr_cpl_s				: std_logic_vector( 1 downto 0)								:= (others => '0');
	signal addr_pat_w_s			: std_logic_vector((SPRITE_SIZE_BITS-1) downto 0)		:= (others => '0');

	signal sprite_saida_s		: std_logic_vector(7 downto 0) :=  "11100011";
	signal pixel_en_s				: std_logic;

	signal port303b_w_en_s		: std_logic := '0';
	signal port303b_r_en_s		: std_logic := '0';
	signal port53_en_s			: std_logic := '0';
	signal port55_en_s			: std_logic := '0';
	signal port57_en_s			: std_logic := '0';

	signal pat_data_pointer_s	: std_logic_vector((TOTAL_SPRITES_BITS+7) downto 0)	:= (others=>'0');
	signal pat_write_en_s		: std_logic															:= '0';

	signal attr_data_pointer_s	: std_logic_vector((TOTAL_SPRITES_BITS+1) downto 0)	:= (others=>'0');
	signal attr_write_en_s		: std_logic															:= '0';

	signal spt_maxl_s				: std_logic															:= '0';
	signal spt_maxl_q				: std_logic															:= '0';
	signal spt_coll_s				: std_logic															:= '0';
	signal spt_coll_q				: std_logic															:= '0';
	signal status_reg_s			: std_logic_vector( 7 downto 0);

	-- debug
	signal D_screen_y_v			: signed(9 downto 0);
	signal D_screen_y_spt_v		: unsigned(8 downto 0);
	signal D_screen_y_dif_v		: unsigned(8 downto 0);

begin

	clock_mem_s <= not clock_master_i;

	attr: entity work.dpram
	generic map (
		addr_width_g => (TOTAL_SPRITES_BITS+2),
		data_width_g => 8
	)
	port map (
		clk_a_i  => clock_mem_s,
		we_i     => attr_write_en_s,
		addr_a_i => attr_data_pointer_s,
		data_a_i => cpu_d_i,
		--
		clk_b_i  => clock_mem_s,
		addr_b_i => addr_attr_s,
		data_b_o => data_attr_s
	);

	pat: entity work.dpram
	generic map (
		addr_width_g => (TOTAL_SPRITES_BITS+8),
		data_width_g => 8
	)
	port map (
		clk_a_i  => clock_mem_s,
		we_i     => pat_write_en_s,
		addr_a_i => pat_data_pointer_s,
		data_a_i => cpu_d_i,
		--
		clk_b_i  => clock_mem_s,
		addr_b_i => addr_pat_s,
		data_b_o => data_pat_s
	);

	rps: for idx in 0 to (SPRITES_PER_LINE-1) generate

		lpat: entity work.spram
		generic map (
			addr_width_g	=> SPRITE_SIZE_BITS,
			data_width_g	=> 8
		)
		port map (
			clk_i		=> clock_mem_s,
			we_i		=> sprite_pwe_q(idx),
			addr_i	=> sprite_paddr_q(idx),
			data_i	=> sprite_pdi_q(idx),
			data_o	=> sprite_pdo_q(idx)
		);

	end generate;

	port303b_r_en_s 	<= '1' when cpu_iorq_n_i = '0' and cpu_rd_n_i = '0' and cpu_a_i = X"303B"				else '0';
	port303b_w_en_s 	<= '1' when cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_a_i = X"303B"				else '0';
	port53_en_s 		<= '1' when cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_a_i(7 downto 0) = X"53"	else '0';	-- only write
	port55_en_s 		<= '1' when cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_a_i(7 downto 0) = X"55"	else '0';	-- only write
	port57_en_s 		<= '1' when cpu_iorq_n_i = '0' and cpu_wr_n_i = '0' and cpu_a_i(7 downto 0) = X"57"	else '0';	-- only write

	status_reg_s <= "000000" & spt_maxl_q & spt_coll_q;

	has_data_o	<= '1' when port303b_r_en_s = '1' else
						'0';

	cpu_d_o		<= status_reg_s when port303b_r_en_s = '1' else
						(others => '0');

	process (clock_master_i)
		variable clkp303b_r_e_v	: std_logic_vector( 1 downto 0);
		variable clkp303b_w_e_v	: std_logic_vector( 1 downto 0);
		variable clkp53_e_v		: std_logic_vector( 1 downto 0);
		variable clkp55_e_v		: std_logic_vector( 1 downto 0);
		variable clkp57_e_v		: std_logic_vector( 1 downto 0);
		variable attr_d_p_v		: std_logic_vector((TOTAL_SPRITES_BITS+1) downto 0);
	begin
		
		if rising_edge(clock_master_i) then
	
			clkp303b_w_e_v	:= clkp303b_w_e_v(0) & port303b_w_en_s;
			clkp303b_r_e_v	:= clkp303b_r_e_v(0) & port303b_r_en_s;
			clkp53_e_v 		:= clkp53_e_v(0) & port53_en_s;
			clkp55_e_v 		:= clkp55_e_v(0) & port55_en_s;
			clkp57_e_v 		:= clkp57_e_v(0) & port57_en_s;
	
			if reset_i = '1' then
				attr_d_p_v				:= (others => '0');
				addr_pall_s				<= (others => '0');
				pat_data_pointer_s	<= (others => '0');
				pat_write_en_s			<= '0';
				attr_write_en_s		<= '0';
			end if;
		
			if clkp303b_w_e_v = "01" then --rising_edge(port303b_w_en_s)
				addr_pall_s <= (others => '0');
				if unsigned(cpu_d_i) < TOTAL_SPRITES then
					attr_d_p_v				:= cpu_d_i((TOTAL_SPRITES_BITS-1) downto 0) & "00";
					pat_data_pointer_s	<= cpu_d_i((TOTAL_SPRITES_BITS-1) downto 0) & "00000000";
				end if;
			end if;

			-- write pallete
			if clkp53_e_v = "01" then -- rising_edge(port53_en_s)
				sprite_pallete_q(to_integer(addr_pall_s)) <= cpu_d_i;
				addr_pall_s <= addr_pall_s + 1;
			end if;

			-- write pattern
			if clkp55_e_v = "01" then -- rising_edge(port55_en_s)
				pat_write_en_s			<= '1';
			else
				pat_write_en_s			<= '0';
			end if;

			if pat_write_en_s = '1' then
				pat_data_pointer_s	<= pat_data_pointer_s + 1;
			end if;

			attr_data_pointer_s <= attr_d_p_v((TOTAL_SPRITES_BITS+1) downto 1) & not attr_d_p_v(0);

			-- write attributes
			if clkp57_e_v = "01" then -- rising_edge(port57_en_s)
				attr_write_en_s		<= '1';
			else
				attr_write_en_s		<= '0';
			end if;

			if attr_write_en_s = '1' then
				attr_d_p_v	:= attr_d_p_v + 1;
 			end if;

			-- Max sprites per line
			if spt_maxl_s = '1' then
				spt_maxl_q <= '1';
			elsif clkp303b_r_e_v = "10" then			-- CPU finished read
				spt_maxl_q <= '0';						-- Status destructive flag
			end if;
			
			-- Sprite Collision
			if spt_coll_s = '1' then
				spt_coll_q <= '1';
			elsif clkp303b_r_e_v = "10" then			-- CPU finished read
				spt_coll_q <= '0';						-- Status destructive flag
			end if;
		end if;
		
	end process;


	addr_attr_s		<= std_logic_vector(sprite_idx_q((TOTAL_SPRITES_BITS-1) downto 0)) & addr_cpl_s;

	-- Test Y from sprites
	process (clock_master_i)
		variable screen_y_v			: signed(9 downto 0);
		variable screen_y_spt_v		: unsigned(8 downto 0);
		variable screen_y_dif_v		: unsigned(8 downto 0);
		variable spt_name_v			: std_logic_vector((TOTAL_SPRITES_BITS-1) downto 0);
		variable spt_opts_v			: std_logic_vector(7 downto 0);
		variable counter_v			: unsigned(SPRITE_SIZE_BITS downto 0);
		variable st_mirror_x_v		: std_logic_vector((SPRITE_SIZE_BITS-1) downto 0);
		variable spt_palidx_v		: unsigned(7 downto 0);
	begin
		if rising_edge(clock_master_i) then
			screen_y_v := signed('0' & vcounter_i) - 1;
			spt_maxl_s <= '0';

			if hcounter_i > 319 and screen_y_v < 256 then

				if state_s = S_START then												-- zeroing

					addr_cpl_s <= "00";
					sprite_xpos_q(to_integer(sprite_cnt_q)) <= (others => '1');
					sprite_pwe_q(to_integer(sprite_cnt_q)) <= '0';

					sprite_cnt_q <= sprite_cnt_q + 1;
					if sprite_cnt_q = (SPRITES_PER_LINE-1) then
						state_s <= S_CHKY;
						sprite_cnt_q <= (others => '0');
					end if;

				elsif state_s = S_CHKY then

					addr_cpl_s	<= "00";
					if vcounter_i >= unsigned(data_attr_s) and vcounter_i < (unsigned('0' & data_attr_s)+SPRITE_SIZE) then
						--
						screen_y_spt_v	:= unsigned('0' & data_attr_s);
						state_s <= S_READATTR;
						addr_cpl_s <= addr_cpl_s + 1;
					else
						sprite_idx_q <= sprite_idx_q + 1;
					end if;
					if sprite_cnt_q = SPRITES_PER_LINE then
						spt_maxl_s	<= '1';
						state_s		<= S_IDLE;
					end if;
					if sprite_idx_q = TOTAL_SPRITES then
						state_s		<= S_IDLE;
					end if;

				elsif state_s = S_READATTR then

					case addr_cpl_s is
						when "01" =>
							sprite_xpos_q(to_integer(sprite_cnt_q)) <= '0' & data_attr_s;
						when "10" =>
							spt_name_v := data_attr_s((TOTAL_SPRITES_BITS-1) downto 0);
						when "11" =>
							spt_opts_v := data_attr_s(7 downto 0);
							if spt_opts_v(1) = '1' then											-- if visible
								sprite_xpos_q(to_integer(sprite_cnt_q))(8) <= spt_opts_v(0);
								state_s <= S_READDATA;
								if spt_opts_v(2) = '1' then										-- mirror Y
									screen_y_dif_v := (SPRITE_SIZE-1) - (vcounter_i - screen_y_spt_v);
								else
									screen_y_dif_v := vcounter_i - screen_y_spt_v;
								end if;
								if spt_opts_v(3) = '1' then										-- mirror X
									st_mirror_x_v := "1111";
								else
									st_mirror_x_v := "0000";
								end if;
								addr_pat_s <= spt_name_v &	std_logic_vector(screen_y_dif_v((SPRITE_SIZE_BITS-1) downto 0)) & st_mirror_x_v;
								addr_pat_w_s <= (others => '0');
								sprite_pwe_q(to_integer(sprite_cnt_q)) <= '1';
								counter_v := (others => '0');
							else
								state_s <= S_CHKY;
								sprite_idx_q <= sprite_idx_q + 1;
								sprite_xpos_q(to_integer(sprite_cnt_q)) <= (others => '1');
							end if;
						when others =>
							null;
					end case;
					addr_cpl_s <= addr_cpl_s + 1;

				elsif state_s = S_READDATA then

					spt_palidx_v := (unsigned(data_pat_s(7 downto 4)) + unsigned(spt_opts_v(7 downto 4))) & unsigned(data_pat_s(3 downto 0));
					sprite_pdi_q(to_integer(sprite_cnt_q)) <= sprite_pallete_q(to_integer(spt_palidx_v));
					if spt_opts_v(2) = '1' then										-- mirror X
						addr_pat_s <= addr_pat_s - 1;
					else
						addr_pat_s <= addr_pat_s + 1;
					end if;
					addr_pat_w_s <= addr_pat_w_s + 1;
					if counter_v = SPRITE_SIZE then
						sprite_pwe_q(to_integer(sprite_cnt_q)) <= '0';
						state_s <= S_CHKY;
						sprite_idx_q <= sprite_idx_q + 1;
						sprite_cnt_q <= sprite_cnt_q + 1;
					end if;
					counter_v := counter_v + 1;

				end if;

			else
				sprite_idx_q <= (others => '0');
				sprite_cnt_q <= (others => '0');
				state_s			<= S_START;
			end if;

			D_screen_y_v		<= screen_y_v;
			D_screen_y_spt_v	<= screen_y_spt_v;
			D_screen_y_dif_v	<= screen_y_dif_v;
		end if;
	end process;

	--
	process (clock_master_i)
		variable diffx_v		: std_logic_vector(8 downto 0);
	begin
		if rising_edge(clock_master_i) then
			for idx in 0 to (SPRITES_PER_LINE-1) loop
				if sprite_pwe_q(idx) = '1' then
					sprite_paddr_q(idx) <= addr_pat_w_s;
				else
					if hcounter_i >= unsigned(sprite_xpos_q(idx)) and hcounter_i < (unsigned(sprite_xpos_q(idx))+SPRITE_SIZE) then
						diffx_v := std_logic_vector(hcounter_i - unsigned(sprite_xpos_q(idx)));
						sprite_paddr_q(idx) <= diffx_v((SPRITE_SIZE_BITS-1) downto 0);
					else
						sprite_paddr_q(idx) <= (others => '0');
					end if;
				end if;
			end loop;
		end if;
	end process;

	--
	process (clock_pixel_i)
		variable pat_data_v		: std_logic_vector(7 downto 0);
		variable spt_col_cnt_v	: unsigned(SPRITES_PER_LINE_BITS downto 0);
		variable x_s_v				: unsigned(8 downto 0);
		variable x_e_v				: unsigned(8 downto 0);
		variable y_s_v				: unsigned(8 downto 0);
		variable y_e_v				: unsigned(8 downto 0);
	begin
		if rising_edge(clock_pixel_i) then
			sprite_saida_s <= "11100011";
			pat_data_v := "11100011";
			pixel_en_s <= '0';
			spt_col_cnt_v := (others => '0');
			spt_coll_s <= '0';
			if over_border_i = '1' then
				x_s_v := to_unsigned(0,   9);
				x_e_v := to_unsigned(320, 9);
				y_s_v := to_unsigned(0,   9);
				y_e_v := to_unsigned(257, 9);
			else
				x_s_v := to_unsigned(31,  9);
				x_e_v := to_unsigned(288, 9);		-- 320 - 32
				y_s_v := to_unsigned(32,  9);
				y_e_v := to_unsigned(225, 9);		-- 257 - 32
			end if;

--			if vcounter_i > 0 and vcounter_i < 257 and hcounter_i > 0 and hcounter_i < 320 then
			if vcounter_i > y_s_v and vcounter_i < y_e_v and hcounter_i > x_s_v and hcounter_i < x_e_v then
				for idx in 0 to (SPRITES_PER_LINE-1) loop
					if hcounter_i >= unsigned(sprite_xpos_q(idx)) and hcounter_i < (unsigned(sprite_xpos_q(idx))+SPRITE_SIZE) then
						pat_data_v := sprite_pdo_q(idx);
						if pat_data_v /= "11100011" then
							spt_col_cnt_v := spt_col_cnt_v + 1;
							pixel_en_s <= '1';
							sprite_saida_s <= pat_data_v;
						end if;
					end if;
				end loop;
			end if;
			if spt_col_cnt_v > 1 then
				spt_coll_s <= '1';
			end if;
		end if;
	end process;

	rgb_o <= sprite_saida_s;
	pixel_en_o <= pixel_en_s;

end architecture;