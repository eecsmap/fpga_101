## using Vivado to target the pynq-z1 board

# synthesis
read_verilog -v top_module.v
read_xdc constraints.xdc
synth_design -top top_module -part xc7z020clg400-1

# implementation
opt_design
place_design
phys_opt_design
route_design
write_bitstream -force top_module.bit
