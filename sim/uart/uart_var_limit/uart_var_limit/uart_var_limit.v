`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/31 18:54:13
// Design Name: 
// Module Name: uart_var_limit
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
    uart_var_limit #(.clock_freq(),.limit_width()) UART0(
        .rx_data(),
        .rx_rec_flag(),
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_data(),
        .tx_start(),
        .baud_limit(),
        .rx(),
        .rx_clr(),
        .clk(),
        .rst()
    );
*/

//通过baud_limit可随时修改分频值
//该设计不会综合出除法器，但是不能直接输入波特率。
module uart_var_limit #(parameter clock_freq = 100_000_000,limit_width = 10) (
    output[7:0] rx_data,
    output rx_rec_flag,
    output tx,
    output tx_done,
    output tx_idle,
    input[7:0] tx_data,
    input[limit_width-1:0] baud_limit,
    input tx_start,
    input rx,
    input rx_clr,
    input clk,
    input rst
    );
    
    uart_var_limit_rx #(.clock_freq(clock_freq),.limit_width(limit_width)) UART_RX0(
        .data(rx_data),
        .data_rec(rx_rec_flag),
        .rx(rx),
        .baud_limit(baud_limit),
        .clr(rx_clr),
        .clk(clk),
        .rst(rst)
    );
    
    uart_var_limit_tx #(.clock_freq(clock_freq),.limit_width(limit_width)) UART_TX0(
        .tx(tx),
        .tx_done(tx_done),
        .tx_idle(tx_idle),
        .tx_start(tx_start),
        .baud_limit(baud_limit),
        .tx_data(tx_data),
        .clk(clk),
        .rst(rst)
    );
    
endmodule
