`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Çç¿Õ-Tiso£¨BÕ¾Í¬Ãû£©
// 
// Create Date: 2023/12/31 19:51:51
// Design Name: 
// Module Name: string_compare
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
    string_compare #(.byte_num()) STR_CMP0(
        .equal(),
        .greater(),
        .less(),
        .string_in0(),
        .string_in1()
        );
*/

module string_compare #(parameter byte_num = 1)(
    output reg equal,
    output reg greater,
    output reg less,
    input[byte_num * 8 - 1 : 0] string_in0,
    input[byte_num * 8 - 1 : 0] string_in1
    );
    
    always@(*) begin
        if(string_in0 == string_in1)
            {equal,greater,less} <= 3'b100;
        else if(string_in0 > string_in1)
            {equal,greater,less} <= 3'b010;
        else
            {equal,greater,less} <= 3'b001;
    end
    
endmodule
