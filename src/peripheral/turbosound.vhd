--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity turbosound is
	generic (
		use_sid_g				: boolean					:= false
	);
	port (
		clk						: in    std_logic;  -- Clock alto (> 6 MHz)
		clk_psg					: in    std_logic;  -- Sinal de clock de 1.75 MHz
		rst_n						: in    std_logic;
		cpu_a						: in    std_logic_vector(15 downto 0);
		cpu_di					: in    std_logic_vector( 7 downto 0);
		cpu_do					: out   std_logic_vector( 7 downto 0);
		cpu_iorq_n				: in    std_logic;
		cpu_rd_n					: in    std_logic;
		cpu_wr_n					: in    std_logic;
		cpu_m1_n					: in    std_logic;

		-- audio
		audio_psg_L_o			: out   unsigned( 7 downto 0);
		audio_psg_R_o			: out   unsigned( 7 downto 0);
		audio_sid_L_o			: out   unsigned(17 downto 0)					:= (others => '0');
		audio_sid_R_o			: out   unsigned(17 downto 0)					:= (others => '0');
		
		-- controles
		enable					: in    std_logic; 	-- "1" enable first AY 
		enable_turbosound		: in    std_logic; 	-- "1" enable second AY 
		turbosound_out 		: out   std_logic;  	-- "1" if we have data to collect 
		ctrl_aymode				: in    std_logic; 	-- 0 = YM, 1 = AY
		stereo_mode				: in 	  std_logic		:= '0'; -- 0 = ABC, 1 = ACB 

		-- Serial
		rs232_rx					: in    std_logic		:= '0';
		rs232_tx					: out   std_logic;
		rs232_cts				: out   std_logic;
		rs232_dtr				: in    std_logic		:= '0'
	);
end turbosound;

architecture turbosound_arch of turbosound is

	signal reset_s					: std_logic;

	signal psg_do1					: std_logic_vector(7 downto 0)	:= "11111111";
	signal psg_do2					: std_logic_vector(7 downto 0)	:= "11111111";                      
	signal psg_do3					: std_logic_vector(7 downto 0)	:= "11111111";                      
	signal nsid_do_s				: std_logic_vector(7 downto 0)	:= "11111111";                      

	signal psg_out1 				: std_logic := '0';
	signal psg_out2 				: std_logic := '0';
	signal psg_out3 				: std_logic := '0';

	signal psg_sel1 				: std_logic := '0';
	signal psg_sel2 				: std_logic := '0';
	signal psg_sel3 				: std_logic := '0';
	 
	signal psg_BDIR				: std_logic;		
	signal psg_BC1					: std_logic;		

	signal out_audio_mix1_L		: unsigned(7 downto 0);
	signal out_audio_mix2_L		: unsigned(7 downto 0);
	signal out_audio_mix3_L		: unsigned(7 downto 0);

	signal out_audio_mix1_R		: unsigned(7 downto 0);
	signal out_audio_mix2_R		: unsigned(7 downto 0);
	signal out_audio_mix3_R		: unsigned(7 downto 0);

	signal out_audio_mix_l_s	: unsigned(9 downto 0);
	signal out_audio_mix_r_s	: unsigned(9 downto 0);

	signal out_audio_A1 			: std_logic_vector(7 downto 0);
	signal out_audio_B1 			: std_logic_vector(7 downto 0);
	signal out_audio_C1 			: std_logic_vector(7 downto 0);

	signal out_audio_A2 			: std_logic_vector(7 downto 0);
	signal out_audio_B2 			: std_logic_vector(7 downto 0);
	signal out_audio_C2 			: std_logic_vector(7 downto 0);
	
	signal out_audio_A3 			: std_logic_vector(7 downto 0);
	signal out_audio_B3 			: std_logic_vector(7 downto 0);
	signal out_audio_C3 			: std_logic_vector(7 downto 0);

	signal ay_select 				: std_logic_vector(1 downto 0) := "11";

	-- SID
	signal nsid_cs_s				: std_logic;
	signal nsid_addr_s			: std_logic;
	signal nsid_wr_s				: std_logic;
	signal nsid_hd_s				: std_logic;
	signal audio_sid_s			: unsigned(17 downto 0)					:= (others => '0');

	-- PAN
	signal pan1_s					: std_logic_vector(1 downto 0);
	signal pan2_s					: std_logic_vector(1 downto 0);
	signal pan3_s					: std_logic_vector(1 downto 0);
	signal pan4_s					: std_logic_vector(1 downto 0);
	signal audioL_1_s 			: std_logic_vector(7 downto 0);
	signal audioL_2_s 			: std_logic_vector(7 downto 0);
	signal audioL_3_s 			: std_logic_vector(7 downto 0);
	signal audioL_4_s 			: std_logic_vector(7 downto 0);
	signal audioR_1_s 			: std_logic_vector(7 downto 0);
	signal audioR_2_s 			: std_logic_vector(7 downto 0);
	signal audioR_3_s 			: std_logic_vector(7 downto 0);
	signal audioR_4_s 			: std_logic_vector(7 downto 0);


