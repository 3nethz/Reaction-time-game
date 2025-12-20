# Compile all source files
xvlog bin2bcd.v
xvlog displayMuxBasys3.v
xvlog reactionTimer.v

# Compile testbench
xvlog tb_bin2bcd.v

# Elaborate
xelab tb_bin2bcd -s sim_bin2bcd

# Run simulation
xsim sim_bin2bcd -R
