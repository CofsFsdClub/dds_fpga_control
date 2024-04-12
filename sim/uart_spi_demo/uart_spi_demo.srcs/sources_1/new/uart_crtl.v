`timescale 1ns / 1ps

module uart_crtl(
    input clk,
    input rst_n,
    input key_in,

    input [7:0] data_in,
    input data_in_vld,
    input tx_finish,
    output reg [2:0] baud,
    output reg [7:0] data_out,
    output reg tx_en
    );

    parameter WAIT_TIME = 600_000_00;//3s
    integer i;

    reg [7:0] store [4:0];//发送存储
    reg [7:0] str_cnt;
    reg [7:0] N;
    reg [7:0] rx_cnt;
    reg [7:0] rx_cnt;
    reg [7:0] rx_num;
    reg [31:0] wait_cnt;
    (*mark_debug = "true"*)reg wait_flag;
    reg rec_flag;
    reg [7:0] rx_buf [9:0];

    wire add_str_cnt,end_str_cnt;
    wire add_wait_cnt,end_wait_cnt;
    wire add_rx_cnt,end_rx_cnt;
    wire end_signal;
    wire din_vld;

    //按键实现波特率的切换
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            baud <= 3'b000;
        else if(key_in)begin
            if(baud == 3'b100)
                baud <= 3'b000;
            else
                baud <= baud + 1'b1;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            store[0]  <= 0;
            store[1]  <= 0;
            store[2]  <= 0;
            store[3]  <= 0;
            store[4]  <= 0;
        end
        else begin
            store[0]  <= "w";//8'd119;//w
            store[1]  <= "a";//8'd97;//a
            store[2]  <= "i";//8'd105;//i
            store[3]  <= "t";//8'd116;//t
            store[4]  <= " ";//8'd32;//空格
        end
    end

    //发送计数器区分发送哪一个字符
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            str_cnt <= 0;
        else if(add_str_cnt)begin
            if(end_str_cnt)
                str_cnt <= 0;
            else
                str_cnt <= str_cnt + 1'b1;
        end
    end

    assign add_str_cnt = tx_finish;
    assign end_str_cnt = add_str_cnt && str_cnt == N - 1;

    //接收计数器
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            rx_cnt <= 0;
        else if(add_rx_cnt)begin
            if(end_rx_cnt)
                rx_cnt <= 0;
            else
                rx_cnt <= rx_cnt + 1'b1;
        end
    end

    assign add_rx_cnt = din_vld;
    assign end_rx_cnt = add_rx_cnt && ((rx_cnt == 10 - 1) || data_in == "#");//接收到的字符串最长为10个


    assign din_vld = data_in_vld && wait_flag;

    //计数器计时等待时间1s
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            wait_cnt <= 0;
        else if(add_wait_cnt)begin
            if(end_wait_cnt)
                wait_cnt <= 0;
            else
                wait_cnt <= wait_cnt + 1'b1;
        end
    end

    assign add_wait_cnt = wait_flag;
    assign end_wait_cnt = add_wait_cnt && wait_cnt == WAIT_TIME - 1;//每到WAIT_TIME时，输出一个end_wait_cnt

    //等待标志位
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            wait_flag <= 1;
        else if(end_wait_cnt)
            wait_flag <= 0;
        else if(end_str_cnt)
            wait_flag <= 1;
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            rx_num <= 0;
        else if(end_signal)
            rx_num <= rx_cnt + 1'b1;
    end

    assign end_signal = add_rx_cnt && data_in == "#";

    //接收缓存
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            for(i = 0;i < 10;i = i + 1)begin
                rx_buf[i] <= 0;
            end
        else if(din_vld && !end_signal)
            rx_buf[rx_cnt] <= data_in;
        else if(end_wait_cnt)
            rx_buf[rx_num - 1] <= " ";
        else if(end_str_cnt)
        for(i = 0;i < 10;i = i + 1)begin
                rx_buf[i] <= 0;
            end
    end

    //检测有效数据
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            rec_flag <= 0;
        else if(end_signal)
            rec_flag <= 1;
        else if(end_str_cnt)
            rec_flag <= 0;
    end

    always@(*)begin
        if(rec_flag)
            N <= rx_num;
        else
            N <= 5;
    end

    //发送数据给串口发送模块
    always@(*)begin
        if(rec_flag)
            data_out <= rx_buf[str_cnt];
        else
            data_out <= 'b0;
    end

    //等待结束后发送使能有效
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            tx_en <= 0;
        else if(end_wait_cnt || (add_str_cnt && str_cnt < N - 1 && !wait_flag))
            tx_en <= 1;
        else
            tx_en <= 0;
    end

endmodule