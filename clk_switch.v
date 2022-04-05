//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/05/26
// Project Name:  
// Module Name:   clk_switch
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// 两个时钟之间进行无毛刺转换
//
// Modification History:
// Date                   Change Descripton
// -------------------------------------------------------------------------------
// 2021/05/26             Initial
//
//////////////////////////////////////////////////////////////////////////////////

module clk_switch
(
    input   wire        clkA,
    input   wire        clkB,       
    input   wire        rst,
    input   wire        select,     //1->clkA, 0->clkB
    output  wire        clkout
);

    reg     DA1;
    reg     DA2;
    reg     DB1;
    reg     DB2;
    
    always @(posedge clkA)begin
        if(rst)begin
            DA1 <= 0;
        end
        else begin
            DA1 <= ~DB2 & select;
        end
    end
    
    always @(negedge clkA)begin
        if(rst)begin
            DA2 <= 0;
        end
        else begin
            DA2 <= DA1;
        end
    end
    
    always @(posedge clkB)begin
        if(rst)begin
            DB1 <= 0;
        end
        else begin
            DB1 <= ~select & ~DA2;
        end
    end
    
    always @(negedge clkB)begin
        if(rst)begin
            DB2 <= 0;
        end
        else begin
            DB2 <= DB1;
        end
    end
    
    assign clkout = (DA2 & clkA) | (DB2 & clkB);

endmodule