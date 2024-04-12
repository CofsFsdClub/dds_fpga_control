`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/01 02:13:58
// Design Name: 
// Module Name: uart_echo
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

/*
    uart_echo #(.clock_freq(),.baud_rate()) UART_ECHO0(
        .tx(),
        .rx(),
        .clk(),
        .rst()
        );
*/

module uart_echo #(parameter clock_freq = 100_000_000,baud_rate = 115200) (
    output tx,
    input rx,
    input clk,
    input rst
    );
    
    wire tx_done;
    wire rx_rec_flag;
    wire[7:0] rx_data;
    wire[7:0] tx_data;
    
    uart_const_baud_rx #(.clock_freq(clock_freq),.baud_rate(baud_rate)) UART_RX0(
        .data(rx_data),
        .data_rec(rx_rec_flag),
        .rx(rx),
        .clr(tx_idle),
        .clk(clk),
        .rst(rst)
    );
    
    uart_const_baud_tx #(.clock_freq(clock_freq),.baud_rate(baud_rate)) UART_TX0(
        .tx(tx),
        .tx_idle(tx_idle),
        .tx_start(rx_rec_flag),
        .tx_data(rx_data),
        .clk(clk),
        .rst(rst)
    );
    
endmodule