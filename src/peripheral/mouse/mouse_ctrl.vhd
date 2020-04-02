--
-- TBBlue / ZX Spectrum Next project
-- Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
-------------------------------------------------------------------------------
-- Title      : MC613
-- Project    : Mouse Controller
-- Details    : www.ic.unicamp.br/~corte/mc613/
--							www.computer-engineering.org/ps2protocol/
-------------------------------------------------------------------------------
-- File       : mouse_ctrl.vhd
-- Author     : Thiago Borges Abdnur
-- Company    : IC - UNICAMP
-- Last update: 29/10/2015 - Vtrucco
-------------------------------------------------------------------------------
-- Description: 
-- PS2 mouse basic I/O control
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mouse_ctrl is
	generic(
		-- This is the system clock value in kHz. Should be at least 1MHz.
		--  Recommended value is 24000 kHz (CLOCK_24 (DE1 pins: PIN_A12 and 
		--  PIN_B12))
		clkfreq : integer;	 
		SENSIBILITY : integer  -- Valores maiores, mais lento					 
	);
	port(
		enable			: in    std_logic;							-- Enable
		clock				: in    std_logic;							-- system clock (same frequency as defined in 'clkfreq' generic)
		reset				: in    std_logic;							-- Reset when '1'
		ps2_data			: inout std_logic;							-- PS2 data pin
		ps2_clk			: inout std_logic;							-- PS2 clock pin
		mouse_x			: out   std_logic_vector(7 downto 0);		
		mouse_y			: out   std_logic_vector(7 downto 0);		
		-- Mouse buttons state ('1' when pressed):
		--	mouse_bts(0): Left mouse button
		--	mouse_bts(1): Right mouse button
		--	mouse_bts(2): Middle mouse button (if it exists)
		mouse_bts		: out   std_logic_vector(2 downto 0);	
		mouse_wheel		: out   std_logic_vector(3 downto 0)
	);
end;

architecture rtl of mouse_ctrl is
	component ps2_iobase
		generic(
			clkfreq : integer	-- This is the system clock value in kHz
		);
		port(
			enable		:	in	   std_logic;
			clock			:	in	   std_logic;
			reset			:	in	   std_logic;
			ps2_data		:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			idata_rdy	:	in	   std_logic;
			idata			:	in	   std_logic_vector(7 downto 0);
			send_rdy		:	out   std_logic;
			odata_rdy	:	out   std_logic;
			odata			:	out   std_logic_vector(7 downto 0)
		);
	end component;
		
	signal sigsend, sigsendrdy, signewdata, newdata,
			 xn, yn, sigmouse_wheel 	: std_logic;
	signal hdata, ddata 					: std_logic_vector(7 downto 0);
	signal dx, dy							: std_logic_vector(8 downto 0);
	signal s_mouse_x, s_mouse_y		: std_logic_vector(7 downto 0);		
	
begin
	ps2io : ps2_iobase generic map(clkfreq)
	port map(
		enable		=> enable,
		clock			=> clock,
		reset			=> reset,
		ps2_data		=> ps2_data,
		ps2_clk		=> ps2_clk,
		idata_rdy	=> sigsend,
		idata			=> hdata,
		send_rdy		=> sigsendrdy,
		odata_rdy	=> signewdata,
		odata			=> ddata
	);
	
	process(clock, enable, reset)
		type rststatename is (
			SETCMD, SEND, WAITACK, NEXTCMD, REPORTING, WAIT_REPORT, CLEAR
		);
	
		constant ncmd : integer := 3; -- Total number of commands to send
		type commands is array (0 to ncmd - 1) of integer;
		constant cmd : commands := (
		
		-- 16#FF#, 16#F5#, -- Reset and disable reporting
		-- 16#F3#, 200, 16#F3#, 100, 16#F3#, 80, 
		-- 16#F2#, -- mouse_wheel enabling
		-- 16#F6#, 16#F4# -- Restore defaults and enable reporting
			
		16#F3#, --  Set Sample Rate
		16#28#, --  decimal 40
		16#F4# -- enable reporting
			
			
		);
		variable state : rststatename;
		variable count : integer range 0 to ncmd := 0;		
		variable count_paks : integer range 0 to 3 := 0;	
	
		variable clkdata_e_v : std_logic_vector(1 downto 0);
 
	begin
		if(rising_edge(clock)) then
			hdata <= X"00";			
			sigsend <= '0';
