`timescale 1ns/1ps
module tb_dds_control();
    reg            sclk              ;    // System Clock.
    reg            srstn             ;    // System Reset. Low Active 
    reg  [ 7 : 0]  sclk_divider      ;    // SPI Clock Control 
    reg            wr_start          ;    // ReRAM Write  Start 
    reg            rd_start          ;    // ReRAM Read   Start  

    wire           wr_finish         ;    // ReRAM Write  Finish 
    wire           rd_finish         ;    // ReRAM Read   Finish

    reg   [ 7 : 0] start_addr        ;    // Write / Read Start Address
    reg   [ 7 : 0] state_init        ; 

    reg   [ 7 : 0] rx_rd_data        ;    // Rx BRAM Read Data
    wire  [ 7 : 0] tx_wr_data        ;    // Tx BRAM Write Data

    wire           SPI_SCLK          ;   // Reram SPI Clock 
    wire           SPI_CSN           ;    // ReRAM SPI Chip Select 
    wire           SPI_MOSI          ;    // ReRAM SPI Master Output 
    reg            SPI_MISO          ;    // ReRAM SPI Master Input
    
  //==============================================================
// initial  value
//==============================================================
    initial begin
    
        sclk         = 1'b0 ;
        SPI_MISO     = 1'b0 ;
        
        srstn        = 1'b0 ;
        rd_start     = 1'b0 ;
        wr_start     = 1'b0 ;
        start_addr   = 8'h0 ;
        rx_rd_data   = 8'h0 ;
        sclk_divider = 8'h0 ;
        #100
        srstn        = 1'b1 ;
        #150
        rx_rd_data   = 8'haa;
        rd_start     = 1'b0 ;
        wr_start     = 1'b1 ;
        start_addr   = 8'h55;
        state_init   = 8'haf;
        sclk_divider = 8'h1 ;
        #200
        rd_start     = 1'b0 ;
        wr_start     = 1'b0 ;
       // $monitor  (" r_tx_bram_wr_data:%h", r_tx_wr_data);
    end
 
    always #50    sclk     = ~sclk; 
  //  always #400   SPI_MISO = ~SPI_MISO  ; 

   spi_master_drive SPI_Master_init (
    .sclk        (sclk        ),    // System Clock.
    .srstn       (srstn       ),    // System Reset. Low Active 
    .sclk_divider(sclk_divider),    // SPI Clock Control / Divid
    .wr_start    (wr_start    ),    // Write  Start 
    .rd_start    (rd_start    ),    // Read   Start  

    .wr_finish   (wr_finish   ),    // Write  Finish 
    .rd_finish   (rd_finish   ),    // Read   Finish

    .start_addr  (start_addr  ),    // Write / Read Start Address
    .state_init  (state_init  ),    // slaver state initial  
    .rx_rd_data  (rx_rd_data  ),    // Rx Read Data
    .tx_wr_data  (tx_wr_data  ),    // Tx Write Data

    .SPI_SCLK    (SPI_SCLK    ),    // SPI Clock 
    .SPI_CSN     (SPI_CSN     ),    // SPI Chip Select 
    .SPI_MOSI    (SPI_MOSI    ),    // SPI Master Output 
    .SPI_MISO    (SPI_MISO    )     // SPI Master Input
);
endmodule