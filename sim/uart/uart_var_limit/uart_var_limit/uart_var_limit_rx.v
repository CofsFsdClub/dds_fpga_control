`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/31 18:50:22
// Design Name: 
// Module Name: uart_var_limit_rx
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
    uart_var_limit_rx #(.clock_freq(),.limit_width()) UART_RX0(
        .data(),
        .data_rec(),
        .baud_limit(),
        .rx(),
        .clr(),
        .clk(),
        .rst()
    );
*/

//通过baud_limit可随时修改分频值
//该设计不会综合出除法器，但是不能直接输入波特率。
module uart_var_limit_rx #(parameter clock_freq = 100_000_000,limit_width = 10)(
    output reg [7:0] data,
    output reg data_rec,
    input[limit_width-1:0] baud_limit,
    input rx,
    input clr,
    input clk,
    input rst
);
    
    localparam bit_num = 10;
    localparam IDLE = 0;
    localparam RECEIVE = 1;
    
    reg baud_cnt_done;
    reg send_cnt_done;
    reg cnt_rst;
    reg [0:0] state = IDLE;
    reg [8:0] data_temp;
    
    wire[limit_width-2:0] half_baud_limit;
    wire [limit_width - 1:0] baud_cnt;
    wire [3:0] bit_index;
    
    assign half_baud_limit = baud_limit[limit_width-1:1];
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            baud_cnt_done <= 0;
        else if(baud_cnt >= (baud_limit - 1))
            baud_cnt_done <= 1;
        else
            baud_cnt_done <= 0;  
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            send_cnt_done <= 0;
        else if((baud_cnt == half_baud_limit) & (bit_index >= bit_num - 1 ? 1:0))
            send_cnt_done <= 1;
        else
            send_cnt_done <= 0;  
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            data_temp <= 9'b1_1111_1111;
        else if(baud_cnt == half_baud_limit)
            data_temp <= {rx,data_temp[8:1]};
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            data = 8'hff;
        else if(send_cnt_done)
            data = data_temp[7:0];
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            state <= IDLE;
        else if(state == IDLE & !rx)
                state <= RECEIVE;
        else if(state == RECEIVE & send_cnt_done)
            state <= IDLE;
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            data_rec <= 0;
        else if(send_cnt_done)
            data_rec <= 1;
        else if(clr)
            data_rec <= 0;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt_rst <= 1;
        else
            case (state)
                IDLE:
                    cnt_rst <= 1;
                RECEIVE:
                    cnt_rst <= 0;
                default:
                    cnt_rst <= 1;
            endcase
    end
    
    cnt_var #(.cnt_mode(0),.width(limit_width)) CNT0(
            .cnt_value(baud_cnt),
            .max_value(baud_limit),
            .clk(clk),
            .rst(cnt_rst)
        );
    
    cnt_auto #(.cnt_mode(0),.max_value(bit_num)) CNT1(
            .cnt_value(bit_index),
            .clk(baud_cnt_done),
            .rst(cnt_rst)
        );
    
endmodule