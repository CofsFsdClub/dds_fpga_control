`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/09 10:10:05
// Design Name: 
// Module Name: uart_tx_byte
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


module uart_tx_byte(
    input clk,
    input rst_n,
    input [2:0] baud_set,
    input send_en,
    input [7:0] data_in,

    output reg data_out, //bit 输出
    output tx_done
    );

    reg [15:0] CYC;
    reg [15:0] cnt_div;
    (*mark_debug = "true"*)reg [3:0] cnt_bit;
    reg add_flag;

    wire add_cnt_div;
    (*mark_debug = "true"*)wire end_cnt_div;
    wire add_cnt_bit,end_cnt_bit;

    //分频计数器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_div <= 0;
        else if(add_cnt_div)begin
            if(end_cnt_div)
                cnt_div <= 0;
            else
                cnt_div <= cnt_div + 1'b1;
        end
    end

    assign add_cnt_div = add_flag;
    assign end_cnt_div = add_cnt_div && cnt_div == CYC - 1;

    //比特位数计数器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt_bit <= 0;
        else if(add_cnt_bit)begin
            if(end_cnt_bit)
                cnt_bit <= 0;
            else
                cnt_bit <= cnt_bit + 1'b1;
        end
    end

    assign add_cnt_bit = end_cnt_div;
    assign end_cnt_bit = add_cnt_bit && cnt_bit == 10 - 1;

    //发送使能后分频计数器开始计数，直到将起始位、数据位、停止位发送完成为止
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            add_flag <= 0;
        else if(send_en)
            add_flag <= 1;
        else if(end_cnt_bit)
            add_flag <= 0;
    end
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
    //根据比特计数器得到对应比特位
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            data_out <= 1;
        else if(send_en)
            data_out <= 0;
        else if(add_cnt_bit && cnt_bit >= 0 && cnt_bit < 8)
            data_out <= data_in[cnt_bit];
        else if((add_cnt_bit && cnt_bit == 8) || end_cnt_bit)
            data_out <= 1;//结束位或者空闲状态均为高电平
    end

    assign tx_done = end_cnt_bit;

endmodule
