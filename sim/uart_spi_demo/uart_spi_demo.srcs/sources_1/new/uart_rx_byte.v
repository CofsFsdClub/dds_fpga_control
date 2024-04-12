`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/09 10:05:00
// Design Name: 
// Module Name: uart_rx_byte
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


module uart_rx_byte(
    input clk,
    input rst_n,
    input [2:0] baud_set,
    input din_bit,

    output reg [7:0] data_byte,
    output reg dout_vld
    );

    reg din_bit_sa,din_bit_sb;
    reg din_bit_tmp;
    reg add_flag;
    reg [15:0] div_cnt;
    reg [3:0] bit_cnt;
    reg [15:0] CYC;

    wire data_neg;
    wire add_div_cnt,end_div_cnt;
    wire add_bit_cnt,end_bit_cnt;
    wire prob;

    //分频计数器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            div_cnt <= 0;
        else if(add_div_cnt)begin
            if(end_div_cnt)
                div_cnt <= 0;
            else
                div_cnt <= div_cnt + 1'b1;
        end
    end

    assign add_div_cnt = add_flag;
    assign end_div_cnt = add_div_cnt && div_cnt == CYC - 1;

    //bit计数器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            bit_cnt <= 0;
        else if(add_bit_cnt)begin
            if(end_bit_cnt)
                bit_cnt <= 0;
            else
                bit_cnt <= bit_cnt + 1'b1;
        end
    end

    assign add_bit_cnt = end_div_cnt;
    assign end_bit_cnt = add_bit_cnt && bit_cnt == 9 - 1;

    //波特率查找表
    always@(*)begin
        case(baud_set)
            3'b000:CYC  <= 5208;//9600/50M
            3'b001:CYC  <= 2604;//19200/50M
            3'b010:CYC  <= 1302;//38400/50M
            3'b011:CYC  <= 868;//57600/50M
            3'b100:CYC  <= 434;//115200/50M
            default:CYC <= 5208;//9600/50M
        endcase
    end

    //同步处理
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            din_bit_sa <= 1;
            din_bit_sb <= 1;
        end
        else begin
            din_bit_sa <= din_bit;
            din_bit_sb <= din_bit_sa;
        end
    end

    //下降沿检测
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            din_bit_tmp <= 1;
        else
            din_bit_tmp <= din_bit_sb;
    end

    assign data_neg = din_bit_tmp == 1 && din_bit_sb == 0;

    //检测到下降沿说明有数据起始位有效，计数标志位拉高
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            add_flag <= 0;
        else if(data_neg)
            add_flag <= 1;
        else if(end_bit_cnt)
            add_flag <= 0;
    end

    //bit位中点采样数据
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            data_byte <= 0;
        else if(prob)
            data_byte[bit_cnt - 1] <= din_bit_sb;
    end

    assign prob = bit_cnt !=0 && add_div_cnt && div_cnt == CYC / 2 - 1;

    //输出数据设置在接收完成是有效
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            dout_vld <= 0;
        else if(end_bit_cnt)
            dout_vld <= 1;
        else
            dout_vld <= 0;
    end

endmodule