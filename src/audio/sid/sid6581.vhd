-------------------------------------------------------------------------------------
--
--                                 SID 6581
--
--     A fully functional SID chip implementation in VHDL
--
-------------------------------------------------------------------------------------
--	to do:	- smaller implementation, use multiplexed channels
--
-- Synthesize
-- WARNING:Xst:1988 - Unit <vic_II>: instances <Mcompar__n0411>, <Mcompar__n0337> of unit <LPM_COMPARE_15> and
-- unit <LPM_COMPARE_13> are dual, second instance is removed
--
--"The Filter was a classic multi-mode (state variable) VCF design. There was no way to create a variable
-- transconductance amplifier in our NMOS process, so I simply used FETs as voltage-controlled resistors
-- to control the cutoff frequency. An 11-bit D/A converter generates the control voltage for the FETs
-- (it's actually a 12-bit D/A, but the LSB had no audible affect so I disconnected it!)."
-- "Filter resonance was controlled by a 4-bit weighted resistor ladder. Each bit would turn on one of the
-- weighted resistors and allow a portion of the output to feed back to the input. The state-variable design
-- provided simultaneous low-pass, band-pass and high-pass outputs. Analog switches selected which combination
-- of outputs were sent to the final amplifier (a notch filter was created by enabling both the high and
-- low-pass outputs simultaneously)."
-- "The filter is the worst part of SID because I could not create high-gain op-amps in NMOS, which were
-- essential to a resonant filter. In addition, the resistance of the FETs varied considerably with processing,
-- so different lots of SID chips had different cutoff frequency characteristics. I knew it wouldn't work very
-- well, but it was better than nothing and I didn't have time to make it better."
--
-------------------------------------------------------------------------------------
-- Dar 08/03/2014
--
--	Devide 32MHz <- Dit kun je makkelijker doen door bovenste bit van busCycle te pakken (deze deelt de klok al door 32)
--
-- roughly modify voice_volume computation to avoid saturation
-------------------------------------------------------------------------------------
-- ZX Next team, 2017/05
-- Adapted for TBBlue, renaming signals
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------

entity sid6581 is
	generic (
		clock_in_mhz_g	: integer := 14
	);
	port (
		clock_i		: in  std_logic;								--	Clock
		reset_i		: in  std_logic;								-- high active signal (reset when reset = '1')
		cs_i			: in  std_logic;								--	"chip select", when this signal is '1' this model can be accessed
		we_i			: in  std_logic;								-- when '1' this model can be written to, otherwise access is considered as read
		--
		addr_i		: in  std_logic_vector(4 downto 0);		-- address lines
		data_i		: in  std_logic_vector(7 downto 0);		--	data in (to chip)
		data_o		: out std_logic_vector(7 downto 0);		--	data out	(from chip)
		--
		audio_o		: out unsigned(17 downto 0)
	);
end entity;


architecture Behavioral of sid6581 is

	-- Implementation of the SID voices (sound channels)
	component sid_voice is
	port (
		clk_1MHz		: in std_logic;							-- this line drives the oscilator
		reset			: in std_logic;							-- active high signal (i.e. registers are reset when reset=1)
		Freq_lo		: in std_logic_vector( 7 downto 0);
		Freq_hi		: in std_logic_vector( 7 downto 0);
		Pw_lo			: in std_logic_vector( 7 downto 0);
		Pw_hi			: in std_logic_vector( 3 downto 0);
		Control		: in std_logic_vector( 7 downto 0);
		Att_dec		: in std_logic_vector( 7 downto 0);
		Sus_Rel		: in std_logic_vector( 7 downto 0);
		PA_MSB_in	: in std_logic;
		PA_MSB_out	: out std_logic;
		Osc			: out std_logic_vector( 7 downto 0);
		Env			: out std_logic_vector( 7 downto 0);
		voice			: out std_logic_vector(11 downto 0)
	);
	end component;

	-------------------------------------------------------------------------------------
	--constant <name>: <type> := <value>;
	constant DC_offset		: std_logic_vector(13 downto 0) := "00111111111111";		-- DC offset required to play samples, this is actually a bug of the real 6581, that was converted into an advantage to play samples
	-------------------------------------------------------------------------------------

	signal Voice_1_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_1_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_1_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_1_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
	signal Voice_1_Control	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_1_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_1_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
	signal Voice_2_Control	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_2_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Freq_lo	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Freq_hi	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Pw_lo		: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Pw_hi		: std_logic_vector(3 downto 0) := "0000";
	signal Voice_3_Control	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Att_dec	: std_logic_vector(7 downto 0) := "00000000";
	signal Voice_3_Sus_Rel	: std_logic_vector(7 downto 0) := "00000000";
	signal Filter_Fc_lo		: std_logic_vector(7 downto 0) := "00000000";
	signal Filter_Fc_hi		: std_logic_vector(7 downto 0) := "00000000";
	signal Filter_Res_Filt	: std_logic_vector(7 downto 0) := "00000000";
	signal Filter_Mode_Vol	: std_logic_vector(7 downto 0) := "00000000";

	signal Misc_PotX			: std_logic_vector(7 downto 0) := "00000000";
	signal Misc_PotY			: std_logic_vector(7 downto 0) := "00000000";
	signal Misc_Osc3_Random	: std_logic_vector(7 downto 0) := "00000000";
	signal Misc_Env3			: std_logic_vector(7 downto 0) := "00000000";

	signal clk_1MHz			: std_logic;
	signal voice_1_PA_MSB	: std_logic;
	signal voice_2_PA_MSB	: std_logic;
	signal voice_3_PA_MSB	: std_logic;

	signal voice_1				: std_logic_vector(11 downto 0);
	signal voice_2				: std_logic_vector(11 downto 0);
	signal voice_3				: std_logic_vector(11 downto 0);
	signal voice_mixed		: std_logic_vector(13 downto 0);
	signal voice_volume		: std_logic_vector(17 downto 0);

	signal do_buf				: std_logic_vector(7 downto 0);

begin

	sid_voice_1: sid_voice
	port map(
		clk_1MHz		=> clk_1MHz,
		reset			=> reset_i,
		Freq_lo		=> Voice_1_Freq_lo,
		Freq_hi		=> Voice_1_Freq_hi,
		Pw_lo			=> Voice_1_Pw_lo,
		Pw_hi			=> Voice_1_Pw_hi,
		Control		=> Voice_1_Control,
		Att_dec		=> Voice_1_Att_dec,
		Sus_Rel		=> Voice_1_Sus_Rel,
		PA_MSB_in	=> voice_3_PA_MSB,
		PA_MSB_out	=> voice_1_PA_MSB,
--		Osc			=> ...
--		Env			=> ...
		voice			=> voice_1
	);

	sid_voice_2: sid_voice
	port map(
		clk_1MHz		=> clk_1MHz,
		reset			=> reset_i,
		Freq_lo		=> Voice_2_Freq_lo,
		Freq_hi		=> Voice_2_Freq_hi,
		Pw_lo			=> Voice_2_Pw_lo,
		Pw_hi			=> Voice_2_Pw_hi,
		Control		=> Voice_2_Control,
		Att_dec		=> Voice_2_Att_dec,
		Sus_Rel		=> Voice_2_Sus_Rel,
		PA_MSB_in	=> voice_1_PA_MSB,
		PA_MSB_out	=> voice_2_PA_MSB,
--		Osc			=> ...
--		Env			=> ...
		voice			=> voice_2
	);

	sid_voice_3: sid_voice
	port map(
		clk_1MHz		=> clk_1MHz,
		reset			=> reset_i,
		Freq_lo		=> Voice_3_Freq_lo,
		Freq_hi		=> Voice_3_Freq_hi,
		Pw_lo			=> Voice_3_Pw_lo,
		Pw_hi			=> Voice_3_Pw_hi,
		Control		=> Voice_3_Control,
		Att_dec		=> Voice_3_Att_dec,
		Sus_Rel		=> Voice_3_Sus_Rel,
		PA_MSB_in	=> voice_2_PA_MSB,
		PA_MSB_out	=> voice_3_PA_MSB,
		Osc			=> Misc_Osc3_Random,
		Env			=> Misc_Env3,
		voice			=> voice_3
	);
	-------------------------------------------------------------------------------------

	-- Divide clock
	divider: process(reset_i, clock_i)
		variable counter_v : integer range 1 to (clock_in_mhz_g/2) := 1;
	begin
		if reset_i = '1' then
			clk_1MHz <= '0';
		elsif rising_edge(clock_i) then
			if counter_v = (clock_in_mhz_g/2) then
				clk_1MHz <= not clk_1MHz;
				counter_v := 1;
			else
				counter_v := counter_v + 1;
			end if;
		end if;
	end process;


	-- Register decoding
	register_decoder: process(clock_i)
	begin
		if rising_edge(clock_i) then
			if reset_i = '1' then
				--------------------------------------- Voice-1
				Voice_1_Freq_lo	<= "00000000";
				Voice_1_Freq_hi	<= "00000000";
				Voice_1_Pw_lo		<= "00000000";
				Voice_1_Pw_hi		<= "0000";
				Voice_1_Control	<= "00000000";
				Voice_1_Att_dec	<= "00000000";
				Voice_1_Sus_Rel	<= "00000000";
				--------------------------------------- Voice-2
				Voice_2_Freq_lo	<= "00000000";
				Voice_2_Freq_hi	<= "00000000";
				Voice_2_Pw_lo		<= "00000000";
				Voice_2_Pw_hi		<= "0000";
				Voice_2_Control	<= "00000000";
				Voice_2_Att_dec	<= "00000000";
				Voice_2_Sus_Rel	<= "00000000";
				--------------------------------------- Voice-3
				Voice_3_Freq_lo	<= "00000000";
				Voice_3_Freq_hi	<= "00000000";
				Voice_3_Pw_lo		<= "00000000";
				Voice_3_Pw_hi		<= "0000";
				Voice_3_Control	<= "00000000";
				Voice_3_Att_dec	<= "00000000";
				Voice_3_Sus_Rel	<= "00000000";
				--------------------------------------- Filter & volume
				Filter_Fc_lo		<= "00000000";
				Filter_Fc_hi		<= "00000000";
				Filter_Res_Filt	<= "00000000";
				Filter_Mode_Vol	<= "00000000";
			else
				Voice_1_Freq_lo	<= Voice_1_Freq_lo;
				Voice_1_Freq_hi	<= Voice_1_Freq_hi;
				Voice_1_Pw_lo		<= Voice_1_Pw_lo;
				Voice_1_Pw_hi		<= Voice_1_Pw_hi;
				Voice_1_Control	<= Voice_1_Control;
				Voice_1_Att_dec	<= Voice_1_Att_dec;
				Voice_1_Sus_Rel	<= Voice_1_Sus_Rel;
				Voice_2_Freq_lo	<= Voice_2_Freq_lo;
				Voice_2_Freq_hi	<= Voice_2_Freq_hi;
				Voice_2_Pw_lo		<= Voice_2_Pw_lo;
				Voice_2_Pw_hi		<= Voice_2_Pw_hi;
				Voice_2_Control	<= Voice_2_Control;
				Voice_2_Att_dec	<= Voice_2_Att_dec;
				Voice_2_Sus_Rel	<= Voice_2_Sus_Rel;
				Voice_3_Freq_lo	<= Voice_3_Freq_lo;
				Voice_3_Freq_hi	<= Voice_3_Freq_hi;
				Voice_3_Pw_lo		<= Voice_3_Pw_lo;
				Voice_3_Pw_hi		<= Voice_3_Pw_hi;
				Voice_3_Control	<= Voice_3_Control;
				Voice_3_Att_dec	<= Voice_3_Att_dec;
				Voice_3_Sus_Rel	<= Voice_3_Sus_Rel;
				Filter_Fc_lo		<= Filter_Fc_lo;
				Filter_Fc_hi		<= Filter_Fc_hi;
				Filter_Res_Filt	<= Filter_Res_Filt;
				Filter_Mode_Vol	<= Filter_Mode_Vol;
	--			do_buf			<= do_buf;
				do_buf 			<= "00000000";

				if cs_i='1' then
					if we_i='1' then	-- Write to SID-register
								------------------------
						case to_integer(unsigned(addr_i)) is
							-------------------------------------- Voice-1
							when 00 =>	Voice_1_Freq_lo	<= data_i;
							when 01 =>	Voice_1_Freq_hi	<= data_i;
							when 02 =>	Voice_1_Pw_lo		<= data_i;
							when 03 =>	Voice_1_Pw_hi		<= data_i(3 downto 0);
							when 04 =>	Voice_1_Control	<= data_i;
							when 05 =>	Voice_1_Att_dec	<= data_i;
							when 06 =>	Voice_1_Sus_Rel	<= data_i;
							--------------------------------------- Voice-2
							when 07 =>	Voice_2_Freq_lo	<= data_i;
							when 08 =>	Voice_2_Freq_hi	<= data_i;
							when 09 =>	Voice_2_Pw_lo		<= data_i;
							when 10 =>	Voice_2_Pw_hi		<= data_i(3 downto 0);
							when 11 =>	Voice_2_Control	<= data_i;
							when 12 =>	Voice_2_Att_dec	<= data_i;
							when 13 =>	Voice_2_Sus_Rel	<= data_i;
							--------------------------------------- Voice-3
							when 14 =>	Voice_3_Freq_lo	<= data_i;
							when 15 =>	Voice_3_Freq_hi	<= data_i;
							when 16 =>	Voice_3_Pw_lo		<= data_i;
							when 17 =>	Voice_3_Pw_hi		<= data_i(3 downto 0);
							when 18 =>	Voice_3_Control	<= data_i;
							when 19 =>	Voice_3_Att_dec	<= data_i;
							when 20 =>	Voice_3_Sus_Rel	<= data_i;
							--------------------------------------- Filter & volume
							when 21 =>	Filter_Fc_lo		<= data_i;
							when 22 =>	Filter_Fc_hi		<= data_i;
							when 23 =>	Filter_Res_Filt	<= data_i;
							when 24 =>	Filter_Mode_Vol	<= data_i;
							--------------------------------------
							when others	=>	null;
						end case;

					else			-- Read from SID-register
							-------------------------
						case to_integer(unsigned(addr_i)) is
							-------------------------------------- Misc
							when 25 =>	do_buf	<= Misc_PotX;
							when 26 =>	do_buf	<= Misc_PotY;
							when 27 =>	do_buf	<= Misc_Osc3_Random;
							when 28 =>	do_buf	<= Misc_Env3;
							--------------------------------------
							when others	=>	do_buf <= "00000000";

						end case;
					end if;
				end if;
			end if;
		end if;
	end process;

	data_o				<= do_buf;

	-- SID filters

	fblk: block
	  signal voice1_signed: signed(12 downto 0);
	  signal voice2_signed: signed(12 downto 0);
	  signal voice3_signed: signed(12 downto 0);
	  constant ext_in_signed: signed(12 downto 0) := to_signed(0,13);
	  signal filtered_audio: signed(18 downto 0);
	  signal tick_q1, tick_q2: std_logic;
	  signal input_valid: std_logic;
	  signal unsigned_audio: std_logic_vector(17 downto 0);
	  signal unsigned_filt: std_logic_vector(18 downto 0);
	  signal ff1: std_logic;
	begin

	  process (clk_1MHz,reset_i)
	  begin
			if reset_i='1' then
			  ff1<='0';
			else

		 if rising_edge(clk_1MHz) then
			  ff1<=not ff1;
		 end if;
		 end if;
	  end process;

	  process(clock_i)
	  begin
		 if rising_edge(clock_i) then
			tick_q1 <= ff1;
			tick_q2 <= tick_q1;
		 end if;
	  end process;

	  input_valid<='1' when tick_q1 /=tick_q2 else '0';


	  voice1_signed <= signed(voice_1 & "0") - 4096;
	  voice2_signed <= signed(voice_2 & "0") - 4096;
	  voice3_signed <= signed(voice_3 & "0") - 4096;

	  filters: entity work.sid_filters 
	  port map (
		 clk       => clock_i,
		 rst       => reset_i,
		 -- SID registers.
		 Fc_lo     => Filter_Fc_lo,
		 Fc_hi     => Filter_Fc_hi,
		 Res_Filt  => Filter_Res_Filt,
		 Mode_Vol  => Filter_Mode_Vol,
		 -- Voices - resampled to 13 bit
		 voice1    => voice1_signed,
		 voice2    => voice2_signed,
		 voice3    => voice3_signed,
		 --
		 input_valid => input_valid,
		 ext_in    => ext_in_signed,

		 sound     => filtered_audio,
		 valid     => open
	  );

		 unsigned_filt <= std_logic_vector(filtered_audio + "1000000000000000000");
		 unsigned_audio <= unsigned_filt(18 downto 5) * ('0' & Filter_Mode_Vol(3 downto 1));
		 audio_o <= unsigned(unsigned_audio);

	end block;

end Behavioral;