begin

	psg : entity work.explorer
	port map (
		clk					=> clk,
		clk_psg				=> clk_psg,
		rst_n					=> rst_n,
		cpu_a 				=> cpu_a,
		cpu_di				=> cpu_di,
		cpu_do				=> psg_do1,

		cpu_iorq_n			=> cpu_iorq_n,
		cpu_rd_n				=> cpu_rd_n,
		cpu_wr_n				=> cpu_wr_n,
		cpu_m1_n				=> cpu_m1_n,

		out_audio_A			=> open,
		out_audio_B			=> open,
		out_audio_C			=> open,
		out_audio_mix_L	=> out_audio_mix1_L,
		out_audio_mix_R	=> out_audio_mix1_R,

		enable				=> enable,
		selected				=> psg_sel1,
		psg_out 				=> psg_out1,
		ctrl_aymode			=> ctrl_aymode,
		stereo_mode			=> stereo_mode,

		BDIR					=>	open,
		BC1					=> open,
		-- Serial
		rs232_rx				=> rs232_rx,
		rs232_tx				=> rs232_tx,
		rs232_cts			=> rs232_cts,
		rs232_dtr			=> rs232_dtr
	);

	psg2 : entity work.explorer
	port map (
		clk					=> clk,
		clk_psg				=> clk_psg,
		rst_n					=> rst_n,
		cpu_a 				=> cpu_a,
		cpu_di				=> cpu_di,
		cpu_do				=> psg_do2,

		cpu_iorq_n			=> cpu_iorq_n,
		cpu_rd_n				=> cpu_rd_n,
		cpu_wr_n				=> cpu_wr_n,
		cpu_m1_n				=> cpu_m1_n,

		out_audio_A			=> open,
		out_audio_B			=> open,
		out_audio_C			=> open,
		out_audio_mix_L	=> out_audio_mix2_L,
		out_audio_mix_R	=> out_audio_mix2_R,

		enable				=> enable,
		selected				=> psg_sel2,
		psg_out 				=> psg_out2,
		ctrl_aymode			=> ctrl_aymode,
		stereo_mode			=> stereo_mode,

		BDIR					=>	open,
		BC1					=> open
	);

	psg3 : entity work.explorer
	port map (
		clk					=> clk,
		clk_psg				=> clk_psg,
		rst_n					=> rst_n,
		cpu_a 				=> cpu_a,
		cpu_di				=> cpu_di,
		cpu_do				=> psg_do3,

		cpu_iorq_n			=> cpu_iorq_n,
		cpu_rd_n				=> cpu_rd_n,
		cpu_wr_n				=> cpu_wr_n,
		cpu_m1_n				=> cpu_m1_n,

		out_audio_A			=> open,
		out_audio_B			=> open,
		out_audio_C			=> open,
		out_audio_mix_L	=> out_audio_mix3_L,
		out_audio_mix_R	=> out_audio_mix3_R,

		enable				=> enable,
		selected				=> psg_sel3,
		psg_out 				=> psg_out3,
		ctrl_aymode			=> ctrl_aymode,
		stereo_mode			=> stereo_mode,

		BDIR					=>	open,
		BC1					=> open
	);

	
	ifsid : if use_sid_g generate
	nextsid: entity work.NextSID
	generic map (
		clock_in_mhz_g => 28
	)
	port map (
		clock_i		=> clk,
		reset_i		=> reset_s,
		-- CPU
		addr_i		=> nsid_addr_s,
		cs_i			=> nsid_cs_s,
		wr_i			=> nsid_wr_s,
		data_i		=> cpu_di,
		data_o		=> nsid_do_s,
		has_data_o	=> nsid_hd_s,
		--
		audio_o		=> audio_sid_s
	);
	end generate;
	
	ifnsid : if not use_sid_g generate
		nsid_do_s <= (others=>'0');
		nsid_hd_s <= '0';
	end generate;

	-- Glue

	reset_s <= not rst_n;

	process (clk)
	begin
		if rising_edge(clk) then
			if (rst_n = '0') then
				ay_select 	<= "11";
				pan1_s		<= "11";
				pan2_s		<= "11";
				pan3_s		<= "11";
				pan4_s		<= "11";
			elsif (enable = '1' and enable_turbosound = '1' and psg_BDIR = '1' and psg_BC1 = '1' and cpu_di(7) = '1' and cpu_di(4 downto 2) = "111") then -- 1XX111
				ay_select <= cpu_di(1 downto 0);  
				
				case cpu_di(1 downto 0) is
					when "11" => pan1_s <= cpu_di(6 downto 5); --L and R channels  
					when "10" => pan2_s <= cpu_di(6 downto 5); --L and R channels  
					when "01" => pan3_s <= cpu_di(6 downto 5); --L and R channels  
					when "00" => pan4_s <= cpu_di(6 downto 5); --L and R channels  
					when others =>	null;
				end case;
					
			end if;
		end if;
	end process;

	
	psg_BDIR <= '1' when enable = '1' and cpu_iorq_n = '0' and cpu_m1_n = '1' and cpu_a(15) = '1' 				and cpu_a(2 downto 0) = "101" and cpu_wr_n = '0' else '0';
	psg_BC1  <= '1' when enable = '1' and cpu_iorq_n = '0' and cpu_m1_n = '1' and cpu_a(15 downto 14) = "11" and cpu_a(2 downto 0) = "101" else '0';

	-- Saida dos dados para o barramento caso a interface estiver sendo lida
	cpu_do <=  psg_do1	when psg_out1 = '1'	and ay_select = "11" else			-- read port FFFD
			     psg_do2	when psg_out2 = '1'	and ay_select = "10" else			-- read port FFFD
				  psg_do3	when psg_out3 = '1'	and ay_select = "01" else			-- read port FFFD
				  nsid_do_s	when nsid_hd_s = '1' and ay_select = "00" else			-- read SID port BFFD
				 (others => 'Z');
	
	turbosound_out <= psg_out1 or psg_out2 or psg_out3;
	
	audioL_1_s <= std_logic_vector(out_audio_mix1_L) when pan1_s(0) = '1' else (others=>'0');
	audioL_2_s <= std_logic_vector(out_audio_mix2_L) when pan2_s(0) = '1' else (others=>'0');
	audioL_3_s <= std_logic_vector(out_audio_mix3_L) when pan3_s(0) = '1' else (others=>'0');

	audioR_1_s <= std_logic_vector(out_audio_mix1_R) when pan1_s(1) = '1' else (others=>'0');
	audioR_2_s <= std_logic_vector(out_audio_mix2_R) when pan2_s(1) = '1' else (others=>'0');
	audioR_3_s <= std_logic_vector(out_audio_mix3_R) when pan3_s(1) = '1' else (others=>'0');

	out_audio_mix_l_s <= unsigned("00" & audioL_1_s) + 
								unsigned("00" & audioL_2_s) + 
								unsigned("00" & audioL_3_s);

	out_audio_mix_r_s <= unsigned("00" & audioR_1_s) + 
								unsigned("00" & audioR_2_s) + 
								unsigned("00" & audioR_3_s);
	
	audio_psg_L_o <= out_audio_mix_l_s(9 downto 2);
	audio_psg_R_o <= out_audio_mix_r_s(9 downto 2);

	audio_sid_L_o <= audio_sid_s when pan4_s(0) = '1' else (others=>'0');
	audio_sid_R_o <= audio_sid_s when pan4_s(1) = '1' else (others=>'0');

	psg_sel1 	<= '1' when ay_select = "11" else '0';
	psg_sel2 	<= '1' when ay_select = "10" else '0';
	psg_sel3 	<= '1' when ay_select = "01" else '0';

-- BDIR = 1 quando escrita em BFFD ou FFFD
-- BC1  = 0 quando leitura ou escrita em BFFD
-- BC1  = 1 quando leitura ou escrita em FFFD

	-- Next SID
	nsid_addr_s <= not cpu_a(14);
	nsid_cs_s	<= '1' when ay_select = "00" and enable = '1' and cpu_iorq_n = '0' and cpu_m1_n = '1' and cpu_a(15) = '1' and cpu_a(2 downto 0) = "101"	else '0';
	nsid_wr_s	<= not cpu_wr_n;

end turbosound_arch;
