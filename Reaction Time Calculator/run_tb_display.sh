# Compile all source files
xvlog bin2bcd.v
xvlog displayMuxBasys3.v

# Compile testbench
xvlog tb_displayMuxBasys3.v

# Elaborate
xelab tb_displayMuxBasys3 -s sim_display

# Run simulation
xsim sim_display -R
