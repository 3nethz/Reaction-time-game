# Compile all source files
xvlog bin2bcd.v
xvlog displayMuxBasys3.v
xvlog reactionTimer.v

# Compile testbench
xvlog tb_reactionTimer.v

# Elaborate
xelab tb_reactionTimer -s sim_reaction

# Run simulation
xsim sim_reaction -R
