//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:   2021/09/27
// Project Name:  
// Module Name:   mux_sync
// Engineer:      NAN
// 
// Version:       1.0
// Description: 
// �����ڶ�������ݵĿ�ʱ����ͬ��������ʹ���źſ��ƣ�MUXͬ������
//
// Modification History:
// Date                   Change Descripton
// -------------------------------------------------------------------------------
// 2021/09/27             Initial
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module mux_sync(

    input   wire        clka,
    input   wire        clkb,
    input   wire        rst,
    input   wire [3:0]  data_bus,
    input   wire        En,
    output  reg  [3:0]  data_bus_b

    );

    reg             En_a;
    reg             En_b1;
    reg             En_b2;
    reg     [3:0]   data_bus_a;

    wire    [3:0]   data_bus_mux;

    //ʱ����a��ͬ���������ݼ�����Ч��־�źţ�����ʱ��
    always@(posedge clka or posedge rst) begin
        if(rst) begin
            En_a <= 1'b0;
            data_bus_a <= 4'd0;      
        end
        else begin
            En_a <= En;
            data_bus_a <= data_bus;
        end
    end

    //��������Ч��־�ź�ͬ����bʱ��������ͬ����
    always@(posedge clkb or posedge rst) begin
        if(rst) begin
            En_b1 <= 1'b0   ;
            En_b2 <= 1'b0;
        end
        else begin
            En_b1 <= En_a;
            En_b2 <= En_b1;
        end
    end

    // //д��1��
    // assign data_bus_mux = En_b2 ? data_bus_a : data_bus_b;

    // always@(posedge clkb or posedge rst) begin
    //     if(rst) begin
    //         data_bus_b <= 4'b0;
    //     end
    //     else begin
    //         data_bus_b <= data_bus_mux;
    //     end
    // end

    //д��2��
    always@(posedge clkb or posedge rst) begin
        if(rst) begin
            data_bus_b <= 4'b0;
        end
        else if(En_b2) begin
            data_bus_b <= data_bus_a;
        end
        else begin
            data_bus_b <= data_bus_b;
        end
    end

endmodule
`default_nettype wire