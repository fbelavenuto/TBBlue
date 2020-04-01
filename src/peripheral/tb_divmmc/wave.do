onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/reset_i
add wave -noupdate -radix hexadecimal /tb/di
add wave -noupdate -radix hexadecimal /tb/do
add wave -noupdate /tb/dout
add wave -noupdate /tb/cpu_ioreq_n
add wave -noupdate /tb/nmi_button_n
add wave -noupdate /tb/nmi_to_cpu_n
add wave -noupdate /tb/no_automap
add wave -noupdate -radix hexadecimal /tb/ram_bank
add wave -noupdate /tb/spi_cs
add wave -noupdate /tb/sd_cs0
add wave -noupdate /tb/sd_miso
add wave -noupdate /tb/sd_mosi
add wave -noupdate /tb/sd_sclk
add wave -noupdate -divider memsw
add wave -noupdate /tb/ram_en
add wave -noupdate /tb/rom_en
add wave -noupdate /tb/clock
add wave -noupdate -radix hexadecimal /tb/cpu_a
add wave -noupdate /tb/cpu_m1_n
add wave -noupdate /tb/cpu_mreq_n
add wave -noupdate /tb/cpu_rd_n
add wave -noupdate /tb/cpu_wr_n
add wave -noupdate /tb/u_target/automap
add wave -noupdate /tb/u_target/mapcond
add wave -noupdate /tb/u_target/mapterm
add wave -noupdate -radix hexadecimal /tb/u_target/portE3_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {855 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 283
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {8384 ns}
