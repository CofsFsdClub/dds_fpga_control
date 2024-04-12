`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 14:37:35
// Design Name: 
// Module Name: pulse2width
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

//计数电平宽度模块
//也可以用作脉冲计数器
module pulse2width#(
    parameter WIDTH = 16 //设置计数 数据的位宽
)(
    input sys_clk, 
    input sys_rst, //计数器复位
   
    input [WIDTH-1:0] rst_value,  //设置初始计数值 范围 2^16
    input count_valid_in,    //触发计数 高电平为有效    
    
    output count_valid_out,     //连接的输出端口
    output [WIDTH-1:0]add_count_out
    );
    
reg [WIDTH-1:0]self_add_count_reg;
always@(posedge sys_clk)begin 
    if(sys_rst)begin
        self_add_count_reg <= rst_value;
    end
    else if(count_valid_in == 1'b1)begin
            self_add_count_reg <= self_add_count_reg + 1'b1;
    end
    else begin
       self_add_count_reg <= rst_value;
    end 
end

assign add_count_out = self_add_count_reg;
assign count_valid_out = count_valid_in;

endmodule