`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/28 22:22:03
// Design Name: 
// Module Name: top
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


module top(
    output uart_tx,
    input uart_rx,
    input clk_100m,
    input rst
    );
    
    wire[87:0] uart_rx_str;
    wire[7:0] uart_rx_data;
    wire[7:0] uart_ctrl_data;
    wire[4:0] str_cnt;
    wire rx_rec_flag;
    wire equal_flag;
    wire equal_pulse;
    wire uart_start;
    wire tx_start;
    wire uart_rx_flag;
    wire uart_tx_done;
    
    //�ַ�������ģ�飬start_signalΪ��ʼʶ���źţ���������Ϊ��ʼ�źź������
    //�翪ʼ�ź�Ϊ".",������.12345ʱ�ͻᱣ������12345
    string_save #(.byte_num(11),.start_signal(".")) STR_SAVE0(
        .str_buf(uart_rx_str),
        .str_cnt(str_cnt),
        .str_in(uart_rx_data),
        .rx_flag(rx_rec_flag),
        .clk(clk_100m),
        .rst(rst)
        );
    
    //�ַ����Ա�ģ�飬��string_in0��string_in1���жԱȲ�����
    //equal���Ƿ���ڣ�greater���Ƿ���ڣ���less���Ƿ�С�ڣ�
    //����ʵ������ֻ��Ҫ�ж��Ƿ���ڣ�����ֻȡ����equal�źš�
    string_compare #(.byte_num(10)) STR_CMP0(
        .equal(equal_flag),
        .greater(),
        .less(),
        .string_in0(uart_rx_str[87:8]) ,
        .string_in1("������˧��")
        );
        
    //�����ڷ��ͺʹ��ڽ�����һ��Ĵ���ģ�飬
    //tx��rx�˿������ⲿ�������ţ�rx_dataΪ���ڽ��յ������ݣ�
    //rx_rec_flagΪ���ڽ��յ����ݱ�־λ
    //tx_startΪ���ڷ��Ϳ����źţ�tx_doneΪ���ڷ�������źţ�
    uart_const_baud #(.clock_freq(100_000_000),.baud_rate(115200)) UART0(
        .rx_data(uart_rx_data),
        .rx_rec_flag(rx_rec_flag),
        .tx(uart_tx),
        .tx_done(uart_tx_done),
        .tx_data(uart_ctrl_data),
        .tx_start(uart_start),
        .rx(uart_rx),
        .rx_clr(rx_rec_flag),
        .clk(clk_100m),
        .rst(rst)
    );
    
    //���ڷ����ַ���ģ�飬string_in�˿�����Ҫ���͵�����
    //byte_num���㷽����ÿ����������ռ��λ��ÿ��Ӣ���ַ�ռһλ���س����У�16'h0d0a��ռ��λ��
    uart_string_send #(.byte_num(18)) UART_SEND0(
        .uart_data(uart_ctrl_data),
        .uart_start(uart_start),
        .idle_flag(),
        .string_in({"�Եģ�������˧��",16'h0d0a}),
        .uart_tx_done(uart_tx_done),
        .send_start(equal_pulse),
        .clk(clk_100m),
        .rst(rst)
        );
        
    //����ת������������һ�������źű�Ϊһ�������źš�
    //��������һ�����м����+��һ���Ĵ��������������м�����滻
    pulse_conver #(.width(2),.filt_value(2'b01)) PC0(
        .pulse_out(equal_pulse),
        .pulse_in(equal_flag),
        .clk(clk_100m),
        .rst(rst)
        );
        
endmodule
