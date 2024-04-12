`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/31 20:03:40
// Design Name: 
// Module Name: string_save
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
    string_save #(.byte_num(),.start_signal()) STR_SAVE0(
        .str_buf(),
        .str_cnt(),
        .str_in(),
        .rx_flag(),
        .clk(),
        .rst()
        );
*/

module string_save #(parameter byte_num = 1,start_signal = ".",limit_width = byte_num > 0 ?  $clog2(byte_num) : 1) (
    output reg[byte_num * 8 - 1 : 0] str_buf,
    output[limit_width - 1:0] str_cnt,
    input[7:0] str_in,
    input rx_flag,
    input clk,
    input rst
    );
    
    localparam IDLE = 0;
    localparam SAVE = 1;
    
    integer i;
    
    reg state = IDLE;
    reg cnt_clk;
    reg start;
    
    wire cnt_rst;
    
    assign cnt_rst = start | rst;
    
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            state <= IDLE;
        else if(start)
            state <= SAVE;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            start <= 0;
        else if(str_in == start_signal)
            start <= rx_flag;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            cnt_clk <= 0;
        else if(state == SAVE)
            cnt_clk <= rx_flag;
        else
            cnt_clk <= 0;
    end
    
    always@(posedge cnt_clk or posedge cnt_rst)
    begin
        if(cnt_rst)
            str_buf <= 0;
        else if(start)
            str_buf <= 0;
        else if(state == IDLE)
            str_buf <= 0;
        else if(state == SAVE) begin
            for(i = 0;i < byte_num;i = i + 1) begin
                if(i == str_cnt)
                    str_buf[i*8+:8] <= str_in;
            end
        end
    end
    
    cnt_limit #(.cnt_mode(1),.max_value(byte_num)) CNT0(
            .cnt_value(str_cnt),
            .clk(cnt_clk),
            .rst(cnt_rst)
        );
    
endmodule
