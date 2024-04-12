`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Çç¿Õ-Tiso£¨BÕ¾Í¬Ãû£©
// 
// Create Date: 2023/12/29 02:00:46
// Design Name: 
// Module Name: uart_const_baud
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
    uart_const_baud #(.clock_freq(),.baud_rate()) UART0(
        .rx_data(),
        .rx_rec_flag(),
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_data(),
        .tx_start(),
        .rx(),
        .rx_clr(),
        .clk(),
        .rst()
    );
*/

module uart_const_baud #(parameter clock_freq = 100_000_000,baud_rate = 115200) (
    output[7:0] rx_data,
    output rx_rec_flag,
    output tx,
    output tx_done,
    output tx_idle,
    input[7:0] tx_data,
    input tx_start,
    input rx,
    input rx_clr,
    input clk,
    input rst
    );
    
    uart_const_baud_rx #(.clock_freq(clock_freq),.baud_rate(baud_rate)) UART_RX0(
        .data(rx_data),
        .data_rec(rx_rec_flag),
        .rx(rx),
        .clr(rx_clr),
        .clk(clk),
        .rst(rst)
    );
    
    uart_const_baud_tx #(.clock_freq(clock_freq),.baud_rate(baud_rate)) UART_TX0(
        .tx(tx),
        .tx_done(tx_done),
        .tx_idle(tx_idle),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .clk(clk),
        .rst(rst)
    );
    
endmodule
