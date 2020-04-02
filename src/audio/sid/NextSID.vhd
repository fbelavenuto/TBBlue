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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity NextSID is
	generic (
		clock_in_mhz_g	: integer := 14
	);
	port (
		clock_i		: in  std_logic;
		reset_i		: in  std_logic;
		-- CPU
		addr_i		: in  std_logic;
		cs_i			: in  std_logic;
		wr_i			: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		has_data_o	: out std_logic;
		--
		audio_o		: out unsigned(17 downto 0)
	);
end entity;

architecture Behavior of NextSID is

	signal sid_addr_s		: std_logic_vector(4 downto 0);
	signal sid_cs_s		: std_logic;

begin

	sid: entity work.sid6581
	generic map (
		clock_in_mhz_g	=> clock_in_mhz_g
	)
	port map (
		clock_i		=> clock_i,
		reset_i		=> reset_i,
		cs_i			=> sid_cs_s,
		we_i			=> wr_i,
		--
		addr_i		=> sid_addr_s,
		data_i		=> data_i,
		data_o		=> data_o,
		--
		audio_o		=> audio_o
	);

	-- write register address
	process (cs_i)
	begin
		if falling_edge(clock_i) then
			if cs_i = '1' and addr_i = '0' and wr_i = '1' then
				sid_addr_s <= data_i(4 downto 0);
			end if;
		end if;
	end process;

	sid_cs_s		<= '1' when cs_i = '1' and addr_i = '1'						else '0';
	has_data_o	<= '1' when cs_i = '1' and addr_i = '1' and wr_i = '0'	else '0';

end architecture;
