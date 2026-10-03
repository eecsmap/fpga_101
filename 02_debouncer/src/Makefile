build:
	vivado -nolog -nojournal -mode batch -source build.tcl

test:
	iverilog -g2012 -o testbench.vvp testbench.v z1top.v debouncer.v synchronizer.v edge_detector.v button_parser.v
	vvp testbench.vvp

clean:
	$(RM) -r .Xil
	$(RM) webtalk* usage_statistics_webtalk*
	$(RM) *.vcd *.vvp *.bit *.dcp
