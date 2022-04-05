//////////////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2022-04-05 09:56
// Project Name:   
// Module Name:   async_fifo
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// 
// Modification History:
// Date                   Change Descripton
// ---------------------------------------------------------------------------------------
// 2022-04-05             Initial
// 
//////////////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module async_fifo
#(  parameter DATAWIDTH = 8 ,
    parameter ADDRWIDTH = 5 )
(
    input  wire                 clk_wr,
    input  wire                 clk_rd,
    input  wire                 wrst_n,
    input  wire                 rrst_n,
    input  wire  [7:0]          I_data_in,
    input  wire                 I_wren,
    output wire  [7:0]          O_data_out,
    input  wire                 I_rden,
    output wire                 O_full,
    output wire                 O_empty
); 

//----------------variable declaration--------------//
reg  [ADDRWIDTH:0] wrptr,wrptr_r1,wrptr_r2,rdptr,rdptr_r1,rdptr_r2;
reg  [ADDRWIDTH:0] wrbin,rdbin;
wire [ADDRWIDTH:0] wrptr_next,rdptr_next,wrbin_next,rdbin_next;
wire [ADDRWIDTH-1:0] wraddr,rdaddr;
reg  full,empty;

//----------------Dual port RAM---------------------//
localparam DATADEPTH = 1<<ADDRWIDTH;
reg [DATAWIDTH-1:0] fifo_ram [DATADEPTH-1:0];
always @(posedge clk_wr) 
begin
    if(wrst_n & I_wren) begin
        fifo_ram[wraddr] <= I_data_in;
    end
end
assign O_data_out = fifo_ram[rdaddr];

//----------------------CDC---------------------------//
always@(posedge clk_wr or negedge wrst_n)
begin
    if(!wrst_n) begin
        rdptr_r1 <= 0;
        rdptr_r2 <= 0;
    end else begin
        rdptr_r1 <= rdptr;
        rdptr_r2 <= rdptr_r1;
    end
end
always@(posedge clk_rd or negedge rrst_n)
begin
    if(!rrst_n) begin
        wrptr_r1 <= 0;
        wrptr_r2 <= 0;
    end else begin
        wrptr_r1 <= wrptr;
        wrptr_r2 <= wrptr_r1;
    end
end

//-------------empty/full judgement-------------------//
always @(posedge clk_wr or negedge wrst_n) 
begin
    if(!wrst_n) begin
        wrptr <= 0;
        wrbin <= 0;
    end else begin
        wrptr <= wrptr_next;
        wrbin <= wrbin_next;
    end    
end
assign wrbin_next = (!full) ? (wrbin+1) : wrbin;
assign wrptr_next = (wrbin_next>>1) ^ wrbin_next;
assign wraddr = wrbin[DATAWIDTH-1:0];
always@(posedge clk_wr or negedge wrst_n)
begin
   if(!wrst_n) begin
       full <= 0;
   end else begin
       full <= (wrptr_next=={~rdptr_r2[DATAWIDTH:DATAWIDTH-1],rdptr_r2[DATAWIDTH-2:0]});
//        full <= 0;
   end
end
assign O_full = full;



always @(posedge clk_rd or negedge rrst_n) 
begin
    if(!rrst_n) begin
        rdptr <= 0;
        rdbin <= 0;
    end else begin
        rdptr <= rdptr_next;
        rdbin <= rdbin_next;
    end    
end
assign rdbin_next = (!empty) ? (rdbin+1) : rdbin;
assign rdptr_next = (rdbin_next>>1) ^ rdbin_next;
assign rdaddr = rdbin[DATAWIDTH-1:0];
always@(posedge clk_rd or negedge rrst_n)
begin
   if(!rrst_n) begin
       empty <= 1;
   end else begin
       empty <= (rdptr_next==wrptr_r2);
   end
end
assign O_empty = empty;

endmodule
`default_nettype wire