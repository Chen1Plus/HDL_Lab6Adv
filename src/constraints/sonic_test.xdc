# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

# Buttons
set_property PACKAGE_PIN U18 [get_ports rst]
    set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Pmod Header JB
# Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {sonic_trig}]
    set_property IOSTANDARD LVCMOS33 [get_ports {sonic_trig}]
# Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {sonic_echo}]
    set_property IOSTANDARD LVCMOS33 [get_ports {sonic_echo}]

## Don't Touch
# set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# set_property CONFIG_MODE SPIx4 [current_design]
# set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

## where 3.3 is the voltage provided to configuration bank 0
set_property CONFIG_VOLTAGE 3.3 [current_design]
## where value1 is either VCCO(for Vdd=3.3) or GND(for Vdd=1.8)
set_property CFGBVS VCCO [current_design]

#set_property PACKAGE_PIN V16 [get_ports speed]
#set_property IOSTANDARD LVCMOS33 [get_ports speed]
#set_property PACKAGE_PIN V16 [get_ports dir]
#set_property IOSTANDARD LVCMOS33 [get_ports dir]
#set_property PACKAGE_PIN V17 [get_ports en]
#set_property IOSTANDARD LVCMOS33 [get_ports en]
#set_property PACKAGE_PIN W16 [get_ports rst]
#set_property IOSTANDARD LVCMOS33 [get_ports rst]