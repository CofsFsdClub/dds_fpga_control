module dds_control_v5#(   
//    parameter PULSE = 1000,//ns 1us
    parameter CLKNUM = 2 //ns 时钟500MHz 1/500MHz
)(
    input sys_clk,//500MHz
    input sys_rst,
    
    input sweep_sel,
    
    input drover,
    input io_update, 
 
    output osk,
    output drctl,
    output drhold,

    input [15:0] triger_pulse
    );

wire[15:0]PULSE;
assign PULSE = triger_pulse; //该参数由上位机传递给FPGA，在没接收到指令之前，一直为0，只有接收到指令之后才开始产生啁啾信号！！！！！！！！！！！！    
assign drctl = (sweep_sel)?1'b1:1'b0; //频率发生 方向选择

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

reg [15:0]trigger_cnt;
reg trigger_flag;
always@(posedge sys_clk)begin
    if(sys_rst)begin
        trigger_flag <= 1'b0;
    end
    else if(~io_update_reg[1]&io_update_reg[0])begin//判断到一个io_update的上升沿
        trigger_flag <= 1'b1;
    end
    else if(trigger_cnt == PULSE/CLKNUM)begin
        trigger_flag <= 1'b0; 
    end
end

always@(posedge sys_clk)begin
    if(sys_rst)begin
        trigger_cnt <= 'b0;
    end
    else if(trigger_flag == 1'b1)begin//判断到一个io_update的上升沿
        trigger_cnt <= trigger_cnt + 1'b1;
    end
    else if(trigger_flag == 1'b0)begin//判断到一个io_update的上升沿
        trigger_cnt <= 'b0;
    end
    else begin
        trigger_cnt <= 'b0; 
    end
end

//assign drhold = ~trigger_flag;
//- - - - - - - - - - - - - - - - osk = 1/2 (~drover) - - - - - - - - - - - - - - - - - - -//
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
    
wire [15:0]drover_start_cnt;
wire [15:0]drover_stop_cnt;
assign drover_start_cnt = sweep_sel? 16'b0:PULSE/CLKNUM/2;      //不需要对末尾值减1 这样才能保证输出的波形宽度正好为设计宽度
assign drover_stop_cnt = sweep_sel? PULSE/CLKNUM/2:PULSE/CLKNUM;

//assign drover_start_cnt =  16'b0;      //不需要对末尾值减1 这样才能保证输出的波形宽度正好为设计宽度
//assign drover_stop_cnt = PULSE/CLKNUM/2;
width2pulse#(
    .WIDTH(16) //输入数据的位宽
)osk_pulse(
    .sys_clk(sys_clk), 
    .sys_rst(sys_rst), //计数器复位
   
    .data_in(drover_cnt),          //输入数据

    .count_start(drover_start_cnt),      //计数开始值
    .count_stop(drover_stop_cnt),       //计数结束值
    
    .pulse_valid_out()              //电平输出
    );
assign osk = ~drover;
endmodule