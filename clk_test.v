//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           clk_test
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        clk_test
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module clk_test(
     input        clk_in     ,                 // ����ʱ��
     input        rst_n      ,                 // ��λ�ź�

     output  reg  clk_out                      // ���ʱ��
);
//paramater define
parameter       DIV_N = 26'd100;
//reg define
reg [25:0] cnt;                                 // ʱ�ӷ�Ƶ����

//*****************************************************
//**                    main code
//*****************************************************

//ʱ�ӷ�Ƶ������500KHz�Ĳ���ʱ��
always @(posedge clk_in or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        cnt     <= 0;
        clk_out <= 0;
    end
    else begin
        if(cnt == DIV_N/2 - 1'b1) begin
            cnt     <= 26'd0;
            clk_out <= ~clk_out;
        end
        else
            cnt <= cnt + 1'b1;
    end
end

endmodule