`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ���-Tiso��Bվͬ����
// 
// Create Date: 2023/12/27 13:35:02
// Design Name: 
// Module Name: uart_sw_2ch_tx
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
    uart_sw_2ch_tx #(.clock_freq(),.ch0_rate(),.ch1_rate()) UART_TX0(
        .tx(),
        .tx_done(),
        .tx_idle(),
        .tx_start(),
        .tx_data(),
        .switch(),
        .clk(),
        .rst()
    );
*/

//switch��Ϊ0ѡ��ch0�����ʣ���֮ѡ��ch1������
module uart_sw_2ch_tx #(parameter clock_freq = 100_000_000,ch0_rate = 115200,ch1_rate = 9600) (
    output reg tx,
    output reg tx_done,
    output reg tx_idle,
    input tx_start,
    input switch,
    input[7:0] tx_data,
    input clk,
    input rst
);

    localparam baud_limit0 = clock_freq / ch0_rate;
    localparam baud_limit1 = clock_freq / ch1_rate;
    localparam limit_width = baud_limit0 > baud_limit1 ? (baud_limit0 > 0 ?  $clog2(baud_limit0+1) : 1) : (baud_limit1 > 0 ?  $clog2(baud_limit1+1) : 1);
    localparam bit_num = 11; //1��ʼλ + 8����λ + 1ֹͣλ + �ټ�һλ�������жϸ�λ
    localparam IDLE  = 0;
    localparam SEND = 1;
    
    wire [limit_width - 1:0] baud_limit;
    wire [limit_width - 1:0] baud_cnt;
    wire [3:0] bit_index;
    wire tx_idle_logic;
    wire tx_done_logic;
    
    reg baud_cnt_done;
    reg send_cnt_done;
    reg [9:0] tx_shift;
    reg [0:0] state = IDLE;
    reg cnt_rst;
    
    assign baud_limit = switch == 0 ? baud_limit0 : baud_limit1;
    assign tx_idle_logic = state == IDLE ? 1 : 0;
    assign tx_done_logic = state == SEND && send_cnt_done;
    
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