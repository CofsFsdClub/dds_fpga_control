`timescale  1ns/1ns
module tb_spi_module #(parameter    WORD_SIZE=8)();

reg                 sclk;
reg                 rst_n;
reg                 tx_en;
reg                 rx_en;
reg [WORD_SIZE-1:0] data_in;
reg                 data_vld;
wire [WORD_SIZE-1:0]    data_ou;
wire                tx_done;
wire                rx_done;
wire                spi_cs_n;
wire                spi_clk;
wire                spi_mosi;
reg                 spi_miso;

initial begin
    sclk=1'b0;
    forever #10 sclk=~sclk;
end

initial begin
    rst_n=1'b0;
    #100    rst_n=1'b1;
end

initial begin
    rx_en=1'b0;
//  tx_en=1'b1;//send data
    spi_miso=1'b0;
end

initial begin
    #100    data_in=8'haa;data_vld=1'b1;
    #20     data_vld=1'b0;
    #400    data_in=8'hfb;data_vld=1'b1;
    #20     data_vld=1'b0;
    #400    data_in=8'h99;data_vld=1'b1;
    #20     data_vld=1'b0;
end

initial begin
    tx_en=1'b0;
    #150    tx_en=1'b1;
    @(tx_done)  tx_en=1'b0;
    #150    tx_en=1'b1;
    @(tx_done)  tx_en=1'b0;
    #150    tx_en=1'b1;
    @(tx_done)  tx_en=1'b0;
end


spi_module  spi_module_inst(
.   sclk    (   sclk    )   ,
.   rst_n   (   rst_n   )   ,
.   tx_en   (   tx_en   )   ,
.   rx_en   (   rx_en   )   ,
.   data_in (   data_in )   ,
.   data_vld(   data_vld)   ,
.   data_ou (   data_ou )   ,
.   tx_done (   tx_done )   ,
.   rx_done (   rx_done )   ,
.   spi_cs_n(   spi_cs_n)   ,
.   spi_clk (   spi_clk )   ,
.   spi_mosi(   spi_mosi)   ,//MSI first send
.   spi_miso(   spi_miso)   
);


endmodule