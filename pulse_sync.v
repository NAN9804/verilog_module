//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/09/27
// Project Name:  
// Module Name:   pulse_sync
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// 适用于单比特数据的单周期脉冲跨时钟域的脉冲同步器
//
// Modification History:
// Date                   Change Descripton
// -------------------------------------------------------------------------------
// 2021/09/27             Initial
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module pulse_sync(
    input   wire        clk_in,
    input   wire        rst_in_n,
    input   wire        pulse_in,
    input   wire        clk_out,
    input   wire        rst_out_n,
    output  wire        pulse_out
);

reg R_in_change = 0;
always@(posedge clk_in or negedge rst_in_n)
begin
    if(!rst_in_n)
        R_in_change <= 0;
    else if(pulse_in)
        R_in_change <= ~R_in_change;
end

reg [2:0] R_out_change = 0;
always@(posedge rst_out_n or negedge rst_out_n)
begin
    if(!rst_out_n)
        R_out_change <= 0;
    else
        R_out_change <= {R_out_change[1:0],R_in_change};
end

assign pulse_out = R_out_change[1] ^ R_out_change[2];

endmodule
`default_nettype wire