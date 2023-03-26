# Just use the following commands to build the project.
# This is not a perfect makefile.
# It simply lists the minimal commands you actually need.

# make impl, this generates the bitstream file top_module.bit
# make program, this writes the bitstream to the FPGA board

program:
	vivado -nolog -nojournal -mode batch -source program.tcl

impl:
	vivado -nolog -nojournal -mode batch -source impl.tcl

# -fst is necessary to generate the waveform file, if not specified, .fst is generated but invalid
# then you can use gtkwave to open the waveform file test.fst
test:
	iverilog -g2012 -DDEBUG=1 -o test.tbi test.v top_module.v
	vvp test.tbi -fst

clean:
	$(RM) -r .Xil
	$(RM) webtalk* usage_statistics_webtalk*
	$(RM) *.fst *.tbi *.bit *.dcp
