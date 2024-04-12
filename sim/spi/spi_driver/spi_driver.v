`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ���-Tiso��Bվͬ����
// 
// Create Date: 2024/01/27 08:15:46
// Design Name: 
// Module Name: spi_driver
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
    spi_driver SPI(
        .rec_data(),
        .mosi(),
        .sclk(),
        .idle(),
        .done(),
        .send_data(),
        .miso(),
        .mode(),
        .start(),
        .next(),
        .clk(),
        .rst()
        );
*/

//sclk���Ϊ����֮һ��clk����������spi���ʹ�ʽ��clk = sclk*2
//��spiͨ��ģ��Ϊ��λ���䣬��֧��ͨ������next�˿�Ϊ1���������Ӷ��ﵽһ���Դ����λ��Ч��
//mode���ڵ�������ģʽ��������ģʽ���£�
//Mode 0: CPOL = 0, CPHA = 0
//Mode 1: CPOL = 0, CPHA = 1
//Mode 2: CPOL = 1, CPHA = 0
//Mode 3: CPOL = 1, CPHA = 1
module spi_driver(
    output reg[7:0] rec_data,
    output reg mosi,
    output reg sclk,
    output idle,
    output reg done,
    input[7:0] send_data,
    input miso,
    input[1:0] mode,
    input start,
    input next,
    input clk,
    input rst
    );
    
    localparam IDLE = 0,
               WORK = 1;
    
    wire[3:0] cnt_value;
    
    reg state;
    reg[7:0] shift_reg;
    
    assign idle = state == IDLE;
    assign cnt_en = state == WORK;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            state <= IDLE;
        else if(state == IDLE && start)
            state <= WORK;
        else if(state == WORK && cnt_value == 15 && !next)
            state <= IDLE;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst) begin
            done <= 0;
            rec_data <= 0;
        end
        else if(state == WORK && cnt_value == 15) begin
            done <= 1;
            if(mode[0])
                rec_data <= {shift_reg[6:0],miso};
            else
                rec_data <= shift_reg;
        end
        else
            done <= 0;
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            mosi <= 1;
        else if(state == IDLE) begin
            if(!mode[0] && start)
                mosi <= send_data[7];
            else
                mosi <= 1;
        end
        else if(state == WORK && mode[0] ^ cnt_value[0])
            mosi <= shift_reg[7];
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            shift_reg <= 0;
        else if(state == IDLE)
            shift_reg <= send_data;
        else if(state == WORK && cnt_value == 15)
            shift_reg <= send_data;
        else if(state == WORK && mode[0] == cnt_value[0])
            shift_reg <= {shift_reg[6:0],miso};
    end
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            sclk <= mode[1];
        else if(state == IDLE)
            sclk <= mode[1];
        else if(state == WORK) begin
            if(cnt_value[0])
                sclk <= mode[1];
            else
                sclk <= ~mode[1];
        end
    end
    
    cnt_en #(.cnt_mode(0),.max_value(16)) CNT0(
            .cnt_value(cnt_value),
            .en(cnt_en),
            .clk(clk),
            .rst(rst)
        );
    
endmodule
