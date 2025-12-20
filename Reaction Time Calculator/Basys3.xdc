# Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

# Reset button
set_property LOC V17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Buttons
set_property PACKAGE_PIN U18 [get_ports start]
set_property PACKAGE_PIN T18 [get_ports stop]
set_property PACKAGE_PIN W19 [get_ports clear]
set_property IOSTANDARD LVCMOS33 [get_ports {start stop clear}]

# LED
set_property PACKAGE_PIN U16 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

# 7-segment anodes
set_property PACKAGE_PIN U2 [get_ports an[0]]
set_property PACKAGE_PIN U4 [get_ports an[1]]
set_property PACKAGE_PIN V4 [get_ports an[2]]
set_property PACKAGE_PIN W4 [get_ports an[3]]

# 7-segment segments
set_property PACKAGE_PIN U7 [get_ports sseg[0]]
set_property PACKAGE_PIN V5 [get_ports sseg[1]]
set_property PACKAGE_PIN U5 [get_ports sseg[2]]
set_property PACKAGE_PIN V8 [get_ports sseg[3]]
set_property PACKAGE_PIN U8 [get_ports sseg[4]]
set_property PACKAGE_PIN W6 [get_ports sseg[5]]
set_property PACKAGE_PIN W7 [get_ports sseg[6]]
set_property PACKAGE_PIN V7 [get_ports sseg[7]]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*] sseg[*]}]

# VGA RGB
set_property PACKAGE_PIN N18 [get_ports rgb[0]]
set_property PACKAGE_PIN L18 [get_ports rgb[1]]
set_property PACKAGE_PIN K18 [get_ports rgb[2]]
set_property PACKAGE_PIN J18 [get_ports rgb[3]]
set_property PACKAGE_PIN J17 [get_ports rgb[4]]
set_property PACKAGE_PIN H17 [get_ports rgb[5]]
set_property PACKAGE_PIN G17 [get_ports rgb[6]]
set_property PACKAGE_PIN D17 [get_ports rgb[7]]
set_property PACKAGE_PIN G19 [get_ports rgb[8]]
set_property PACKAGE_PIN H19 [get_ports rgb[9]]
set_property PACKAGE_PIN J19 [get_ports rgb[10]]
set_property PACKAGE_PIN N19 [get_ports rgb[11]]

# VGA sync
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[*] hsync vsync}]
