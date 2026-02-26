set_property PACKAGE_PIN U18 [get_ports clk_in]
set_property PACKAGE_PIN W15 [get_ports rst]
set_property PACKAGE_PIN L15 [get_ports rx_in]
set_property PACKAGE_PIN N16 [get_ports tx_out]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rx_in]
set_property IOSTANDARD LVCMOS33 [get_ports tx_out]



set_property DRIVE 12 [get_ports tx_out]



set_property IOSTANDARD LVCMOS33 [get_ports {led_cmd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_cmd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_cmd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_cmd[0]}]
set_property PACKAGE_PIN P20 [get_ports {led_cmd[3]}]
set_property PACKAGE_PIN N20 [get_ports {led_cmd[2]}]
set_property PACKAGE_PIN P16 [get_ports {led_cmd[1]}]
set_property PACKAGE_PIN P15 [get_ports {led_cmd[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports fwd]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_out]
set_property PACKAGE_PIN N15 [get_ports fwd]
set_property PACKAGE_PIN K14 [get_ports pwm_out]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_wiz_out]

set_property IOSTANDARD LVCMOS33 [get_ports INA]
set_property IOSTANDARD LVCMOS33 [get_ports INB]
set_property PACKAGE_PIN N15 [get_ports INA]
set_property PACKAGE_PIN K14 [get_ports INB]
