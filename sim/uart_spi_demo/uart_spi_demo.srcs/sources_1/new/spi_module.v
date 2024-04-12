`timescale  1ns/1ps
module spi_module   #(parameter WORD_SIZE=8)(
    input       wire                        sclk,
    input       wire                        rst_n,
    input       wire                        tx_en,
    input       wire                        rx_en,
    input       wire [WORD_SIZE-1:0]        data_in,
    input       wire                        data_vld,
    output      wire [WORD_SIZE-1:0]        data_ou,
    output      reg                         tx_done,
    output      reg                         rx_done,
    //spi interface
    output      reg                         spi_cs_n,
    output      reg                         spi_clk,
    output      wire                        spi_mosi,//MSI first send
    input       wire                        spi_miso
);

reg [3:0]   tx_state;
reg [3:0]   rx_state;

reg [WORD_SIZE-1:0] shift_in_reg;
reg [WORD_SIZE-1:0] shift_ou_reg;
reg                 shift_in;
reg                 shift_ou;

reg                 tx_done_r;
reg                 rx_done_r;

always  @(posedge   sclk or negedge rst_n)begin
    if(rst_n==1'b0) begin
        tx_done_r<=1'b0;
        rx_done_r<=1'b0;
        spi_cs_n<=1'b1;
        spi_clk<=1'b0;//mode 0
        //spi_mosi<=1'bz;
        tx_state<=4'd0;
        rx_state<=4'd0;
        shift_in<=1'b0;
        shift_ou<=1'b0;
    end
    else    if(tx_en==1'b1)begin
        spi_cs_n<=1'b0;
        case(tx_state)
            4'd1,4'd3,4'd5,4'd7,4'd9,4'd11,4'd13:begin
                spi_clk<=1'b1;
                tx_state<=tx_state+1'b1;
                shift_in<=1'b1;
            end
            4'd0,4'd2,4'd4,4'd6,4'd8,4'd10,4'd12,4'd14:begin
                spi_clk<=1'b0;
                tx_state<=tx_state+1'b1;
                shift_in<=1'b0;
            end
            4'd15:begin
                spi_clk<=1'b1;
                tx_state<=4'd0;
                shift_in<=1'b1;
                tx_done_r<=1'b1;
            end
            default:tx_state<=4'd0;
        endcase
    end
    else    if(rx_en==1'b1)begin
        spi_cs_n<=1'b0;
        case(rx_state)
            4'd1,4'd3,4'd5,4'd7,4'd9,4'd11,4'd13:begin
                spi_clk<=1'b1;
                rx_state<=rx_state+1'b1;
                shift_ou<=1'b0;
            end
            4'd0,4'd2,4'd4,4'd6,4'd8,4'd10,4'd12,4'd14:begin
                spi_clk<=1'b0;
                rx_state<=rx_state+1'b1;
                shift_ou<=1'b1;
            end
            4'd15:begin
                spi_clk<=1'b1;
                rx_state<=rx_state+1'b1;
                shift_ou<=1'b0;
                rx_done_r<=1'b1;
            end
            default:rx_state<=4'd0;
        endcase
    end
    else    begin
        tx_done_r<=1'b0;
        rx_done_r<=1'b0;
        spi_cs_n<=1'b1;
        spi_clk<=1'b0;//mode 0
        //spi_mosi<=1'bz;
        tx_state<=4'd0;
        rx_state<=4'd0;
        shift_in<=1'b0;
        shift_ou<=1'b0;
    end
end

always  @(posedge   sclk or negedge rst_n)begin
    if(rst_n==1'b0) shift_in_reg<='d0;
    else    if(data_vld==1'b1)
        shift_in_reg<=data_in;
    else    if(shift_in==1'b1)
        shift_in_reg<=shift_in_reg<<1;
end
assign  spi_mosi=shift_in_reg[WORD_SIZE-1];

always  @(posedge   sclk or negedge rst_n)begin
    if(rst_n==1'b0) shift_ou_reg<=4'd0;
    else    if(shift_ou==1'b1)
        shift_ou_reg<={shift_ou_reg[WORD_SIZE-2:0],spi_miso};
end

assign  data_ou=(rx_done==1'b1)? shift_ou_reg:{{WORD_SIZE{1'hz}}};

always  @(posedge   sclk or negedge rst_n)begin
    if(rst_n==1'b0) begin
        tx_done<=1'b0;
        rx_done<=1'b0;
    end
    else    begin
        tx_done<=tx_done_r;
        rx_done<=rx_done_r;
    end
end

endmodule