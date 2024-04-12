`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/26 02:50:03
// Design Name: 
// Module Name: cnt_auto
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
    cnt_auto #(.cnt_mode(),.max_value()) CNT0(
        .cnt_value(),
        .clk(),
        .rst()
        );
*/

//cnt_mode控制加减，0为加法计数器，不为0则为减法计数器
//给定maxvalue后会自动计算width，无需给width参数值
module cnt_auto #(parameter cnt_mode = 0,max_value = 10,width = max_value > 0 ? $clog2(max_value) : 1)(
    output reg[width-1:0] cnt_value,
    input clk,
    input rst
    );
    
    always@(posedge clk or posedge rst)
    begin
        if(cnt_mode == 0) begin
            if(rst)
                cnt_value <= 0;
            else if(cnt_value >= max_value - 1)
                cnt_value <= 0;
            else
                cnt_value <= cnt_value + 1;    
        end
        else begin
            if(rst)
                cnt_value <= max_value - 1;
            else if(cnt_value == 0)
                cnt_value <= max_value - 1;
            else
                cnt_value <= cnt_value - 1;   
        end
    end
    
endmodule
