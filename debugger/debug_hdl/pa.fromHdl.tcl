
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name debug_hdl -dir "/home/chris/Documents/tek7854mpu/debugger/debug_hdl/planAhead_run_1" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "toplevel.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {serial_tx.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {toplevel.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top toplevel $srcset
add_files [list {toplevel.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
