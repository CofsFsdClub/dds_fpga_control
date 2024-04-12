`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 17:48:29
// Design Name: 
// Module Name: system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system#(
)(
    input 	sys_clk,	//系统时钟
	input 	sys_rst_n,	//系统复位
 
	input 	uart_rxd,	//接收端口
	output 	uart_txd,	//发送端口
	
	output rx_finish_led,
	output tx_finish_led,
	
	output sys_lock
);
wire tx_done,rx_done;
(*mark_debug = "true"*)wire data_rx_vld;
(*mark_debug = "true"*)wire [7:0] data_rx_byte;

wire [2:0] baud;
wire [7:0] data_tx;
(*mark_debug = "true"*)wire send_start;

wire key_signal;
assign key_signal = 1'b0;
wire sys_clk;

    uart_crtl uart_ctrl(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .key_in(key_signal),

    .data_in(data_rx_byte),
    .data_in_vld(data_rx_vld),
    .tx_finish(tx_done),
    .baud(),
    .data_out(data_tx),
    .tx_en(send_start)
    );
 assign baud = 3'b100;
    uart_tx_byte uart_tx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .baud_set(baud),//[2:0]
    .send_en(send_start),
    .data_in(data_tx),//[7:0]

    .data_out(uart_txd),
    .tx_done(tx_done));

assign tx_finish_led = !tx_done;

    uart_rx_byte uart_rx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .baud_set(baud),
    .din_bit(uart_rxd),

    .data_byte(data_rx_byte),
    .dout_vld(data_rx_vld)
    );

assign rx_finish_led = !data_rx_vld;

ila_0 ila1 (
	.clk(sys_clk), // input wire clk
	.probe0(
	{
	data_rx_byte,
	data_tx,
	baud,
	data_rx_vld,
	data_tx_vld,
	tx_done,
	send_start,
	sys_lock
	}) // input wire [511:0] probe0
);
 
endmodule