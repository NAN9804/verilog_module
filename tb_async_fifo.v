`timescale  1ns / 1ps

module tb_async_fifo;

// async_fifo Parameters
parameter DATAWIDTH  = 8;
parameter ADDRWIDTH  = 5;

// async_fifo Inputs
reg   clkwr = 0;
reg   clkrd = 0;
reg   wrstn = 0;
reg   rrstn = 0;
reg   [7:0]  datain = 8'hF7;
reg   wren = 0;
reg   rden = 0;

// async_fifo Outputs
wire  [7:0]  dataout;
wire  full = 0;
wire  empty = 1;


parameter PERIOD_wr = 20;
parameter PERIOD_rd = 40;
always #(PERIOD_wr/2)  clkwr=~clkwr;
always #(PERIOD_rd/2)  clkrd=~clkrd;

initial
begin
    wren = 1;
    #(PERIOD_wr*2) 
    #(PERIOD_rd*2) rrstn  =  1;wrstn  =  1;
    #(PERIOD_wr*10) datain = 8'h7E;
    #500 wren = 0;
    #20  rden = 1;
    #400 rden = 0; datain = 8'h56;
    #30  wren = 1;
end

async_fifo #(
    .DATAWIDTH (8) ,
    .ADDRWIDTH (5)
) u_async_fifo (
    .clk_wr          (clkwr),
    .clk_rd          (clkrd),
    .wrst_n          (wrstn),
    .rrst_n          (rrstn),
    .I_data_in       (datain),
    .I_wren          (wren),
    .O_data_out      (dataout),
    .I_rden          (rden),
    .full          (full),
    .empty         (empty)
);

endmodule