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

  output master_reset,
  output pf0,
  output pf1,
  output pf2,
  output exit_pwr_over,
  output txenable,

  output clk_locked, //调试阶段用作指示，封机阶段用作复位信号  
  output sweep_sel, //调试阶段用作指示
  
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

assign master_reset = ~clk_locked;
assign pf0 = 1'b0;
assign pf1 = 1'b0;
assign pf2 = 1'b0;
assign exit_pwr_over = 1'b0;
assign txenable = 1'b0;
//- - - - - - - - - - 系统时钟 - - - - - - - - - - - - -//
wire clk_250m;
wire clk_500m;
wire clk_500mA;
wire clk_50m;

    Gowin_PLL system_clk(
        .lock(clk_locked), //output lock
        .clkout0(clk_500mA), //output clkout0
        .clkout1(clk_50m), //output clkout1
        .clkin(clk_in), //input clkin
        .reset(resetn_in) //input reset
    );
   Gowin_DCE sysclk_bufg(
        .clkout(clk_500m), //output clkout
        .clkin(clk_500mA), //input clkin
        .ce(clk_locked) //input ce
    );

//- - - - - - - - - - DDS串口指令解析部分  - - - - - - - - - - - - -//
parameter UART_BPS = 115200; //串口波特率
parameter CLK_FREQ = 50000000; //串口时钟
wire pulse_position;
wire [15:0]triger_pulse;
dds_cmd_set#(
    .UART_BPS(UART_BPS),
    .CLK_FREQ(CLK_FREQ),			/* 模块时钟输入，单位为MHz */
	.SPI_CLK(2000),		    /* SPI时钟频率，单位为KHz */
    .HEAD_FREAME_1(8'hAA), //定义头帧1
    .HEAD_FREAME_2(8'h55),//定义头帧2
    .END_FREAME(8'hCE) //定义尾帧	
 ) dds_cmd_set(
    .sys_clk(clk_50m),			//50M系统时钟
	.sys_rst(resetn_in),			//系统复位

	.pulse_position(pulse_position),
    .triger_pulse(triger_pulse), //设置脉宽

    .uart_rxd(uart_rxd),
	.uart_txd(uart_txd),

    .SCK_O(spi_clk),
	.MOSI_O(spi_mosi),
	.MISO_I(spi_miso),
	.CS_O(spi_cs)
);


//- - - - - - - - - - DDS时序控制部分 - - - - - - - - - - - - -//
//parameter FRE = 10000;
//parameter PULSE = 2000; //实际脉宽为FULSE/2 us
parameter CLKNUM50M = 20;//时钟 1/50MHz = 20ns 
parameter CLKNUM250M = 4;//时钟 1/250MHz = 4ns
parameter CLKNUM500M = 2;//时钟 1/500MHz = 2ns 时序紧张
assign sweep_sel = pulse_position;//给到软核端口控制 取pulse_position的第一位
assign drhold = 1'b0;

dds_control_v5#(
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

    .triger_pulse(triger_pulse)//ns 2us   
    );

endmodule