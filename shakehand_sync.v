//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/09/27
// Project Name:  
// Module Name:   shakehand_sync
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// �����ڶ�������ݵĿ�ʱ����ͬ������������Э��
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
    input   wire       a_en         , //�����ⲿ��ʹ���źţ��������һ��ʱ������
    input   wire [3:0] data_a_in    , //�ⲿ�����ź�
    output  reg  [3:0] data_b_out   ,
    output  wire       b_en         ,
    output  wire       ack_syn_out
);

    //���������ź�
    reg req; 
    reg ack_syn;
    always@(posedge clk_a or posedge rst) begin
        if(rst)
            req <= 1'b0;
        else if(a_en) 
            req <= 1'b1;
        else if(ack_syn)  //req ��������
            req <= 1'b0;

    end

    //�����ź�req��ʱ������
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

    //����ʱ����b�ڵ�����ʹ���źš���req_syn�źŵ�������
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

    //bʱ�����aʱ�������Ӧ�ź�
    reg     ack;
    always@(posedge clk_b or posedge rst) begin
        if(rst)
            ack <= 1'b0;            
        else
            ack <= req_syn;
    end

    //b_en��Ч�����ʾ������Ч�����Բ���aʱ�����������
    always@(posedge clk_b or posedge rst) begin
        if(rst) begin
            data_b_out <= 4'd0;
        end
        else if(b_en) begin
            data_b_out <= data_a_in;
        end
    end

    //��Ӧ�ź�ͬ����aʱ����
    //ack_syn��������Ϊa_req���͵�����
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

    assign ack_syn_out = ack_syn; //���ź���Ϊa_en�ķ����źţ���⵽���ź��½��ؿɿ�ʼ��һ�����ݴ���

endmodule
`default_nettype wire