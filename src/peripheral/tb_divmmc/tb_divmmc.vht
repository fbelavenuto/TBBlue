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

entity tb is
end tb;

architecture divmmc_arch of tb is

	-- test target
	component divmmc
	port(
		-- CPU
		clock				: in    std_logic;
		reset_i			: in    std_logic;
		cpu_a				: in    std_logic_vector(15 downto 0);
		cpu_wr_n			: in    std_logic;
		cpu_rd_n			: in    std_logic;
		cpu_mreq_n		: in    std_logic;
		cpu_ioreq_n		: in    std_logic;
		cpu_m1_n			: in    std_logic;
		di					: in    std_logic_vector(7 downto 0);
		do					: out   std_logic_vector(7 downto 0);
		-- SD card interface
		spi_cs			: out   std_logic;
		sd_cs0			: out   std_logic;
		sd_sclk			: out   std_logic;
		sd_mosi			: out   std_logic;
		sd_miso			: in    std_logic;
		-- NMI
		nmi_button_n	: in    std_logic;
		nmi_to_cpu_n	: out   std_logic;
		-- Paging control for external RAM/ROM banks
		no_automap		: in    std_logic;
		ram_bank			: out   std_logic_vector(5 downto 0);
		
		--sinais pra rom e ram
		ram_en_o		: out   std_logic;
		rom_en_o		: out   std_logic;
		dout				: out   std_logic;
		-- Debug
		D_mapterm_o		: out   std_logic;
		D_automap_o		: out   std_logic
	);
	end component;

	signal clock			: std_logic;
	signal reset_i			: std_logic;
	signal cpu_a			: std_logic_vector(15 downto 0);
	signal cpu_wr_n		: std_logic;
	signal cpu_rd_n		: std_logic;
	signal cpu_mreq_n		: std_logic;
	signal cpu_ioreq_n	: std_logic;
	signal cpu_m1_n		: std_logic;
	signal di				: std_logic_vector(7 downto 0);
	signal do				: std_logic_vector(7 downto 0);
	signal spi_cs			: std_logic;
	signal sd_cs0			: std_logic;
	signal sd_sclk			: std_logic;
	signal sd_mosi			: std_logic;
	signal sd_miso			: std_logic;
	signal nmi_button_n	: std_logic;
	signal nmi_to_cpu_n	: std_logic;
	signal no_automap		: std_logic;
	signal ram_bank		: std_logic_vector(5 downto 0);
	signal ram_en			: std_logic;
	signal rom_en			: std_logic;
	signal dout				: std_logic;
	signal tb_end			: std_logic := '0';

begin

	--  instance
	u_target: divmmc
	port map(
		clock				=> clock,
		reset_i			=> reset_i,
		cpu_a				=> cpu_a,
		cpu_wr_n			=> cpu_wr_n,
		cpu_rd_n			=> cpu_rd_n,
		cpu_mreq_n		=> cpu_mreq_n,
		cpu_ioreq_n		=> cpu_ioreq_n,
		cpu_m1_n			=> cpu_m1_n,
		di					=> di,
		do					=> do,
		spi_cs			=> spi_cs,
		sd_cs0			=> sd_cs0,
		sd_sclk			=> sd_sclk,
		sd_mosi			=> sd_mosi,
		sd_miso			=> sd_miso,
		nmi_button_n	=> nmi_button_n,
		nmi_to_cpu_n	=> nmi_to_cpu_n,
		no_automap		=> no_automap,
		ram_bank			=> ram_bank,
		ram_en_o			=> ram_en,
		rom_en_o			=> rom_en,
		dout				=> dout
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock <= '0';
		wait for 140 ns;
		clock <= '1';
		wait for 140 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		cpu_a			<= (others => 'Z');
		cpu_wr_n		<= '1';
		cpu_rd_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_ioreq_n		<= '1';
		cpu_m1_n		<= '1';
		di				<= (others => '0');
		sd_miso			<= '0';
		nmi_button_n	<= '1';
		no_automap		<= '0';

		-- reset
		reset_i	<= '1';
		wait until( rising_edge(clock) );
		reset_i	<= '0';
		wait until( rising_edge(clock) );

		-- Mem
		wait until( rising_edge(clock) );

		-- T80
		-------------- M1 -----------------------
		cpu_a			<= X"0008";
		cpu_m1_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_m1_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		cpu_a			<= X"0000";		-- rfsh
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- MEM ----------------------
		cpu_a			<= X"0009";
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( falling_edge(clock) );
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- MEM ----------------------
		cpu_a			<= X"000A";
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( falling_edge(clock) );
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- M1 -----------------------
		cpu_a			<= X"1FF8";
		cpu_m1_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_m1_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		cpu_a			<= X"0000";		-- rfsh
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- MEM ----------------------
		cpu_a			<= X"000B";
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( falling_edge(clock) );
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- M1 -----------------------
		cpu_a			<= X"3D00";
		cpu_m1_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_m1_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		cpu_a			<= X"0000";		-- rfsh
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------
		-------------- M1 -----------------------
		cpu_a			<= X"1FFF";
		cpu_m1_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_m1_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		cpu_a			<= X"0000";		-- rfsh
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------



		cpu_a			<= (others => 'Z');
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );

		-- A-Z80
		-------------- M1 -----------------------
		cpu_m1_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_a			<= X"0008";
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		cpu_m1_n		<= '1';
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		wait until( falling_edge(clock) );
		cpu_a			<= X"0000";		-- rfsh
		cpu_mreq_n		<= '0';
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------

		-------------- MEM ----------------------
		wait until( falling_edge(clock) );
		cpu_a			<= X"0009";
		cpu_mreq_n		<= '0';
		cpu_rd_n		<= '0';
		wait until( falling_edge(clock) );
		wait until( falling_edge(clock) );
		cpu_mreq_n		<= '1';
		cpu_rd_n		<= '1';
		wait until( rising_edge(clock) );
		-----------------------------------------

		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		wait until( rising_edge(clock) );
		-- SPI
		-- write A5 in port EB
		cpu_a		<= X"00EB";
		cpu_ioreq_n	<= '0';
		DI			<= X"5A";
		wait until( rising_edge(clock) );
		cpu_ioreq_n	<= '1';

		for i in 0 to 20 loop
			wait until( rising_edge(clock) );
		end loop;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end divmmc_arch;
