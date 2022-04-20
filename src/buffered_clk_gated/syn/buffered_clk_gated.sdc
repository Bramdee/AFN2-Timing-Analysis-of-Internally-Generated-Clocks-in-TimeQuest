# Define Clocks
create_clock -period 20 [get_ports CLOCK_50]
create_clock -period 20 [get_ports GPIO_0_0]

# Create Generated Clock
derive_pll_clocks

# Set Clock Uncertainty
derive_clock_uncertainty

