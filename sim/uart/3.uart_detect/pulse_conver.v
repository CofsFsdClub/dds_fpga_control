`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Çç¿Õ-Tiso£¨BÕ¾Í¬Ãû£©
// 
// Create Date: 2023/12/20 01:45:24
// Design Name: 
// Module Name: pulse_conver
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

/*
    pulse_conver #(.width(),.filt_value()) PC0(
        .pulse_out(),
        .pulse_in(),
        .clk(),
        .rst()
        );
*/

module pulse_conver #(parameter width = 8,filt_value = 8'hff)(
    output reg pulse_out,
    input pulse_in,
    input clk,
    input rst
    );
    
    reg[width-1:0] pulse_shift;
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            pulse_shift <= 0;
        else
            pulse_shift <= {pulse_shift[width-2:0],pulse_in};
    end
    
    always@(*)
    begin
        if(rst)
            pulse_out = 0;
        else if(pulse_shift == filt_value)
            pulse_out = 1;
        else
            pulse_out = 0;
    end
    
endmodule
