--
-- TBBlue / ZX Spectrum Next project
-- Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
-------------------------------------------------------------------------------
-- Title      : MC613
-- Project    : PS2 Basic Protocol
-- Details    : www.ic.unicamp.br/~corte/mc613/
--							www.computer-engineering.org/ps2protocol/
-------------------------------------------------------------------------------
-- File       : ps2_base.vhd
-- Author     : Thiago Borges Abdnur
-- Company    : IC - UNICAMP
-- Last update: 2010/04/12
-------------------------------------------------------------------------------
-- Description: 
-- PS2 basic control
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ps2_iobase is
	generic(
		clkfreq			: integer										-- This is the system clock value in kHz
	);
	port(
		enable			: in    std_logic;							-- Enable
		clock				: in    std_logic;							-- system clock (same frequency as defined in 'clkfreq' generic)
		reset				: in    std_logic;							-- Reset when '1'
		ps2_data			: inout std_logic;							-- PS2 data pin
		ps2_clk			: inout std_logic;							-- PS2 clock pin
		idata_rdy		: in    std_logic;							-- Rise this to signal data is ready to be sent to device
		idata				: in    std_logic_vector(7 downto 0);	-- Data to be sent to device
		send_rdy			: out   std_logic;							-- '1' if data can be sent to device (wait for this before rising 'idata_rdy'
		odata_rdy		: out   std_logic;							-- '1' when data from device has arrived
		odata				: out   std_logic_vector(7 downto 0)	-- Data from device
	);
end;

architecture rtl of ps2_iobase is

	constant CLKSSTABLE 		: integer := clkfreq / 150;
				 
	signal sdata, hdata		: std_logic_vector(7 downto 0);
	signal sigtrigger			: std_logic;
	signal parchecked			: std_logic;
	signal sigsending			: std_logic;
	signal sigsendend			: std_logic;
	signal sigclkreleased	: std_logic;
	signal sigclkheld			: std_logic;

begin

	-- Trigger for state change to eliminate noise
	process(clock, ps2_clk, enable, reset)
		variable fcount, rcount : integer range CLKSSTABLE downto 0;
	begin
		if(rising_edge(clock) and enable = '1') then
			-- Falling edge noise
			if ps2_clk = '0' then
				rcount := 0;
				if fcount >= CLKSSTABLE then
					sigtrigger <= '1';
				else
					fcount := fcount + 1;
				end if;
			-- Rising edge noise
			elsif ps2_clk = '1' then
				fcount := 0;
				if rcount >= CLKSSTABLE then
					sigtrigger <= '0';
				else
					rcount := rcount + 1;
				end if;
			end if;
		end if;
		if reset = '1' then
			fcount := 0;
			rcount := 0;
			sigtrigger <= '0';
		end if;
	end process;

	FROMPS2:
	process(sigtrigger, sigsending, reset)
		variable count : integer range 0 to 11;
	begin
		if reset = '1' or sigsending = '1' then
			sdata <= (others => '0');
			parchecked <= '0';
			count := 0;
		elsif rising_edge(sigtrigger) then
			if count = 0 then
				-- Idle state, check for start bit (0) only and don't
				-- start counting bits until we get it
				if ps2_data = '0' then
					-- This is a start bit
					count := count + 1;
				end if;
			else
				-- Running.  8-bit data comes in LSb first followed by
				-- a single stop bit (1)
				if count < 9 then
					sdata(count - 1) <= ps2_data;
				end if;
				if count = 9 then
					if (not (sdata(0) xor sdata(1) xor sdata(2) xor sdata(3)
					 xor sdata(4) xor sdata(5) xor sdata(6) xor sdata(7))) = ps2_data then
						parchecked <= '1';
					else
						parchecked <= '0';
					end if;
				end if;
				count := count + 1;
				if count = 11 then
					count := 0;
					parchecked <= '0';
				end if;
			end if;
		end if;
	end process;

	odata_rdy	<= enable and parchecked;
	odata 		<= sdata;

	-- Edge triggered send register
	process(idata_rdy, sigsendend, reset)
	begin
		if(rising_edge(idata_rdy)) then
			sigsending <= '1';
		end if;
		if reset = '1' or sigsendend = '1' then
			sigsending <= '0';
		end if;
	end process;

	-- Wait for at least 11ms before allowing to send again
	process(clock, sigsending, reset)
		-- clkfreq is the number of clocks within a milisecond
		variable countclk : integer range 0 to (12 * clkfreq);
	begin
		if(rising_edge(clock) and sigsending = '0') then			
			if countclk = (11 * clkfreq) then
				send_rdy <= '1';
			else
				countclk := countclk + 1;
			end if;
		end if;
		if sigsending = '1' then
			send_rdy <= '0';
			countclk := 0;
		end if;
		if reset = '1' then
			send_rdy <= '1';
			countclk := 0;
		end if;
	end process;
	
	-- Host input data register
	process(idata_rdy, sigsendend, reset)
	begin
		if(rising_edge(idata_rdy)) then
			hdata <= idata;
		end if;
		if reset = '1' or sigsendend = '1' then
			hdata <= (others => '0');
		end if;
	end process;
	
	-- PS2 clock control
	process(enable, clock, sigsendend, reset, sigsending)
		constant US100CNT : integer := clkfreq / 10;
		variable count : integer range 0 to US100CNT + 101;
	begin
		if(rising_edge(clock) and sigsending = '1') then
			if count < US100CNT + 50 then
				count := count + 1;
				ps2_clk <= '0';
				sigclkreleased <= '0';
				sigclkheld <= '0';
			elsif count < US100CNT + 100 then
				count := count + 1;
				ps2_clk <= '0';
				sigclkreleased <= '0';
				sigclkheld <= '1';
			else
				ps2_clk <= 'Z';
				sigclkreleased <= '1';
				sigclkheld <= '0';
			end if;
		end if;
		if enable = '0' or reset = '1' or sigsendend = '1' then
			ps2_clk			<= 'Z';
			sigclkreleased	<= '1';
			sigclkheld		<= '0';
			count				:= 0;
		end if;
	end process;

	-- Sending control
	TOPS2:
	process(enable, sigtrigger, sigsending, sigclkheld, sigclkreleased, reset)
		variable count : integer range 0 to 11;
	begin
		if(rising_edge(sigtrigger) and sigclkreleased = '1' and sigsending = '1') then
			if count >= 0 and count < 8 then
				ps2_data <= hdata(count);
				sigsendend <= '0';
			end if;
			if count = 8 then
				ps2_data <= (not (hdata(0) xor hdata(1) xor hdata(2) xor hdata(3)
				 xor hdata(4) xor hdata(5) xor hdata(6) xor hdata(7)));
				sigsendend <= '0';
			end if;
			if count = 9 then
				ps2_data <= 'Z';
				sigsendend <= '0';
			end if;			
			if count = 10 then				
				ps2_data <= 'Z';
				sigsendend <= '1';
				count := 0;
			end if;
			count := count + 1;
		end if;		
		if sigclkheld = '1' then
			ps2_data <= '0';
			sigsendend <= '0';
			count := 0;
		end if;
		if enable = '0' or reset = '1' or sigsending = '0' then
			ps2_data <= 'Z';
			sigsendend <= '0';			
			count := 0;
		end if;
	end process;

end rtl;