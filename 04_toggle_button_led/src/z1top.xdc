# Clock signal 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { CLK_125MHZ_FPGA }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { CLK_125MHZ_FPGA }];

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {BUTTON}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {LED}]
