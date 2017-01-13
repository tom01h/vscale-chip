create_clock -period 10.000 -name clk -waveform {0.000 5.000}


create_clock -period 10.000 -name clk_1 -waveform {0.000 5.000} [get_ports clk]


set_property PACKAGE_PIN E3 [get_ports clk]
set_property PACKAGE_PIN A9 [get_ports RXD]
set_property PACKAGE_PIN D10 [get_ports TXD]
set_property PACKAGE_PIN C2 [get_ports rstn]


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports RXD]
set_property IOSTANDARD LVCMOS33 [get_ports TXD]

