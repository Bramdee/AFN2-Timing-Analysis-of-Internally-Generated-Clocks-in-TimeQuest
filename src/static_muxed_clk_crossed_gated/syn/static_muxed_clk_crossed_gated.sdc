# Define clocks
create_clock -period 5 [get_ports iClkA]
create_clock -period 10 [get_ports iClkB]

# Tell timing the Timing Analyzer that the defined clocks are unrelated
# This is needed for propper timing analysis of Multiplexed Clocks
# Multiplexed Clocks are unrealated because they share the same path but will never used together.
# Not seperating those two clocks would lead to wrong timing analysis
set_clock_groups \
    -exclusive \
    -group {iClkA} \
    -group {iClkB} 