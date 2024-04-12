`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/31 16:52:41
// Design Name: 
// Module Name: uart_var
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
    uart_var #(.clock_freq(),.baud_width(),.limit_width()) UART0(
        .rx_data(),
        .rx_rec_flag(),
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_data(),
        .tx_start(),
        .baud_var(),
        .rx(),
        .rx_clr(),
        .clk(),
        .rst()
    );
*/

//避免综合出多个除法器，使用limit_var的tx和rx模块替代
module uart_var #(parameter clock_freq = 100_000_000,baud_width = 20,limit_width = 10) (
    output[7:0] rx_data,
    output rx_rec_flag,
    output tx,
    output tx_done,
    output tx_idle,
    input[7:0] tx_data,
    input[baud_width-1:0] baud_var,
    input tx_start,
    input rx,
    input rx_clr,
    input clk,
    input rst
    );
    
    wire[limit_width-1:0] baud_limit;
    
    assign baud_limit = clock_freq / baud_var;
    
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
