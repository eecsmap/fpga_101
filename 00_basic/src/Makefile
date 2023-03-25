# Just use the following commands to build the project.
# This is not a perfect makefile.
# It simply lists the minimal commands you actually need.

# make impl, this generates the bitstream file top_module.bit
# make program, this writes the bitstream to the FPGA board

program:
	vivado -nolog -nojournal -mode batch -source program.tcl

impl:
	vivado -nolog -nojournal -mode batch -source impl.tcl

clean:
	$(RM) -r .Xil
	$(RM) usage_statistics_webtalk*
	$(RM) webtalk*
	$(RM) *.bit
