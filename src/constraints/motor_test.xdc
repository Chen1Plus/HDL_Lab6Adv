## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
##   (if you are using the editor in Vivado, you can select lines and hit "Ctrl + /" to comment/uncomment.)
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

# Buttons
 set_property PACKAGE_PIN U18 [get_ports rst]
    set_property IOSTANDARD LVCMOS33 [get_ports rst]
# set_property PACKAGE_PIN T18 [get_ports btn_up]
#    set_property IOSTANDARD LVCMOS33 [get_ports btn_up]
# set_property PACKAGE_PIN W19 [get_ports btnL]
#    set_property IOSTANDARD LVCMOS33 [get_ports btnL]
# set_property PACKAGE_PIN T17 [get_ports btnR]
#    set_property IOSTANDARD LVCMOS33 [get_ports btnR]
# set_property PACKAGE_PIN U17 [get_ports btn_down]
#    set_property IOSTANDARD LVCMOS33 [get_ports btn_down]


## Pmod Header JA
## Sch name = JA1
 set_property PACKAGE_PIN J1 [get_ports {IN1}]
    set_property IOSTANDARD LVCMOS33 [get_ports {IN1}]
## Sch name = JA2
 set_property PACKAGE_PIN L2 [get_ports {IN2}]
    set_property IOSTANDARD LVCMOS33 [get_ports {IN2}]
## Sch name = JA3
 set_property PACKAGE_PIN J2 [get_ports {IN3}]
    set_property IOSTANDARD LVCMOS33 [get_ports {IN3}]
## Sch name = JA4
 set_property PACKAGE_PIN G2 [get_ports {IN4}]
    set_property IOSTANDARD LVCMOS33 [get_ports {IN4}]
## Sch name = JA7
 set_property PACKAGE_PIN H1 [get_ports {left_pwm}]
    set_property IOSTANDARD LVCMOS33 [get_ports {left_pwm}]
## Sch name = JA8
 set_property PACKAGE_PIN K2 [get_ports {right_pwm}]
    set_property IOSTANDARD LVCMOS33 [get_ports {right_pwm}]
## Sch name = JA9
# set_property PACKAGE_PIN H2 [get_ports {PWM_1}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {PWM_1}]
## Sch name = JA10
# set_property PACKAGE_PIN G3 [get_ports {sw0}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw0}]


## where 3.3 is the voltage provided to configuration bank 0
set_property CONFIG_VOLTAGE 3.3 [current_design]
## where value1 is either VCCO(for Vdd=3.3) or GND(for Vdd=1.8)
set_property CFGBVS VCCO [current_design]

