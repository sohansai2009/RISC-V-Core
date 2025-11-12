#set the top module name
set top_mod yarp_top

#define the clock name
set clk_name clk

#set the directory
set RTL_DIR ./

#read the verilog file
analyze -format sverilog \
		"$RTL_DIR/yarp_pkg.sv \
		 $RTL_DIR/yarp_top.sv \
		 $RTL_DIR/yarp_fetch.sv \
    		 $RTL_DIR/yarp_decode.sv \
		 $RTL_DIR/yarp_reg_file.sv \
		 $RTL_DIR/yarp_execute.sv \
		 $RTL_DIR/yarp_memory.sv \
		 $RTL_DIR/yarp_control.sv \
		 $RTL_DIR/yarp_branchcontrol.sv"
		
elaborate yarp_top
link

#set the current design as top module
current_design yarp_top

#set clock period
set clk_per 10

#set the clock skew
set clk_skew 0.3

#create clock
create_clock -name $clk_name -period $clk_per -wavform "0 [expr $clk_per/2]" $clk_name

#define clock uncertainity
set_clock_uncertainity $clk_skew $clk_per


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
#report the timing
report_timing -delay min -max_paths 10 > yarp_synth_timing.rpt
quit

