# synthesis
read_verilog -v z1top.v
read_xdc z1top.xdc
synth_design -top z1top -part xc7z020clg400-1

# implementation
opt_design
place_design
phys_opt_design
route_design
write_bitstream -force z1top.bit

# load program
source [file dirname [info script]]/program.tcl
