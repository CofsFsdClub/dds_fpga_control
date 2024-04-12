set_property PACKAGE_PIN F20 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN F16 [get_ports uart_rxd]
set_property PACKAGE_PIN L15 [get_ports uart_txd]

#set_property IOSTANDARD LVCMOS33 [get_ports tx_finish_led]
#set_property PACKAGE_PIN T14 [get_ports rx_finish_led]
#set_property PACKAGE_PIN G15 [get_ports tx_finish_led]

set_property IOSTANDARD LVCMOS33 [get_ports sys_50m]
set_property PACKAGE_PIN U18 [get_ports sys_50m]

set_property IOSTANDARD LVCMOS33 [get_ports sys_lock]
set_property PACKAGE_PIN J14 [get_ports sys_lock]

#set_property IOSTANDARD LVCMOS33 [get_ports rx_finish_led]
set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets sys_clk]
