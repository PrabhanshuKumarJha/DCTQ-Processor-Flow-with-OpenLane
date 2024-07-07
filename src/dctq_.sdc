# Define clocks
create_clock -name pci_clk -period 100 [get_ports pci_clk]  
create_clock -name clk -period 100 [get_ports clk]

# Input and output delay constraints
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports di]
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports wa]
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports be]
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports start]
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports din_valid]
set_input_delay -clock [get_clocks pci_clk] 0.1 [get_ports hold]
set_input_delay -clock [get_clocks clk] 0.1 [get_ports reset_n]

set_output_delay -clock [get_clocks pci_clk] 0.1 [get_ports ready]
set_output_delay -clock [get_clocks pci_clk] 0.1 [get_ports dctq_valid]
set_output_delay -clock [get_clocks pci_clk] 0.1 [get_ports dctq1]
set_output_delay -clock [get_clocks pci_clk] 0.1 [get_ports addr]

# Set load for output ports
set_load 0.1 [get_ports ready]
set_load 0.1 [get_ports dctq_valid]
set_load 0.1 [get_ports dctq1]
set_load 0.1 [get_ports addr]

# Max and min delay constraints
set_max_delay 1 -from [get_ports start] -to [get_ports ready]
set_min_delay 0.5 -from [get_ports start] -to [get_ports ready]

# Clock uncertainty (if needed)
set_clock_uncertainty 0.001 [get_clocks pci_clk]
set_clock_uncertainty 0.001 [get_clocks clk]
 





