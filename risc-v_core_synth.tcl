#set the top design
set top_design yarp_top 

#set the clock
set clk_name clk

#set the rtl directory
set RTL_DIR ./

#read the system verilog file
analyze -format sverilog \
                "$RTL_DIR/yarp_pkg.sv \
                 $RTL_DIR/yarp_top.sv \
                 $RTL_DIR/yarp_fetch.sv \
                 $RTL_DIR/cache_top.sv \
                 $RTL_DIR/cache_decoder.sv \
                 $RTL_DIR/cache_lookup.sv \
                 $RTL_DIR/cache_controller.sv \
                 $RTL_DIR/Instruction_Memory.sv \
                 $RTL_DIR/yarp_decode.sv \
                 $RTL_DIR/yarp_reg_file.sv \
                 $RTL_DIR/yarp_control.sv \
                 $RTL_DIR/yarp_execute.sv \
                 $RTL_DIR/d_cache_top.sv \
                 $RTL_DIR/d_cache_decode.sv \
                 $RTL_DIR/d_cache_lookup.sv \
                 $RTL_DIR/d_cache_control.sv \
                 $RTL_DIR/data_mem.sv"

#elaborate the top module and link it
elaborate yarp_top
link

#set the current design as yarp_top
current_design yarp_top

#set the clk per
set clk_per 3

#set the clock skew
set clk_skew 0.1

#create the clock
create_clock -name $clk_name -period $clk_per -waveform "0 [expr $clk_per/2]" $clk_name

#set clock uncertainity (usually skew + jitter)
set_clock_uncertainity $clk_skew $clk_name 

#*******************#
#set the target library
set OSU_FREEPDK [format "%s%s"  [getenv "PDK_DIR"] "/osu_soc/lib/files"]
set search_path [concat  $search_path $OSU_FREEPDK]
set alib_library_analysis_path $OSU_FREEPDK
set link_library [set target_library [concat  [list gscl45nm.db] [list dw_foundation.sldb]]]
set target_library "gscl45nm.db"
define_design_lib WORK -path ./WORK
set verilogout_show_unconnected_pins "true"
#compile the design
compile -map_effort medium

#report overall timing
report_timing > yarp_core_mem_timing.rpt


#use through method to report the timing paths of the signals connected to u_cache_top/in_req

report_timing \
-through [get_pins -hier u_cache_top/in_req] \
-max_paths 5 > path1.rpt


##use through method to report the timing paths of the signals connected to u_cache_top/data_out_cache_top
report_timing \
-through [get_pins -hier u_cache_top/data_out_cache_top] \
-max_paths 5 > path2.rpt

report_timing \
-through [get_pins -hier u_yarp_instr_mem/mem_rd_data_i] \
-max_paths 5 > path3.rpt
## the below timing analysis means that, 'caucluate timign from any flop to the instr_mem_instr_o_reg/d and the path should go through mem_rd_data_i
report_timing \
  -from [get_clocks clk] \
  -through [get_pins -hier u_yarp_instr_mem/mem_rd_data_i] \
  -to [get_pins -hier instr_mem_instr_o] \
  -max_paths 5 > cache_if_path.rpt

#see how dc uses/calls the pins which has the string 'instr_mem_req'
get_nets -hier *instr_mem_req*
get_pins -hier *in_addr*
get_nets -hier *instr_mem_rd_data*
get_pins -hier *data_out*

quit