--			sigreseting <= '1';
			
			case state is
			
				when SETCMD =>
					hdata <= std_logic_vector(to_unsigned(cmd(count), 8));
					if sigsendrdy = '1' then
						state := SEND;
					else
						state := SETCMD;
					end if;
					
				when SEND =>
					hdata <= std_logic_vector(to_unsigned(cmd(count), 8));
					sigsend <= '1';
					state := WAITACK;
					
				when WAITACK =>
					if signewdata = '1' then
						-- mouse_wheel detection
						if cmd(count) = 16#F2# then
							-- If device ID is 0x00, it has no mouse_wheel				
							if ddata = X"00" then							
								sigmouse_wheel <= '0';
								state := NEXTCMD;
							-- If device ID is 0x03, it has a mouse_wheel							
							elsif ddata = X"03" then							
								sigmouse_wheel <= '1';
								state := NEXTCMD;
							end if;
						else	
							state := NEXTCMD;
						end if;
					end if;
					
				when NEXTCMD =>
					count := count + 1;
					if count = ncmd then
						state := WAIT_REPORT;--REPORTING; --CLEAR
					else
						state := SETCMD;
					end if;	
					
				when REPORTING =>
			
					if sigsendrdy = '1' then
						hdata <= X"EB"; --ask for mouse update
						sigsend <= '1'; --send to mouse
						count_paks := 0;
						state := WAIT_REPORT; 
					else
						state := REPORTING;
					end if;

					
				when WAIT_REPORT=>
				
				
				
					clkdata_e_v := clkdata_e_v(0) & signewdata;
					 
					if clkdata_e_v = "01" then --rising edge of signewdata
						  
						if ddata = X"FA" and count_paks = 0 then --if is an ACK, just wait for the next byte
						
							count_paks := 0;
						
						else

							newdata <= '0';
							
							
							case count_paks is
								when 0 =>
									mouse_bts <= ddata(2 downto 0);
									xn <= ddata(4);
									yn <= ddata(5);
							--	--	ox <= ddata(6);
							--	--	oy <= ddata(7);
									
								when 1 =>
									dx <= xn & ddata;
																		
								when 2 =>
									dy <= yn & ddata;
									
								--when 3 =>
									--mouse_wheel <= ddata(3 downto 0);
								
								when others => 
									NULL;
							end case;
						
							count_paks := count_paks + 1;
							
							if (sigmouse_wheel = '0' and count_paks > 2) or count_paks > 3 then
								count_paks := 0;
								newdata <= '1';
								state := WAIT_REPORT;--REPORTING; 
							end if;
						end if;
						
					else -- no new data, keep wainting
					
						state := WAIT_REPORT; 
						
					end if;
					

						
						
			
				when CLEAR =>
--					sigreseting <= '0';
					count := 0;					
			end case;
			
			
		end if;
		
		
		
		
		if reset = '1' or enable = '0' then
			state := SETCMD;
			count := 0;
			sigmouse_wheel <= '0';
			
			mouse_bts <= (others => '0');
			dx <= (others => '0');
			dy <= (others => '0');
			mouse_wheel <= (others => '0');
			xn <= '0';
			yn <= '0';
	--		ox <= '0';
	--		oy <= '0';
			count := 0;
			newdata <= '0';
		end if;
		
	end process;
	
	
	process(newdata, reset)
		variable xacc, yacc : integer range -10000 to 10000;
	begin
		if rising_edge(newdata) then			
			s_mouse_x <= std_logic_vector(to_signed(to_integer(signed(s_mouse_x)) + ((xacc + to_integer(signed(dx))) / SENSIBILITY), 8));
			s_mouse_y <= std_logic_vector(to_signed(to_integer(signed(s_mouse_y)) + ((yacc + to_integer(signed(dy))) / SENSIBILITY), 8));
			xacc := ((xacc + to_integer(signed(dx))) rem SENSIBILITY);
			yacc := ((yacc + to_integer(signed(dy))) rem SENSIBILITY);					
		end if;
		if reset = '1' then
			xacc := 0;
			yacc := 0;
			s_mouse_x <= (others => '0');
			s_mouse_y <= (others => '0');
		end if;
	end process;
	
	mouse_x <= s_mouse_x;
	mouse_y <= s_mouse_y;
	
end rtl;