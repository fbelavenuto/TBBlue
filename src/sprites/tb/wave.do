onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_master_s
add wave -noupdate /tb/i1/clock_mem_s
add wave -noupdate /tb/clock_pixel_s
add wave -noupdate -radix unsigned /tb/hcounter_s
add wave -noupdate -radix unsigned /tb/vcounter_s
add wave -noupdate -radix hexadecimal /tb/rgb_s
add wave -noupdate /tb/pixel_en_s
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/i1/state_s
add wave -noupdate -radix unsigned /tb/i1/sprite_cnt_q
add wave -noupdate -radix unsigned /tb/i1/sprite_idx_q
add wave -noupdate -radix hexadecimal -childformat {{/tb/i1/sprite_xpos_q(0) -radix hexadecimal} {/tb/i1/sprite_xpos_q(1) -radix hexadecimal} {/tb/i1/sprite_xpos_q(2) -radix hexadecimal} {/tb/i1/sprite_xpos_q(3) -radix hexadecimal} {/tb/i1/sprite_xpos_q(4) -radix hexadecimal} {/tb/i1/sprite_xpos_q(5) -radix hexadecimal} {/tb/i1/sprite_xpos_q(6) -radix hexadecimal} {/tb/i1/sprite_xpos_q(7) -radix hexadecimal}} -subitemconfig {/tb/i1/sprite_xpos_q(0) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(1) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(2) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(3) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(4) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(5) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(6) {-height 15 -radix hexadecimal} /tb/i1/sprite_xpos_q(7) {-height 15 -radix hexadecimal}} /tb/i1/sprite_xpos_q
add wave -noupdate /tb/i1/sprite_pwe_q
add wave -noupdate -radix hexadecimal -childformat {{/tb/i1/sprite_paddr_q(0) -radix hexadecimal} {/tb/i1/sprite_paddr_q(1) -radix hexadecimal} {/tb/i1/sprite_paddr_q(2) -radix hexadecimal} {/tb/i1/sprite_paddr_q(3) -radix hexadecimal} {/tb/i1/sprite_paddr_q(4) -radix hexadecimal} {/tb/i1/sprite_paddr_q(5) -radix hexadecimal} {/tb/i1/sprite_paddr_q(6) -radix hexadecimal} {/tb/i1/sprite_paddr_q(7) -radix hexadecimal}} -subitemconfig {/tb/i1/sprite_paddr_q(0) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(1) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(2) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(3) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(4) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(5) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(6) {-height 15 -radix hexadecimal} /tb/i1/sprite_paddr_q(7) {-height 15 -radix hexadecimal}} /tb/i1/sprite_paddr_q
add wave -noupdate -radix hexadecimal -childformat {{/tb/i1/sprite_pdi_q(0) -radix hexadecimal} {/tb/i1/sprite_pdi_q(1) -radix hexadecimal} {/tb/i1/sprite_pdi_q(2) -radix hexadecimal} {/tb/i1/sprite_pdi_q(3) -radix hexadecimal} {/tb/i1/sprite_pdi_q(4) -radix hexadecimal} {/tb/i1/sprite_pdi_q(5) -radix hexadecimal} {/tb/i1/sprite_pdi_q(6) -radix hexadecimal} {/tb/i1/sprite_pdi_q(7) -radix hexadecimal}} -subitemconfig {/tb/i1/sprite_pdi_q(0) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(1) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(2) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(3) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(4) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(5) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(6) {-height 15 -radix hexadecimal} /tb/i1/sprite_pdi_q(7) {-height 15 -radix hexadecimal}} /tb/i1/sprite_pdi_q
add wave -noupdate -radix hexadecimal /tb/i1/addr_attr_s
add wave -noupdate -radix unsigned -childformat {{/tb/i1/data_attr_s(7) -radix unsigned} {/tb/i1/data_attr_s(6) -radix unsigned} {/tb/i1/data_attr_s(5) -radix unsigned} {/tb/i1/data_attr_s(4) -radix unsigned} {/tb/i1/data_attr_s(3) -radix unsigned} {/tb/i1/data_attr_s(2) -radix unsigned} {/tb/i1/data_attr_s(1) -radix unsigned} {/tb/i1/data_attr_s(0) -radix unsigned}} -subitemconfig {/tb/i1/data_attr_s(7) {-radix unsigned} /tb/i1/data_attr_s(6) {-radix unsigned} /tb/i1/data_attr_s(5) {-radix unsigned} /tb/i1/data_attr_s(4) {-radix unsigned} /tb/i1/data_attr_s(3) {-radix unsigned} /tb/i1/data_attr_s(2) {-radix unsigned} /tb/i1/data_attr_s(1) {-radix unsigned} /tb/i1/data_attr_s(0) {-radix unsigned}} /tb/i1/data_attr_s
add wave -noupdate -radix hexadecimal /tb/i1/addr_pat_s
add wave -noupdate -radix hexadecimal /tb/i1/data_pat_s
add wave -noupdate /tb/i1/addr_cpl_s
add wave -noupdate -radix unsigned /tb/i1/addr_pat_w_s
add wave -noupdate -radix decimal /tb/i1/D_screen_y_v
add wave -noupdate -radix unsigned /tb/i1/D_screen_y_spt_v
add wave -noupdate /tb/i1/spt_coll_s
add wave -noupdate /tb/i1/spt_coll_q
add wave -noupdate /tb/i1/spt_maxl_s
add wave -noupdate /tb/i1/spt_maxl_q
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb/cpu_a_s
add wave -noupdate -radix hexadecimal /tb/cpu_d_i_s
add wave -noupdate /tb/has_data_s
add wave -noupdate -radix hexadecimal /tb/cpu_d_o_s
add wave -noupdate /tb/cpu_iorq_n_s
add wave -noupdate /tb/cpu_rd_n_s
add wave -noupdate /tb/cpu_wr_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {468 ns} 0}
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
WaveRestoreZoom {0 ns} {1760 ns}
