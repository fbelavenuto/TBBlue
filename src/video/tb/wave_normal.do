onerror {resume}
quietly virtual signal -install /tb { (context /tb )(rgb_r_s & rgb_g_s & rgb_b_s & rgb_i_s )} RGBI
quietly virtual signal -install /tb { (context /tb )(rgb_i_s & rgb_r_s & rgb_g_s & rgb_b_s )} RGBI001
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_28_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/u_target/clk7_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/u_target/hc_s(8) -radix hexadecimal} {/tb/u_target/hc_s(7) -radix hexadecimal} {/tb/u_target/hc_s(6) -radix hexadecimal} {/tb/u_target/hc_s(5) -radix hexadecimal} {/tb/u_target/hc_s(4) -radix hexadecimal} {/tb/u_target/hc_s(3) -radix hexadecimal} {/tb/u_target/hc_s(2) -radix hexadecimal} {/tb/u_target/hc_s(1) -radix hexadecimal} {/tb/u_target/hc_s(0) -radix hexadecimal}} -subitemconfig {/tb/u_target/hc_s(8) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(7) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(6) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(5) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(4) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(3) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(2) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(1) {-height 15 -radix hexadecimal} /tb/u_target/hc_s(0) {-height 15 -radix hexadecimal}} /tb/u_target/hc_s
add wave -noupdate -radix hexadecimal /tb/u_target/hcd_s
add wave -noupdate /tb/mem_cs_s
add wave -noupdate /tb/mem_oe_s
add wave -noupdate -radix hexadecimal /tb/mem_addr_s
add wave -noupdate -radix hexadecimal /tb/mem_data_i_s
add wave -noupdate /tb/u_target/attr_data_load_s
add wave -noupdate -radix hexadecimal /tb/u_target/attr_data_r
add wave -noupdate /tb/u_target/attr_output_load_s
add wave -noupdate -radix hexadecimal /tb/u_target/attr_output_r
add wave -noupdate -radix hexadecimal /tb/u_target/input_to_attr_out_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_palette_addr_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_palette_dout_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_paper_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_ink_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_paper_out_s
add wave -noupdate -radix hexadecimal /tb/u_target/ulaplus_ink_out_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/rgb_ulap_s(7) -radix hexadecimal} {/tb/rgb_ulap_s(6) -radix hexadecimal} {/tb/rgb_ulap_s(5) -radix hexadecimal} {/tb/rgb_ulap_s(4) -radix hexadecimal} {/tb/rgb_ulap_s(3) -radix hexadecimal} {/tb/rgb_ulap_s(2) -radix hexadecimal} {/tb/rgb_ulap_s(1) -radix hexadecimal} {/tb/rgb_ulap_s(0) -radix hexadecimal}} -subitemconfig {/tb/rgb_ulap_s(7) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(6) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(5) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(4) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(3) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(2) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(1) {-height 15 -radix hexadecimal} /tb/rgb_ulap_s(0) {-height 15 -radix hexadecimal}} /tb/rgb_ulap_s
add wave -noupdate /tb/u_target/serializer_load_s
add wave -noupdate -radix hexadecimal /tb/u_target/bitmap_serial_r
add wave -noupdate /tb/u_target/serial_output_s
add wave -noupdate /tb/u_target/bitmap_data_load_s
add wave -noupdate -radix hexadecimal /tb/u_target/bitmap_data_r
add wave -noupdate /tb/u_target/video_en_s
add wave -noupdate /tb/u_target/border_n_s
add wave -noupdate /tb/cpu_clock_s
add wave -noupdate -radix hexadecimal /tb/cpu_addr_s
add wave -noupdate -radix hexadecimal /tb/cpu_data_i_s
add wave -noupdate -radix hexadecimal /tb/cpu_data_o_s
add wave -noupdate /tb/cpu_int_n_s
add wave -noupdate /tb/cpu_iorq_n_s
add wave -noupdate /tb/cpu_mreq_n_s
add wave -noupdate /tb/cpu_rd_n_s
add wave -noupdate /tb/cpu_wr_n_s
add wave -noupdate /tb/rgb_hblank_s
add wave -noupdate /tb/rgb_hsync_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/RGBI001(3) -radix hexadecimal} {/tb/RGBI001(2) -radix hexadecimal} {/tb/RGBI001(1) -radix hexadecimal} {/tb/RGBI001(0) -radix hexadecimal}} -subitemconfig {/tb/rgb_i_s {-radix hexadecimal} /tb/rgb_r_s {-radix hexadecimal} /tb/rgb_g_s {-radix hexadecimal} /tb/rgb_b_s {-radix hexadecimal}} /tb/RGBI001
add wave -noupdate /tb/rgb_i_s
add wave -noupdate /tb/rgb_r_s
add wave -noupdate /tb/rgb_g_s
add wave -noupdate /tb/rgb_b_s
add wave -noupdate /tb/rgb_ulap_en_s
add wave -noupdate /tb/rgb_vblank_s
add wave -noupdate /tb/rgb_vsync_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/mode_s
add wave -noupdate -radix hexadecimal /tb/kb_columns_s
add wave -noupdate /tb/ram_bank_s
add wave -noupdate /tb/speaker_s
add wave -noupdate /tb/mic_s
add wave -noupdate /tb/ear_s
add wave -noupdate /tb/turbo_en_s
add wave -noupdate /tb/ulaplus_en_s
add wave -noupdate /tb/vf50_60_s
add wave -noupdate /tb/vram_shadow_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1760 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
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
WaveRestoreZoom {0 ns} {3688 ns}
