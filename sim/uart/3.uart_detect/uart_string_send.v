`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Çç¿Õ-Tiso£¨BÕ¾Í¬Ãû£©
// 
// Create Date: 2024/01/01 00:50:15
// Design Name: 
// Module Name: uart_string_send
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
    uart_string_send #(.byte_num()) UART_SEND0(
        .uart_data(),
        .uart_start(),
        .idle_flag(),
        .string_in(),
        .uart_tx_done(),
        .send_start(),
        .clk(),
        .rst()
        );
*/

module uart_string_send #(parameter byte_num = 1) (
    output[7:0] uart_data,
    output reg uart_start,
    output idle_flag,
    input[byte_num * 8 - 1 : 0] string_in,
    input uart_tx_done,
    input send_start,
    input clk,
    input rst
    );
    
    localparam cnt_width = byte_num > 0 ? $clog2(byte_num) : 1;
    localparam IDLE  = 0;
    localparam SEND = 1;
    
    reg cnt_clk;
    reg cnt_rst;
    reg[0:0] state;
    reg[byte_num * 8 - 1 : 0] string_temp;
    reg string_temp_rst;
    
    wire[cnt_width-1:0] send_cnt;
    
    assign uart_data = string_temp[byte_num * 8 - 1 : byte_num * 8 - 8];
    assign idle_flag = state == IDLE ? 1 : 0;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            state <= IDLE;
        else if(state == IDLE && send_start == 1 && uart_tx_done)
            state <= SEND;
        else if(state == SEND && send_cnt == 0 && uart_tx_done == 0)
            state <= IDLE;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            cnt_clk <= 1;
        else if(state == IDLE)
            cnt_clk <= 1;
        else if(state == SEND)
            cnt_clk <= uart_tx_done;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            cnt_rst <= 1;
        else if(state == IDLE && send_start == 1 && uart_tx_done)
            cnt_rst <= 1;
        else
            cnt_rst <= 0;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            uart_start <= 0;
        else if(state == IDLE && send_start == 1 && uart_tx_done)
            uart_start <= 1;
        else if(state == SEND && uart_tx_done == 1)
            uart_start <= 1;
        else
            uart_start <= 0;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            string_temp_rst <= 1;
        else if(state == IDLE)
            string_temp_rst <= 1;
        else
            string_temp_rst <= 0;
    end
    
    always@(posedge cnt_clk or posedge string_temp_rst)
    begin
        if(string_temp_rst)
            string_temp <= string_in;
        else
            string_temp <= {string_temp[byte_num * 8 - 9:0],8'h00};
    end
    
    cnt_auto #(.cnt_mode(1),.max_value(byte_num)) CNT0(
            .cnt_value(send_cnt),
            .clk(cnt_clk),
            .rst(cnt_rst)
        );
    
endmodule
