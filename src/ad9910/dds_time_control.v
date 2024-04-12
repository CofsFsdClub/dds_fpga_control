`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/01 11:28:40
// Design Name: 
// Module Name: dds_control_v4
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
//该版本为 io_update触发 drover下降沿触发，drctl为pwm型信号调制，实现啁啾信号

module dds_time_control #(   
    parameter FRE = 10000,//Hz  10kHz
    parameter PULSE = 1000,//ns 1us
    parameter CLKNUM = 2, //ns 时钟500MHz 1/500MHz
    parameter MAX_CNT = 1_000_000_000/FRE/CLKNUM//1s/fre/(1/50MHz)
)(
    input sys_clk,//500MHz
    input sys_rst,
    
    input sweep_sel,
    
    input drover,
    input io_update, 
 
    output osk,
    output drctl,
    output drhold
    );

assign drhold = 1'b0; //该信号引脚没用上
//对io_update信号打拍处理，用于判断上升沿   
reg [1:0]io_update_reg;
always@(posedge sys_clk)begin
    if(sys_rst)begin
        io_update_reg <= 'b0;
    end
    else begin
        io_update_reg <= {io_update_reg[0],io_update};
    end
end
//对drover信号打拍处理，用于判断下降升沿   
reg [1:0]drover_reg;
always@(posedge sys_clk)begin
    if(sys_rst)begin
        drover_reg <= 'b0;
    end
    else begin
        drover_reg <= {drover_reg[0],drover};
    end
end
//触发信号状态机
reg [2:0] triger_state;

localparam IDLE = 3'b000;        //初始状态
//localparam STARTDRCTL = 3'b101; //DRCTL
localparam WAITDROVER = 3'b001;
localparam DROVERCOUNT_1 = 3'b010;
localparam DROVERCOUNT_2 = 3'b100;

//reg [15:0]drctl_cnt;//定义计数drctl长度
//reg [15:0]pulse_cnt;//定义计数脉冲长度 仿真计算长度使用 并无实际作用
reg drctl_reg;
//reg drhold_reg;
always @(posedge sys_clk)begin
    if(sys_rst)begin
//        drctl_cnt <= 'b0;
        drctl_reg <= 1'b0;
//        drhold_reg <= 1'b0;
    end
    else if(triger_state == WAITDROVER) begin
//        drctl_cnt <= drctl_cnt + 1'b1;
        drctl_reg <= 1'b1;
//        drhold_reg <= 1'b1;
    end
    else if(triger_state == DROVERCOUNT_1)begin
//        drctl_cnt <= drctl_cnt + 1'b1;
        drctl_reg <= 1'b1;
//        drhold_reg <= 1'b0;
    end
    else if(triger_state == DROVERCOUNT_2)begin
//        drctl_cnt <= 'b0;
        drctl_reg <= 1'b0;
//        drhold_reg <= 1'b0;
    end
    else begin
//        drctl_cnt <= 'b0;
        drctl_reg <= 1'b0;
//        drhold_reg <= 1'b0;
    end
end

//计数 drover的宽度
wire [15:0] drover_cnt;
pulse2width#(
    .WIDTH(16) //设置计数 数据的位宽
)drover_width(
    .sys_clk(sys_clk), 
    .sys_rst(sys_rst), //计数器复位
    
    .rst_value(16'b0),  //设置初始计数值 范围 2^16
    .count_valid_in(~drover),    //触发计数 高电平为有效    
    
    .count_valid_out(),     //连接的输出端口
    .add_count_out(drover_cnt) //0-500
    );
    
always @(posedge sys_clk)begin
    case(triger_state)
        IDLE:begin
            if(~io_update_reg[1]&io_update_reg[0])begin//判断到一个io_update的上升沿 状态机转换
                triger_state <= WAITDROVER;
            end
        end
        WAITDROVER:begin
            if(drover_reg[1]&~drover_reg[0])begin//判断到一个drover的下降沿 状态机转换
                triger_state <= DROVERCOUNT_1;
            end
        end
        DROVERCOUNT_1:begin
            if(drover_cnt == PULSE/CLKNUM/2) begin //当计数达到设定脉冲宽度值的时候 状态机转换
                triger_state <= DROVERCOUNT_2;
            end
        end
        DROVERCOUNT_2:begin
            if(drover_cnt == PULSE/CLKNUM) begin //当计数达到设定脉冲宽度值的时候 状态机转换
                triger_state <= IDLE;
            end
        end
        default:begin
            triger_state <= IDLE;
        end 
    endcase 
end

wire [15:0]drover_start_cnt;
wire [15:0]drover_stop_cnt;
assign drover_start_cnt = sweep_sel? 16'b0:PULSE/CLKNUM/2;      //不需要对末尾值减1 这样才能保证输出的波形宽度正好为设计宽度
assign drover_stop_cnt = sweep_sel? PULSE/CLKNUM/2:PULSE/CLKNUM;

width2pulse#(
    .WIDTH(16) //输入数据的位宽
)osk_pulse(
    .sys_clk(sys_clk), 
    .sys_rst(sys_rst), //计数器复位
   
    .data_in(drover_cnt),          //输入数据

    .count_start(drover_start_cnt),      //计数开始值
    .count_stop(drover_stop_cnt),       //计数结束值
    
    .pulse_valid_out(osk)              //电平输出
    );

//reg drhold_reg;
//always @(posedge sys_clk)begin
//    if(sys_rst)begin
//        drhold_reg <= 1'b0;
//    end
//    else if((triger_state == WAITDROVER)&&(drover_cnt == 0))begin
//        drhold_reg <= 1'b1;
//    end
//    else begin
//        drhold_reg <= 1'b0;
//    end
//end
assign drctl = drctl_reg;
//assign drhold = drhold_reg;
endmodule
