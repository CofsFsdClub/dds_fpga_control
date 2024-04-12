`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2024/01/01 10:57:34
// Design Name: 
// Module Name: cnt_limit
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
    cnt_limit #(.cnt_mode(),.max_value()) CNT0(
            .cnt_value(),
            .clk(),
            .rst()
        );
*/

//limit的计数器：加法到最高值或者减法到最低值后计数停止，只能通过复位再重新开始计数。
module cnt_limit #(parameter cnt_mode = 0,max_value = 10,width = max_value > 0 ? $clog2(max_value + 1) : 1)(
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
                cnt_value <= cnt_value;
            else
                cnt_value <= cnt_value + 1;    
        end
        else begin
            if(rst)
                cnt_value <= max_value - 1;
            else if(cnt_value == 0)
                cnt_value <= cnt_value;
            else
                cnt_value <= cnt_value - 1;   
        end
    end
    
endmodule