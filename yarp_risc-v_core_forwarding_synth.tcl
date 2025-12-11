
#set the top mod
set top_mod yarp_top

#set the clk
set clk_name clk

#set the RTL directory
set RTL_DIR ./

#read the system verilog files
analyze -format sverilog \
"$RTL_DIR/yarp_pkg.sv \
 $RTL_DIR/yarp_top.sv \
 $RTL_DIR/yarp_fetch.sv \
 $RTL_DIR/if_id_pipeline.sv \
 $RTL_DIR/yarp_decode.sv \
 $RTL_DIR/hazard_detection.sv \
 $RTL_DIR/yarp_reg_file.sv \
 $RTL_DIR/yarp_control.sv \
 $RTL_DIR/id_ex_pipeline.sv \
 $RTL_DIR/yarp_execute.sv \
 $RTL_DIR/ex_mem_pipeline.sv \
 $RTL_DIR/yarp_memory.sv \
 $RTL_DIR/mem_wb_pipeline.sv "

#eleborate all the submodules instantiated inside yarp_top.sv and link them as mentioned in yarp_top.sv
elaborate yarp_top
link

#define the clock period
set clk_per 5

#set clock skew
set clk_skew 0.2
#create the clock
create_clock -name $clk_name -period $clk_per -waveform "0 [expr $clk_per/2]" $clk_name

#set the top module as current design
current_design yarp_top

#set clock uncertainity
set_clock_uncertainity $clk_skew $clk_per

#define the technology files and everything
set OSU_FREEPDK [format "%s%s"  [getenv "PDK_DIR"] "/osu_soc/lib/files"]
set search_path [concat  $search_path $OSU_FREEPDK]
set alib_library_analysis_path $OSU_FREEPDK
set link_library [set target_library [concat  [list gscl45nm.db] [list dw_foundation.sldb]]]
set target_library "gscl45nm.db"
define_design_lib WORK -path ./WORK
set verilogout_show_unconnected_pins "true"
#compile the design
compile -map_effort medium
#report the timing -> setup violation
report_timing -max_paths 10 > yarp_synth_hazard_detection_forwarding_setup_analysis.rpt

#report power
report_power > yarp_synth_no_pipelining_power.rpt
quit
