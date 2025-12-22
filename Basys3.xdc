## ----------------------------------------------------------------------------
## Clock (Unchanged)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## ----------------------------------------------------------------------------
## Pmod Header JA (Used for ESP32 Connection)
## Replaces previous Buttons and onboard LED
## ----------------------------------------------------------------------------
# JA1 -> Connected to ESP32 Pin 4 (START Signal)
set_property PACKAGE_PIN J1 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

# JA2 -> Connected to ESP32 Pin 5 (STOP Signal)
set_property PACKAGE_PIN L2 [get_ports stop]
set_property IOSTANDARD LVCMOS33 [get_ports stop]

# JA3 -> Connected to ESP32 Pin 6 (CLEAR Signal)
set_property PACKAGE_PIN J2 [get_ports clear]
set_property IOSTANDARD LVCMOS33 [get_ports clear]

# JA4 -> Connected to ESP32 Pin 7 (LED Status Output)
set_property PACKAGE_PIN G2 [get_ports led_esp]
set_property IOSTANDARD LVCMOS33 [get_ports led_esp]


## ----------------------------------------------------------------------------
## 7-Segment Display (Unchanged)
## ----------------------------------------------------------------------------
# Anodes
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]

# Segments (Cathodes)
set_property PACKAGE_PIN W7 [get_ports {sseg[6]}]
set_property PACKAGE_PIN W6 [get_ports {sseg[5]}]
set_property PACKAGE_PIN U8 [get_ports {sseg[4]}]
set_property PACKAGE_PIN V8 [get_ports {sseg[3]}]
set_property PACKAGE_PIN U5 [get_ports {sseg[2]}]
set_property PACKAGE_PIN V5 [get_ports {sseg[1]}]
set_property PACKAGE_PIN U7 [get_ports {sseg[0]}]
set_property PACKAGE_PIN V7 [get_ports {sseg[7]}] 
# Note: sseg[7] is the Decimal Point (DP)

set_property IOSTANDARD LVCMOS33 [get_ports {an[*] sseg[*]}]


## ----------------------------------------------------------------------------
## DISABLED
## ----------------------------------------------------------------------------
## Old Button Mappings
# set_property PACKAGE_PIN U18 [get_ports start]
# set_property PACKAGE_PIN T18 [get_ports stop]
# set_property PACKAGE_PIN W19 [get_ports clear]

## Old LED Mapping
set_property PACKAGE_PIN U16 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]