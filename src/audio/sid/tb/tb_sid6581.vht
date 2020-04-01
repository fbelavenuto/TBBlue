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

ARCHITECTURE sid6581_arch OF tb IS

	component sid6581 is
		generic (
			clock_in_mhz_g	: integer := 14
		);
		port (
			clock_i		: in  std_logic;
			reset_i		: in  std_logic;
			cs_i		: in  std_logic;
			we_i		: in  std_logic;
			--
			addr_i		: in  std_logic_vector(4 downto 0);
			data_i		: in  std_logic_vector(7 downto 0);
			data_o		: out std_logic_vector(7 downto 0);
			--
			audio_o		: out std_logic_vector(17 downto 0)
		);
	end component;

	-- constants

	-- signals
	signal tb_end			: std_logic := '0';
	signal clock_s			: std_logic;
	signal reset_s			: std_logic;
	signal cs_s				: std_logic;
	signal we_s				: std_logic;
	signal addr_s			: std_logic_vector( 4 downto 0);
	signal data_i_s			: std_logic_vector( 7 downto 0);
	signal data_o_s			: std_logic_vector( 7 downto 0);
	signal audio_s			: std_logic_vector(17 downto 0);

begin

	i1 : sid6581
	generic map (
		clock_in_mhz_g	=> 28
	)
	port map (
		clock_i		=> clock_s,
		reset_i		=> reset_s,
		cs_i		=> cs_s,
		we_i		=> we_s,
		--
		addr_i		=> addr_s,
		data_i		=> data_i_s,
		data_o		=> data_o_s,
		--
		audio_o		=> audio_s
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

		clock_s <= '1';
		wait for 17.8 ns;
		clock_s <= '0';
		wait for 17.8 ns;
	end process;	

	-- ----------------------------------------------------- --
	--  testbench                                            --
	-- ----------------------------------------------------- --
	process
	begin
		cs_s		<= '0';
		we_s		<= '0';
		data_i_s	<= X"00";
		addr_s		<= "00000";
		reset_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s		<= '0';

		wait for 2 ms;

		-- ----------------------------------------------------- --
		--  end                                                  --
		-- ----------------------------------------------------- --
		tb_end <= '1';
		wait;
	end process;

end sid6581_arch;
