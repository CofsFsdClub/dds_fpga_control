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
    
    //字符串保存模块，start_signal为开始识别信号，保存内容为开始信号后的内容
    //如开始信号为".",则当输入.12345时就会保存内容12345
    string_save #(.byte_num(11),.start_signal(".")) STR_SAVE0(
        .str_buf(uart_rx_str),
        .str_cnt(str_cnt),
        .str_in(uart_rx_data),
        .rx_flag(rx_rec_flag),
        .clk(clk_100m),
        .rst(rst)
        );
    
    //字符串对比模块，将string_in0与string_in1进行对比并给出
    //equal（是否等于）greater（是否大于）和less（是否小于）
    //本次实验我们只需要判断是否等于，所以只取用了equal信号。
    string_compare #(.byte_num(10)) STR_CMP0(
        .equal(equal_flag),
        .greater(),
        .less(),
        .string_in0(uart_rx_str[87:8]) ,
        .string_in1("阿空真帅！")
        );
        
    //集串口发送和串口接收于一体的串口模块，
    //tx与rx端口连接外部串口引脚，rx_data为串口接收到的数据，
    //rx_rec_flag为串口接收到数据标志位
    //tx_start为串口发送开启信号，tx_done为串口发送完成信号，
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
    
    //串口发送字符串模块，string_in端口输入要发送的内容
    //byte_num计算方法：每个中文文字占两位，每个英文字符占一位，回车换行（16'h0d0a）占两位。
    uart_string_send #(.byte_num(18)) UART_SEND0(
        .uart_data(uart_ctrl_data),
        .uart_start(uart_start),
        .idle_flag(),
        .string_in({"对的，阿空真帅！",16'h0d0a}),
        .uart_tx_done(uart_tx_done),
        .send_start(equal_pulse),
        .clk(clk_100m),
        .rst(rst)
        );
        
    //脉冲转化器，用来将一段连续信号变为一个脉冲信号。
    //本质上是一个序列检测器+多一级寄存器，可以用序列检测器替换
    pulse_conver #(.width(2),.filt_value(2'b01)) PC0(
        .pulse_out(equal_pulse),
        .pulse_in(equal_flag),
        .clk(clk_100m),
        .rst(rst)
        );
        
endmodule
