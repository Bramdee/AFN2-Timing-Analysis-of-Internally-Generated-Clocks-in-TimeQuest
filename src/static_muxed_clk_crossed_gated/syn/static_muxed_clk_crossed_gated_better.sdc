# Define clocks
create_clock -period 5 -name iClkA [get_ports iClkA]
create_clock -period 10 -name iClkB [get_ports iClkB]

# Define generated clocks
create_generated_clock [get_pins {TheMuxedClk0|altclkctrl_0|MuxedClock_altclkctrl_0_sub_component|sd1|outclk}] \
    -name clk_mux_a \
    -source [get_ports {iClkA}] \
    -master_clock [get_clocks {iClkA}]

create_generated_clock [get_pins {TheMuxedClk0|altclkctrl_0|MuxedClock_altclkctrl_0_sub_component|sd1|outclk}] \
    -name clk_mux_b \
    -add \
    -source [get_ports {iClkB}] \
    -master_clock [get_clocks {iClkB}]


# Tell timing the Timing Analyzer that the defined clocks are unrelated
# This is needed for propper timing analysis of Multiplexed Clocks
# Multiplexed Clocks are unrealated because they share the same path but will never used together.
# Not seperating those two clocks would lead to wrong timing analysis
set_clock_groups \
    -exclusive \
    -group {clk_mux_a} \
    -group {clk_mux_b} 