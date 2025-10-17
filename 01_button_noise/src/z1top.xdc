set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {BUTTON}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {LED}]

# Override clock dedicated route constraint for button as clock
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets BUTTON_IBUF]
 