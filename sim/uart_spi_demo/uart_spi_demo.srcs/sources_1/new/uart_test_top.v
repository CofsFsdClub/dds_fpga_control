`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 18:03:26
// Design Name: 
// Module Name: uart_test_top
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


module uart_test_top(
    input sys_clk,
    input sys_rst_n, //�͵�ƽ��Ч
    
    input uart_rxd,
    output uart_txd
    );

wire [7:0]  addr_data;
wire [7:0] cmd_data;
wire data_done;
wire rx_done;
wire addr_data_valid;
wire cmd_data_valid;

uart_decode#(
    .UART_BPS(115200),
    .CLK_FREQ(50_000_000),
    .HEAD_FREAME(8'hA6), //8'hA6, //����ͷ֡
    .END_FREAME(8'hCE) //����β֡
)uart_rec_decode(
    .sys_clk(sys_clk),			//50Mϵͳʱ��
    .sys_rst_n(~sys_rst_n),			//ϵͳ��λ
    
    .uart_rxd(uart_rxd),          //���ڽ�������
    
    .addr_data(addr_data),
    .cmd_data(cmd_data),
    .addr_data_valid(addr_data_valid),
    .cmd_data_valid(cmd_data_valid),
    
    .data_done(data_done), //���һ�����ݽ����ı�־ 11�ֽ�
    .byte_valid(rx_done)    //�������ʱ���� ����һ���ֽڵı�־ 8bit
);

//�������������
uart_tx#(
	.BPS		    (115200),
	.SYS_CLK_FRE	(50_000_000))
u_uart_tx(
	.sys_clk		(sys_clk),
	.sys_rst_n	    (~sys_rst_n),
	.uart_tx_en		(cmd_data_valid),
	.uart_data	    (cmd_data),	
	.uart_txd	    (uart_txd)
);
ila_0 ila2 (
	.clk(sys_clk), // input wire clk
	.probe0(
	{
	addr_data,
	cmd_data,
	addr_data_valid,
	cmd_data_valid,
	data_done,
	rx_done
	}) // input wire [511:0] probe0
);

endmodule
