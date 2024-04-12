`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/09 10:07:31
// Design Name: 
// Module Name: tb_uart_crtl
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


module tb_uart_crtl();

    reg clk,rst_n;
    reg key_in;
    reg [7:0] data_in;
    reg data_in_vld;

    wire tx_finish;
    wire [2:0] baud;
    wire [7:0] data_tx;
    wire tx_en;

    uart_crtl uart_ctrl(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key_in),

    .data_in(data_in),
    .data_in_vld(data_in_vld),
    .tx_finish(tx_finish),
    .baud(baud),
    .data_out(data_tx),
    .tx_en(tx_en)
    );

    uart_tx_byte uart_tx_module(
    .clk(clk),
    .rst_n(rst_n),
    .baud_set(baud),
    .send_en(tx_en),
    .data_in(data_tx),

    .data_out(),
    .tx_done(tx_finish)
    );

    parameter CYC = 5,
              RST_TIME = 2;

    defparam uart_ctrl.WAIT_TIME = 2000_000;

    initial begin
        clk = 0;
        forever #(CYC / 2.0) clk = ~clk;
    end

    initial begin
        rst_n = 1;
        #1;
        rst_n = 0;
        #(CYC * RST_TIME);
        rst_n = 1;
    end

    initial begin
        #1;
        key_in = 0;
        data_in = 0;
        data_in_vld = 0;
        #(CYC * RST_TIME);
        #10_000;
        #5_000_000;
        data_in = 8'h30;
        repeat(4)begin
            data_in_vld = 1;
            data_in = data_in + 1;
            #(CYC * 1);
            data_in_vld = 0;
        end
        data_in_vld = 1;
        data_in = 8'h23;
        #(CYC * 1);
        data_in_vld = 0;
        #10_000;
        $stop;
    end
endmodule