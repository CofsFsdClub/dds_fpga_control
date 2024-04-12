`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/27 15:34:06
// Design Name: 
// Module Name: cnt_var
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
    cnt_var #(.cnt_mode(),.width()) CNT0(
            .cnt_value(),
            .max_value(),
            .clk(),
            .rst()
        );
*/

//cnt_mode控制加减，0为加法计数器，不为0则为减法计数器
module cnt_var #(parameter cnt_mode = 0,width = 8)(
    output reg[width-1:0] cnt_value,
    input[width-1:0] max_value,
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

