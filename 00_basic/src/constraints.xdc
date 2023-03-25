# constraints based on pynq-z1 board

# BUTTONS
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports a];
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports b];

# LEDS
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports c];
