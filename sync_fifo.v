//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/09/27
// Project Name:  
// Module Name:   sync_fifo
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// 适用于VIVADO的同步FIFO
//
// Modification History:
// Date                   Change Descripton
// -------------------------------------------------------------------------------
// 2021/09/27             Initial
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module sync_fifo
#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 64,
    parameter ADDR_WIDTH = 6
)
(
	input   wire                      clk,
	input   wire                      rst_n,
	input   wire  [DATA_WIDTH-1:0]    wr_data,
	input   wire                      rq,  //read request
	input   wire                      wq,  //write request
	output  reg   [DATA_WIDTH-1:0]    rd_data,
	output  wire                      full,
	output  wire                      empty
);
//internal signal
(* ram_style = "block" *) reg [DATA_WIDTH-1:0] fifo_mem [DATA_DEPTH-1:0];//使用BRAM
reg[ADDR_WIDTH:0]  counter; //extra one bit for counter
reg[ADDR_WIDTH-1:0] rd_ptr;
reg[ADDR_WIDTH-1:0] wr_ptr;

//set full and empty
assign   full  = (counter==DATA_DEPTH) ? 1'b1 : 1'b0;
assign   empty = (counter==0) ? 1'b1 : 1'b0;

//set current fifo  counter value
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		counter<=0;
	else if((wq && full)||(rq && empty))
		counter <= counter;
	else  if(rq&&!empty)
		counter <= counter - 1;
	else  if(wq&&!full)
		counter <= counter + 1;
	else
		counter <= counter;   //no read, no write, keep no change
end
//read data if no empty and read enable
always @(posedge clk or negedge rst_n )
begin
	if(!rst_n) begin
		rd_data <= 0;
	end
	else if(rq && !empty)
		rd_data <= fifo_mem[rd_ptr];
end
//write data if no full and write enable
always @(posedge clk)
begin
	if(wq && !full)
		fifo_mem[wr_ptr] <= wr_data;
end
    
//update read and write ptr
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
        begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
	else
        begin
            if(!full && wq)
                begin
                    wr_ptr <= wr_ptr + 1;
                    // we can omit these two lines, for it will change to 0 if overflow.
                    //if(wr_ptr==(FIFO_DEPTH-1))
                    //	wr_ptr<=0;
                end
            else if(!empty && rq)
                begin
                    rd_ptr <= rd_ptr + 1;
                    //if(rd_ptr==(FIFO_DEPTH-1))
                    //	rd_ptr<=0;
                end
        end
end

endmodule
`default_nettype wire