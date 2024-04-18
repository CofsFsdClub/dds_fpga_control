
module spi_clock#
(
	parameter	CLK_FREQ        = 50,
    parameter   CPOL            = 1'b0,
	parameter	SPI_CLK_FREQ    = 1000
)
(
	input       Clk_I,
	input       RstP_I,
	input       En_I,
	output      SCK_O,
	output      SCKEdge1_O,		    /* 时钟的第一个跳变沿 */
	output      SCKEdge2_O			/* 时钟的第二个跳变沿 */
);
/* SPI时序说明：1、当CPOL=1时，SCK在空闲时候为低电平，第一个跳变为上升沿
				2、当CPOL=0时，SCK在空闲时为高电平，第一个跳变为下降沿
*/
/* 时钟分频计数器 */
localparam	CLK_DIV_CNT = (CLK_FREQ * 1000)/SPI_CLK_FREQ;
reg         SCK;
reg         SCK_Pdg, SCK_Ndg;
reg[31:0]	ClkDivCnt;
/* 时钟分频计数器控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
		ClkDivCnt <= 32'd0;
	else if(!En_I)
        ClkDivCnt <= 32'd0;
    else begin
        if(ClkDivCnt == CLK_DIV_CNT - 1)
            ClkDivCnt <= 32'd0;
        else
            ClkDivCnt <= ClkDivCnt + 1'b1;
    end
end
/* SCK控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
        SCK <= (CPOL) ? 1'b1 : 1'b0;
    else if(!En_I)
        SCK <= (CPOL) ? 1'b1 : 1'b0;
    else begin
        if(ClkDivCnt == CLK_DIV_CNT - 1 || (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1))
            SCK <= ~SCK;
        else
            SCK <= SCK;
    end
end
/* SCK上升沿检测块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        SCK_Pdg <= 1'b0;
    else begin
        if(CPOL)
            SCK_Pdg <= (ClkDivCnt == CLK_DIV_CNT - 1) ? 1'b1 : 1'b0;
        else
            SCK_Pdg <= (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1) ? 1'b1 : 1'b0;
    end
end
 
/* SCK下降沿检测块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        SCK_Ndg <= 1'b0;
    else begin
        if(CPOL)
            SCK_Ndg <= (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1) ? 1'b1 : 1'b0;
        else
            SCK_Ndg <= (ClkDivCnt == CLK_DIV_CNT - 1) ? 1'b1 : 1'b0;
    end
end
/* 根据CPOL来选择边沿输出 */
assign SCKEdge1_O = (CPOL) ? SCK_Ndg : SCK_Pdg;
assign SCKEdge2_O = (CPOL) ? SCK_Pdg : SCK_Ndg;
assign SCK_O = SCK;
endmodule