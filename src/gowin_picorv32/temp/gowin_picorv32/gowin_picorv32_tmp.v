//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: A
//Created Time: Thu Apr 04 22:20:08 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_PicoRV32_Top your_instance_name(
		.ser_tx(ser_tx_o), //output ser_tx
		.ser_rx(ser_rx_i), //input ser_rx
		.wbuart_tx(wbuart_tx_o), //output wbuart_tx
		.wbuart_rx(wbuart_rx_i), //input wbuart_rx
		.gpio_io(gpio_io_io), //inout [3:0] gpio_io
		.wbspi_master_miso(wbspi_master_miso_i), //input wbspi_master_miso
		.wbspi_master_mosi(wbspi_master_mosi_o), //output wbspi_master_mosi
		.wbspi_master_ssn(wbspi_master_ssn_o), //output [0:0] wbspi_master_ssn
		.wbspi_master_sclk(wbspi_master_sclk_o), //output wbspi_master_sclk
		.io_spi_clk(io_spi_clk_io), //inout io_spi_clk
		.io_spi_csn(io_spi_csn_io), //inout io_spi_csn
		.io_spi_mosi(io_spi_mosi_io), //inout io_spi_mosi
		.io_spi_miso(io_spi_miso_io), //inout io_spi_miso
		.jtag_TDI(jtag_TDI_i), //input jtag_TDI
		.jtag_TDO(jtag_TDO_o), //output jtag_TDO
		.jtag_TCK(jtag_TCK_i), //input jtag_TCK
		.jtag_TMS(jtag_TMS_i), //input jtag_TMS
		.clk_in(clk_in_i), //input clk_in
		.resetn_in(resetn_in_i) //input resetn_in
	);

//--------Copy end-------------------
