`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Çç¿Õ-Tiso£¨BÕ¾Í¬Ãû£©
// 
// Create Date: 2023/12/31 19:17:22
// Design Name: 
// Module Name: uart_sw_2ch
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
    uart_sw_2ch #(.clock_freq(),.ch0_rate(),.ch1_rate()) UART0(
        .rx_data(),
        .rx_rec_flag(),
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_data(),
        .tx_start(),
        .rx(),
        .switch(),
        .rx_clr(),
        .clk(),
        .rst()
    );
*/

module uart_sw_2ch #(parameter clock_freq = 100_000_000,ch0_rate = 115200,ch1_rate = 9600) (
    output[7:0] rx_data,
    output rx_rec_flag,
    output tx,
    output tx_done,
    output tx_idle,
    input[7:0] tx_data,
    input tx_start,
    input rx,
    input switch,
    input rx_clr,
    input clk,
    input rst
    );
    
    uart_sw_2ch_rx #(.clock_freq(clock_freq),.ch0_rate(ch0_rate),.ch1_rate(ch1_rate)) UART_RX0(
        .data(rx_data),
        .data_rec(rx_rec_flag),
        .rx(rx),
        .switch(switch),
        .clr(rx_clr),
        .clk(clk),
        .rst(rst)
    );
    
    uart_sw_2ch_tx #(.clock_freq(clock_freq),.ch0_rate(ch0_rate),.ch1_rate(ch1_rate)) UART_TX0(
        .tx(tx),
        .tx_done(tx_done),
        .tx_idle(tx_idle),
        .tx_start(tx_start),
        .switch(switch),
        .tx_data(tx_data),
        .clk(clk),
        .rst(rst)
    );
    
endmodule
