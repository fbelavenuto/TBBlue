onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate /tb/cs_s
add wave -noupdate /tb/wr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/has_data_s
add wave -noupdate -radix hexadecimal /tb/audio_s
add wave -noupdate -divider nextsid
add wave -noupdate /tb/i1/addr_i
add wave -noupdate /tb/i1/sid_addr_s
add wave -noupdate /tb/i1/sid_cs_s
add wave -noupdate -divider sid
add wave -noupdate -radix hexadecimal /tb/i1/sid/addr_i
add wave -noupdate -radix hexadecimal /tb/i1/sid/Filter_Fc_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Filter_Fc_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Filter_Mode_Vol
add wave -noupdate -radix hexadecimal /tb/i1/sid/Filter_Res_Filt
add wave -noupdate -radix hexadecimal /tb/i1/sid/Misc_Env3
add wave -noupdate -radix hexadecimal /tb/i1/sid/Misc_Osc3_Random
add wave -noupdate -radix hexadecimal /tb/i1/sid/Misc_PotX
add wave -noupdate -radix hexadecimal /tb/i1/sid/Misc_PotY
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Att_dec
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Control
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Freq_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Freq_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Pw_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Pw_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_1_Sus_Rel
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Att_dec
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Control
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Freq_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Freq_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Pw_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Pw_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_2_Sus_Rel
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Att_dec
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Control
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Freq_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Freq_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Pw_hi
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Pw_lo
add wave -noupdate -radix hexadecimal /tb/i1/sid/Voice_3_Sus_Rel
add wave -noupdate /tb/i1/sid/clk_1MHz
add wave -noupdate -radix hexadecimal /tb/i1/sid/data_i
add wave -noupdate -radix hexadecimal /tb/i1/sid/data_o
add wave -noupdate /tb/i1/sid/do_buf
add wave -noupdate /tb/i1/sid/voice_1
add wave -noupdate /tb/i1/sid/voice_1_PA_MSB
add wave -noupdate /tb/i1/sid/voice_2
add wave -noupdate /tb/i1/sid/voice_2_PA_MSB
add wave -noupdate /tb/i1/sid/voice_3
add wave -noupdate /tb/i1/sid/voice_3_PA_MSB
add wave -noupdate /tb/i1/sid/voice_mixed
add wave -noupdate /tb/i1/sid/voice_volume
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1363 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 296
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
WaveRestoreZoom {0 ns} {7040 ns}
