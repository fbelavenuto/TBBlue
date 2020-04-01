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
-- Abstracao do audio para chip TDA1543

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Audio_TDA1543 is
	generic (
		chipSMD		: boolean := TRUE
	);
	port (
		clock			: in    std_logic;							-- Clock (28 MHz)
		ear			: in    std_logic;							-- Entrada 1 bit EAR
		spk			: in    std_logic;							-- Entrada 1 bit Speaker
		mic			: in    std_logic;							-- Entrada 1 bit MIC
		psg			: in    std_logic_vector(7 downto 0);	-- Entrada 8 bits mono para o PSG

		i2s_bclk		: out   std_logic;							-- Ligar nos pinos do TOP
		i2s_ws		: out   std_logic;
		i2s_data		: out   std_logic;
		format		: in	  std_logic
	);
end entity;

architecture Behavior of Audio_TDA1543 is

	signal clock_div			: std_logic_vector(3 downto 0)	:= "0000";

	signal pcm_outl			: std_logic_vector(15 downto 0);
	signal pcm_outr			: std_logic_vector(15 downto 0);

	signal spk_s				: std_logic_vector(15 downto 0);
	signal mic_s				: std_logic_vector(15 downto 0);
	signal ear_s				: std_logic_vector(15 downto 0);
	signal psg_s				: std_logic_vector(15 downto 0);

	constant spk_volume		: std_logic_vector(15 downto 0) := "0100000000000000";
	constant mic_volume		: std_logic_vector(15 downto 0) := "0000100000000000";
	constant ear_volume		: std_logic_vector(15 downto 0) := "0000001000000000";

begin

	audioout : entity work.tda1543
	generic map (
		chipSMD		=> chipSMD
	)
	port map (
		clock			=> clock_div(1),		-- 7 MHz
		left_audio	=> pcm_outl,
		right_audio	=> pcm_outr,
		tda_bck		=> i2s_bclk,
		tda_ws		=> i2s_ws,
		tda_data		=> i2s_data,
		format		=> format
	);

	spk_s <= spk_volume when spk = '1' else (others => '0');
	mic_s <= mic_volume when mic = '1' else (others => '0');
	ear_s <= ear_volume when ear = '1' else (others => '0');
	psg_s <=  psg & "00000000";

	pcm_outl <= std_logic_vector(unsigned(spk_s) + unsigned(mic_s) + unsigned(ear_s) + unsigned(psg_s));
	pcm_outr <= std_logic_vector(unsigned(spk_s) + unsigned(mic_s) + unsigned(ear_s) + unsigned(psg_s));

	-- Dividir clock
	process(clock)
	begin
		if rising_edge(clock) then
			clock_div <= clock_div + '1';
		end if;
	end process;
	-- clock_div(0) = 14 MHz
	-- clock_div(1) =  7 MHz
	-- clock_div(2) =  3.5 MHz

end architecture;