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

entity dpram2 is
	generic (
		addr_width_g : integer := 6;
		data_width_g : integer := 8
	);
	port (
		clk_a_i  : in  std_logic;
		we_i     : in  std_logic;
		addr_a_i : in  std_logic_vector(addr_width_g-1 downto 0);
		data_a_i : in  std_logic_vector(data_width_g-1 downto 0);
		data_a_o : out std_logic_vector(data_width_g-1 downto 0);
		clk_b_i  : in  std_logic;
		addr_b_i : in  std_logic_vector(addr_width_g-1 downto 0);
		data_b_o : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity;

architecture rtl of dpram2 is

	type ROM_ARRAY is array(0 to 63) of std_logic_vector(7 downto 0);
	constant ROM : ROM_ARRAY := (
                x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07", -- 0x0000
                x"08",x"09",x"10",x"11",x"12",x"13",x"14",x"15", -- 0x0008
                x"16",x"17",x"18",x"19",x"20",x"21",x"22",x"23", -- 0x0010
                x"24",x"25",x"26",x"27",x"28",x"29",x"30",x"31", -- 0x0018
                x"32",x"33",x"34",x"35",x"36",x"37",x"38",x"39", -- 0x0020
                x"40",x"41",x"42",x"43",x"44",x"45",x"46",x"47", -- 0x0028
                x"48",x"49",x"50",x"51",x"52",x"53",x"54",x"55", -- 0x0030
                x"56",x"57",x"58",x"59",x"60",x"61",x"62",x"63"  -- 0x0038
	);

begin

	process(clk_b_i)
	begin
		if rising_edge(clk_b_i) then
			data_b_o <= ROM(to_integer(unsigned(addr_b_i)));
		end if;
	end process;
end RTL;
