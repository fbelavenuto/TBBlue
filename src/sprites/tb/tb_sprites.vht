-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions
-- and other software and tools, and its AMPP partner logic
-- functions, and any output files from any of the foregoing
-- (including device programming or simulation files), and any
-- associated documentation or information are expressly subject
-- to the terms and conditions of the Altera Program License
-- Subscription Agreement, Altera MegaCore Function License
-- Agreement, or other applicable license agreement, including,
-- without limitation, that your use is for the sole purpose of
-- programming logic devices manufactured by Altera and sold by
-- Altera or its authorized distributors.  Please refer to the
-- applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to
-- suit user's needs .Comments are provided in each section to help the user
-- fill out necessary details.
-- ***************************************************************************
-- Generated on "01/31/2017 20:50:32"

-- Vhdl Test Bench template for design  :  sprites
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY tb IS
END tb;

ARCHITECTURE sprites_arch OF tb IS

	component sprites is
		port (
			clock_master_i	: in  std_logic;
			clock_pixel_i	: in  std_logic;
			reset_i			: in  std_logic;
			hcounter_i		: in unsigned(8 downto 0);
			vcounter_i		: in unsigned(8 downto 0);
			-- CPU
			cpu_a_i			: in  std_logic_vector(15 downto 0);
			cpu_d_i			: in  std_logic_vector( 7 downto 0);
			cpu_d_o			: out std_logic_vector( 7 downto 0);
			has_data_o		: out std_logic;
			cpu_iorq_n_i	: in  std_logic;
			cpu_rd_n_i		: in  std_logic;
			cpu_wr_n_i		: in  std_logic;
			-- Out
			rgb_o			: out std_logic_vector(7 downto 0);
			pixel_en_o		: out std_logic
		);
	end component;

	-- constants

	-- signals
	signal tb_end			: std_logic := '0';
	signal clock_master_s	: std_logic;
	signal clock_pixel_s	: std_logic;
	signal reset_s			: std_logic;
	signal hcounter_s		: unsigned(8 downto 0)				:= (others => '0');
	signal vcounter_s		: unsigned(8 downto 0)				:= (others => '1');
	signal cpu_a_s			: std_logic_vector(15 downto 0);
	signal cpu_d_i_s		: std_logic_vector( 7 downto 0);
	signal cpu_d_o_s		: std_logic_vector( 7 downto 0);
	signal has_data_s		: std_logic;
	signal cpu_iorq_n_s		: std_logic;
	signal cpu_rd_n_s		: std_logic;
	signal cpu_wr_n_s		: std_logic;
	signal rgb_s			: std_logic_vector(7 downto 0);
	signal pixel_en_s		: std_logic;

begin

	i1 : sprites
	port map (
		clock_master_i	=> clock_master_s,
		clock_pixel_i	=> clock_pixel_s,
		reset_i			=> reset_s,
		hcounter_i		=> hcounter_s,
		vcounter_i		=> vcounter_s,
		-- CPU
		cpu_a_i			=> cpu_a_s,
		cpu_d_i			=> cpu_d_i_s,
		cpu_d_o			=> cpu_d_o_s,
		has_data_o		=> has_data_s,
		cpu_iorq_n_i	=> cpu_iorq_n_s,
		cpu_rd_n_i		=> cpu_rd_n_s,
		cpu_wr_n_i		=> cpu_wr_n_s,
		-- Out
		rgb_o			=> rgb_s,
		pixel_en_o		=> pixel_en_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	-- 28 MHz
	process
	begin
		if tb_end = '1' then
			wait;
		end if;

		clock_master_s <= '1';
		wait for 18 ns;
		clock_master_s <= '0';
		wait for 18 ns;
	end process;	

	-- 7 MHz
	process
	begin
		if tb_end = '1' then
			wait;
		end if;

		clock_pixel_s <= '1';
		wait for 72 ns;
		clock_pixel_s <= '0';
		wait for 72 ns;
	end process;	

	-- ----------------------------------------------------- --
	--  testbench                                            --
	-- ----------------------------------------------------- --
	process (clock_pixel_s)
	begin
		if rising_edge(clock_pixel_s) then
			if hcounter_s = 447 then
				hcounter_s <= (others => '0');
				vcounter_s <= vcounter_s + 1;
			else
				hcounter_s <= hcounter_s + 1;
			end if;
		end if;
	end process;

	process
	begin

		reset_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		reset_s <= '0';

		wait for 2 ms;

		-- ----------------------------------------------------- --
		--  end                                                  --
		-- ----------------------------------------------------- --
		tb_end <= '1';
		wait;
	end process;

	-- Load data
	process
	begin
		cpu_a_s <= (others => '0');
		cpu_d_i_s <= (others => '0');
		cpu_iorq_n_s <= '1';
		cpu_rd_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );

		-- OUT 12347,0
		cpu_a_s <= x"303B";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,32 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"20";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,40 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"28";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,48 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"30";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,2 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"02";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,56 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"38";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,3 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"03";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,64 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"40";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,4 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"04";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,72 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"48";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,5 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"05";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,80 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"50";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,6 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"06";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,88 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"58";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,7 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"07";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,89 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"59";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,8 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"08";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,90 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"5A";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,9 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"09";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

-------------------------------------------------------------------
		-- OUT 87,91 (X)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"5B";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,0 (Y)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"00";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,1 (Attr)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"01";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		-- OUT 87,10 (Name)
		cpu_a_s <= x"0057";
		cpu_d_i_s <= x"0A";
		cpu_iorq_n_s <= '0';
		cpu_wr_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_wr_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );


--------------------------------------
--------------------------------------

		wait for 148 us;

		-- IN 12347
		cpu_a_s <= x"303B";
		cpu_iorq_n_s <= '0';
		cpu_rd_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_rd_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		wait for 1500 us;

		-- IN 12347
		cpu_a_s <= x"303B";
		cpu_iorq_n_s <= '0';
		cpu_rd_n_s <= '0';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );
		cpu_iorq_n_s <= '1';
		cpu_rd_n_s <= '1';
		wait until( rising_edge(clock_master_s) );
		wait until( rising_edge(clock_master_s) );

		wait;
	end process;

end sprites_arch;
