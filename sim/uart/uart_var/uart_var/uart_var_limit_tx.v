`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 晴空-Tiso（B站同名）
// 
// Create Date: 2023/12/27 16:23:31
// Design Name: 
// Module Name: uart_var_limit_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.03 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
    uart_var_limit_tx #(.clock_freq(),.limit_width()) UART_TX0(
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_start(),
        .baud_limit(),
        .tx_data(),
        .clk(),
        .rst()
    );
*/

//通过baud_limit可随时修改分频值
//该设计不会综合出除法器，但是不能直接输入波特率。
module uart_var_limit_tx #(parameter clock_freq = 100_000_000,limit_width = 10) (
    output reg tx,
    output reg tx_done,
    output reg tx_idle,
    input tx_start,
    input[limit_width-1:0] baud_limit,
    input[7:0] tx_data,
    input clk,
    input rst
);
    
    localparam bit_num = 11; //1开始位 + 8数据位 + 1停止位 + 再加一位计数器判断复位
    localparam IDLE  = 0;
    localparam SEND = 1;
    
    wire [limit_width - 1:0] baud_cnt;
    wire [3:0] bit_index;
    wire tx_idle_logic;
    wire tx_done_logic;
    
    reg baud_cnt_done;
    reg send_cnt_done;
    reg [9:0] tx_shift;
    reg [0:0] state = IDLE;
    reg cnt_rst;
    
    assign tx_idle_logic = state == IDLE ? 1 : 0;
    assign tx_done_logic = state == IDLE && send_cnt_done;
    
    always @(posedge clk) begin
        tx_done <= tx_done_logic;
        tx_idle <= tx_idle_logic;
    end
    
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
        else if(bit_index >= bit_num - 1 ? 1:0)
            send_cnt_done <= 1;
        else
            send_cnt_done <= 0;  
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            case (state)
                IDLE:
                    if(tx_start)
                        state <= SEND;
                SEND:
                    if (send_cnt_done)
                        state <= IDLE;
                default:
                    state <= IDLE;
            endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_shift <= 10'b1111111111;
        else
            case (state)
                IDLE:
                    if(tx_start)
                        tx_shift <= {2'b11, tx_data};
                    else
                        tx_shift <= 10'b1111111111;
                SEND:
                    if (baud_cnt_done)
                        tx_shift <= {1'b1, tx_shift[9:1]};
                default:
                    tx_shift <= 10'b1111111111;
            endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            tx <= 1;
        else
            case (state)
                IDLE:
                    if(tx_start)
                        tx <= 0;
                    else
                        tx <= 1;
                SEND:
                    if (baud_cnt_done)
                        tx <= tx_shift[0];
                default:
                    tx <= 1;
            endcase
    end
    
    always @(*) begin
        if (rst)
            cnt_rst <= 1;
        else
            case (state)
                IDLE:
                    cnt_rst <= 1;
                SEND:
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

