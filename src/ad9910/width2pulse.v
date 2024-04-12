`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/01 17:00:35
// Design Name: 
// Module Name: width2pulse
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


module width2pulse#(
    parameter WIDTH = 16 //输入数据的位宽
)(
    input sys_clk, //ADC采样时钟 250MHz
    input sys_rst, //adc 复位
   
    input [WIDTH-1:0]data_in,          //输入数据
//    input data_valid,                   //触发计数 高电平为有效
    input [WIDTH-1:0]count_start,      //计数开始值
    input [WIDTH-1:0]count_stop,       //计数结束值
    
    output pulse_valid_out              //电平输出
    );

reg pulse_valid_out_reg;
always@(posedge sys_clk)begin 
    if(sys_rst)begin
        pulse_valid_out_reg <= 1'b0;
    end
    else if((data_in <= count_stop)&&(data_in > count_start))begin // >0才行，不然就成了死循环了 pulse_valid_out_reg会被一直拉高
        pulse_valid_out_reg <= 1'b1;
    end
    else begin
        pulse_valid_out_reg <= 'b0;
    end 
end

assign pulse_valid_out = pulse_valid_out_reg;

endmodule
