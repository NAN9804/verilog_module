//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/09/27
// Project Name:  
// Module Name:   shakehand_sync
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// 适用于多比特数据的跨时钟域同步器——握手协议
//
// Modification History:
// Date                   Change Descripton
// -------------------------------------------------------------------------------
// 2021/09/27             Initial
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module shakehand_sync
(
    input   wire       clk_a        ,
    input   wire       clk_b        ,
    input   wire       rst          ,
    input   wire       a_en         , //来自外部的使能信号，脉冲持续一个时钟周期
    input   wire [3:0] data_a_in    , //外部输入信号
    output  reg  [3:0] data_b_out   ,
    output  wire       b_en         ,
    output  wire       ack_syn_out
);

    //生成请求信号
    reg req; 
    reg ack_syn;
    always@(posedge clk_a or posedge rst) begin
        if(rst)
            req <= 1'b0;
        else if(a_en) 
            req <= 1'b1;
        else if(ack_syn)  //req 拉低条件
            req <= 1'b0;

    end

    //请求信号req跨时钟域处理
    reg     req_b, req_syn;
    always@(posedge clk_b or posedge rst) begin
        if(rst) begin
            req_b <= 1'b0;
            req_syn <= 1'b0;
        end
        else begin
            req_b <= req;
            req_syn <= req_b;
        end
    end

    //生成时钟域b内的数据使能信号——req_syn信号的上升沿
    reg     req_syn_r1;
    always@(posedge clk_b or posedge rst) begin
        if(rst) begin
            req_syn_r1 <= 1'b0;          
        end
        else begin
            req_syn_r1 <= req_syn;
        end
    end
    assign b_en = ~req_syn_r1 && req_syn;

    //b时钟域对a时钟域的响应信号
    reg     ack;
    always@(posedge clk_b or posedge rst) begin
        if(rst)
            ack <= 1'b0;            
        else
            ack <= req_syn;
    end

    //b_en有效，则表示数据有效，可以采样a时钟域的数据了
    always@(posedge clk_b or posedge rst) begin
        if(rst) begin
            data_b_out <= 4'd0;
        end
        else if(b_en) begin
            data_b_out <= data_a_in;
        end
    end

    //响应信号同步到a时钟域
    //ack_syn上升沿作为a_req拉低的条件
    reg ack_a;
    always@(posedge clk_a or posedge rst) begin
        if(rst) begin
            ack_a <= 1'b0;
            ack_syn <= 1'b0;
        end
        else begin
            ack_a <= ack;
            ack_syn <= ack_a;
        end
    end

    assign ack_syn_out = ack_syn; //此信号作为a_en的反馈信号，检测到此信号下降沿可开始下一次数据传输

endmodule
`default_nettype wire