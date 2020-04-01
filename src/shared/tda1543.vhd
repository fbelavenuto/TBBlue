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
-- TDA1543 - I2S Sound
--

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tda1543 is
	generic (
		chipSMD		: boolean := TRUE
	);
	port (
		clock			: in    std_logic;
		left_audio	: in    std_logic_vector(15 downto 0);
		right_audio	: in    std_logic_vector(15 downto 0);

		tda_bck		: out   std_logic;
		tda_ws		: out   std_logic;
		tda_data		: out   std_logic;
		format		: in    std_logic
	);
end tda1543;

architecture behavior of tda1543 is

	signal offset	: integer := 0;	-- 0 = DIP, 7 = SMD

begin

--smd: if chipSMD generate
--	offset	<= 7;
--end generate;

--dip: if not chipSMD generate
--	offset	<= 0;
--end generate;

	offset <= 7 when format = '0' else 0;

	process( clock )
		variable outLeft       : unsigned(15 downto 0) := x"0000";
		variable outRight      : unsigned(15 downto 0) := x"0000";
		variable outData       : unsigned(47 downto 0) := x"000000000000";

		variable leftDataTemp  : unsigned(19 downto 0) := x"00000";
		variable rightDataTemp : unsigned(19 downto 0) := x"00000";

		variable tdaCounter    : unsigned(7 downto 0) := "00000000";
		variable skipCounter   : unsigned(7 downto 0) := x"00";
		
	begin
		if rising_edge(clock) then

			if tdaCounter = 48 * 2 then
				tdaCounter := x"00";

				outRight := rightDataTemp( 19 downto 4 );
				rightDataTemp := x"00000";

				outLeft := leftDataTemp( 19 downto 4 );
				leftDataTemp := x"00000";

				outRight(15) := not outRight(15);
				outLeft(15) := not outLeft(15);

				outData := unsigned( x"00" & std_logic_vector(outRight( 15 downto 0 )) & x"00" & std_logic_vector(outLeft( 15 downto 0 )) );

			end if;
			
			if tdaCounter(0) = '0' then
    			
				tda_data <= outData( 47 );
				outData := outData( 46 downto 0 ) & "0";

				-- para TDA1543 (DIP) usar offset 0, para TDA1543T (SMD) usar offset 7
				if tdaCounter( 7 downto 1 ) = 0 + offset then
					tda_ws <= '1';
				elsif tdaCounter( 7 downto 1 ) = 24 + offset then
					tda_ws <= '0';
				end if;

				if skipCounter >= 2 then
							
					rightDataTemp := rightDataTemp + unsigned( right_audio );
					leftDataTemp  := leftDataTemp  + unsigned( left_audio );
					skipCounter   := x"00";					
					
				else
				
					skipCounter := skipCounter + 1;
					
				end if;
			
			end if;
		
			tda_bck <= tdaCounter(0);
			tdaCounter := tdaCounter + 1;
			
		end if;
	end process;

end architecture;