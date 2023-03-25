## using Vivado to target the pynq-z1 board

# load program
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target

set_property PROGRAM.FILE top_module.bit [get_hw_devices xc7z*]
program_hw_devices [get_hw_devices xc7z*]
refresh_hw_device [get_hw_devices xc7z*]

close_hw_manager
