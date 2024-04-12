`timescale 1ns/1ps

module system(
//- - - - -奇怪的引脚 - - - - -//
  inout io_spi_clk, //莫名奇妙的bug 只有该引脚被定义后，500M时钟控制DDS的波形才可以正常产生

//- - - - -AD9910控制引脚 - - - - -//
  input drover,
  input io_update,
  output osk,
  output drctl,
  output drhold, //目前用不上

  output clk_locked, //调试阶段用作指示，封机阶段用作复位信号
  output master_reset,
  output sweep_sel,
  
  output spi_clk,
  output spi_mosi,
  input spi_miso,
  output spi_cs,

  input uart_rxd,
  output uart_txd,
  
//- - - - -FPGA全局引脚- - - - -//
                                        //记得可以试用一下 PD_clk 250M的时钟，实现FPGA与DDS时钟同源
  input clk_in,  //clk_50m
  input resetn_in  //高有效
);

//- - - - - - - - - - DDS初始化所需引脚 - - - - - - - - - - - - -//
/*
//外部GPIO 引脚定义
#define MASTER_RESET_PIN 	1
#define IO_UPDATE_PIN 		2
#define SPI_CS_PIN 			3
#define SWEEP_SEL_PIN 		4
*/

wire clk_1G;//试验无法成功触发，但是做了时序约束,可以让锁相环正常工作
wire clk_250m;
wire clk_500m;
wire clk_50m;

//- - - - - - - - - - 系统时钟 - - - - - - - - - - - - -//
    Gowin_PLL system_clk(
        .lock(clk_locked), //output lock
        .clkout0(clk_500m), //output clkout0
        .clkout1(clk_50m), //output clkout1
        .clkin(clk_in), //input clkin
        .reset(resetn_in) //input reset
    );
//- - - - - - - - - - DDS时序控制部分 - - - - - - - - - - - - -//
parameter FRE = 10000;
parameter PULSE = 2000; //实际脉宽为FULSE/2 us
parameter CLKNUM50M = 20;//时钟 1/50MHz = 20ns 
parameter CLKNUM250M = 4;//时钟 1/250MHz = 4ns

parameter CLKNUM500M = 2;//时钟 1/500MHz = 2ns 时序紧张
parameter CLKNUM1G = 1;//时钟 1/1G = 1ns 时序紧张
     
assign sweep_sel = 1'b1;//给到软核端口控制,仿真中给定制
assign drhold = 1'b0;

dds_time_control#(
    .FRE(FRE),//Hz  10kHz
    .PULSE(PULSE),//ns 2us
    .CLKNUM(CLKNUM500M) //ns 
) dds_control(
    .sys_clk(clk_500m),//250MHz
    .sys_rst(resetn_in),
    
    .drover(drover),
    .io_update(io_update),
    
    .sweep_sel(sweep_sel),
    
    .osk(osk),
    .drctl(drctl),
    .drhold(drhold),
   
    );
//- - - - - - - - - - DDS串口指令解析部分 - - - - - - - - - - - - -//
parameter UART_BPS = 115200; //串口波特率
parameter CLK_FREQ = 50000000; //串口时钟
wire [7:0]  addr_data;
wire [7:0] cmd_data;

wire addr_data_valid;
wire cmd_data_valid;

uart_decode#(
    .UART_BPS(UART_BPS),
    .CLK_FREQ(CLK_FREQ),
    .HEAD_FREAME(8'hA6), //8'hA6 定义头帧
    .END_FREAME(8'hCE) //8'hCE 定义尾帧
)uart_rec_decode(
    .sys_clk(clk_50m),			//50M系统时钟
    .sys_rst_n(resetn_in),			//系统复位
    
    .uart_rxd(uart_rxd),          //串口接收引脚
    
    .addr_data(addr_data),
    .cmd_data(cmd_data),
    .addr_data_valid(addr_data_valid),
    .cmd_data_valid(cmd_data_valid)
);

//放在这里测试用
uart_tx#(
	.BPS		    (UART_BPS),
	.SYS_CLK_FRE	(CLK_FREQ))
u_uart_tx(
	.sys_clk		(clk_50m),
	.sys_rst_n	    (resetn_in),
	.uart_tx_en		(cmd_data_valid),
	.uart_data	    (cmd_data),	
	.uart_txd	    (uart_txd)
);


endmodule