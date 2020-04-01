## Generated SDC file "tbblue_fpga.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Fri May 19 19:51:42 2017"

##
## DEVICE  "EP2C20F484C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {tbblue:tbblue1|zxula:ula_inst|cpu_clk_s} -period 285.714 -waveform { 0.000 142.857 } [get_registers { tbblue:tbblue1|zxula:ula_inst|cpu_clk_s }]
create_clock -name {tbblue:tbblue1|zxula:ula_inst|clk7_s} -period 142.857 -waveform { 0.000 71.428 } [get_registers { tbblue:tbblue1|zxula:ula_inst|clk7_s }]
create_clock -name {tbblue:tbblue1|counter[0]} -period 71.428 -waveform { 0.000 35.714 } [get_registers { tbblue:tbblue1|counter[0] }]
create_clock -name {tbblue:tbblue1|turbosound:\ts2:turbosound|NextSID:\ifsid:nextsid|sid6581:sid|clk_1MHz} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { tbblue:tbblue1|turbosound:\ts2:turbosound|NextSID:\ifsid:nextsid|sid6581:sid|clk_1MHz }]
create_clock -name {CLOCK_24[0]} -period 41.666 -waveform { 0.000 20.833 } [get_ports { CLOCK_24[0] }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll|altpll_component|pll|clk[0]} -source [get_pins {pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 14 -divide_by 25 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|pll|clk[0]}] 
create_generated_clock -name {pll|altpll_component|pll|clk[2]} -source [get_pins {pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase -45.000 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|pll|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

