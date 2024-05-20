//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           cymometer
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        cymometer
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module cymometer#(
    parameter   CNT_GATE_MAX = 28'd75_000_000,      // ��Ƶ����ʱ��Ϊ1.5s 
    parameter   CNT_TIME_MAX = 28'd100_000_000,     // ��������ʱ��Ϊ2s     
    parameter   CNT_GATE_LOW = 28'd12_500_000,      // բ��Ϊ�͵�ʱ��0.25s
    parameter   CLK_FS_FREQ  = 28'd100_000_000
)(
    input               sys_clk,            // ϵͳʱ�ӣ�50M
    input               clk_fs,             // ��׼ʱ�ӣ�100M
    input               sys_rst_n,          // ϵͳ��λ���͵�ƽ��Ч
    input               clk_fx,             // ����ʱ���ź�

    output reg [29:0]   data_fx,            // ����ʱ��Ƶ��ֵ

    input  wire         ready,              // ֵ�ɱ�����
    input wire [56:0]   quotient,           // ��
    input wire [56:0]   remainder,          // ����
    input wire          vld_out,            // ֵ��Ч

    output reg [56:0]   dividend,           // ������
    output reg [56:0]   divisor,            // ����
    output reg          en                  // ��ʼ�ź�
 
);
//
localparam TIME = 10'd150;                   // �����ȶ�ʱ��
//reg define
reg             gate_sclk;
reg     [27:0]  cnt_gate_fs;
reg             gate_fx;
reg             gate_fx_d0;
reg             gate_fx_d1;
reg             gate_fx_d2;
reg             gate_fx_d3;
reg             gate_fs;
reg             gate_fs_d0;
reg             gate_fs_d1;
reg     [29:0]  cnt_fx;
reg     [29:0]  cnt_fx_reg;
reg     [29:0]  cnt_fs;
reg     [29:0]  cnt_fs_reg;
reg     [29:0]  cnt_fs_reg_reg;
reg             calc_flag;
reg     [56:0]  numer;
reg             fx_flag;
reg     [56:0]  numer_reg;
reg     [27:0]  cnt_dely;
reg             flag_dely;
//wire define
wire            gate_fx_pose;       // ������
wire            gate_fx_nege;       // �½���
wire            gate_fs_nege;       // �½���

//*****************************************************
//**                    main code
//*****************************************************

// ���㹫ʽ CLK_FX_FREQ = cnt_fx*CLK_FS_FREQ/cnt_fs
assign gate_fx_pose = ((gate_fx) && (!gate_fx_d3))? 1'b1:1'b0;//������
assign gate_fx_nege = ((!gate_fx_d2) && gate_fx_d3)? 1'b1:1'b0;//�½���
assign gate_fs_nege = ((!gate_fs_d0) && gate_fs_d1)? 1'b1:1'b0;//�½���

// �������բ��ʱ������� cnt_gate_fs 1.5s
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_gate_fs <= 28'd0;
    else if(cnt_gate_fs == CNT_GATE_MAX - 1'b1 )
        cnt_gate_fs <= 28'd0;
    else
        cnt_gate_fs <= cnt_gate_fs + 1'b1;
end

// �������բ�� GATE_SCLK 
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        gate_sclk <= 1'b0;
    else if(cnt_gate_fs == CNT_GATE_LOW - 1'b1)
        gate_sclk <= 1'b1;
    else if(cnt_gate_fs == CNT_GATE_MAX - CNT_GATE_LOW - 1'b1)
        gate_sclk <= 1'b0;
    else
        gate_sclk <= gate_sclk;
end

// �����բ��ͬ��������ʱ���µõ�ʵ��բ��,�����д��Ļ�ȡ�����غ��½���
always@(posedge clk_fx or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        gate_fx <= 1'b0;
        gate_fx_d0 <= 1'b0;
        gate_fx_d1 <= 1'b0;
        gate_fx_d2 <= 1'b0;
        gate_fx_d3 <= 1'b0;
        end
    else begin
        gate_fx <= gate_sclk;
        gate_fx_d0 <= gate_fx;
        gate_fx_d1 <= gate_fx_d0;
        gate_fx_d2 <= gate_fx_d1;
        gate_fx_d3 <= gate_fx_d2;
        end
end

// ��ȡʵ��բ�ŵ��½��� �ڻ�׼ʱ���»�ȡ�½���
always@(posedge clk_fs or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        gate_fs <= 1'b0;
        gate_fs_d0 <= 1'b0;
        gate_fs_d1 <= 1'b0;
        end
    else begin
        gate_fs <= gate_fx;
        gate_fs_d0 <= gate_fs;
        gate_fs_d1 <= gate_fs_d0;
        end
end

// ��ʵ��բ���·ֱ����ʱ�������� cnt_fx(����ʱ��) cnt_fs(��׼ʱ��)
// ����ʱ���µ����ڸ��� cnt_fx
always@(posedge clk_fx or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_fx <= 30'd0;
    else if(gate_fx_d2)
        cnt_fx <= cnt_fx + 1'b1;
    else if(!gate_fx_d2)
        cnt_fx <= 30'd0;
    else
        cnt_fx <= cnt_fx;  
end

// ���½��ؽ�����ʱ�ӵ�ʱ�����������л���
always@(posedge clk_fx or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_fx_reg <= 30'd0;
    else if(gate_fx_nege)
        cnt_fx_reg <= cnt_fx;
    else
        cnt_fx_reg <= cnt_fx_reg;
end

// ��׼ʱ���µ����ڸ��� cnt_fs
always@(posedge clk_fs or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_fs <= 30'd0;
    else if(gate_fx)
        cnt_fs <= cnt_fs + 1'b1;
    else if(gate_fs_nege)
        cnt_fs <= 30'd0;
    else
        cnt_fs <= cnt_fs;  
end

// ���½��ؽ���׼ʱ�ӵ�ʱ�����������л���
always@(posedge clk_fs or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_fs_reg <= 30'd0;
    else if(gate_fs_nege)
        cnt_fs_reg <= cnt_fs;
    else
        cnt_fs_reg <= cnt_fs_reg;
end

// CLK_FX_FREQ = cnt_fx*CLK_FS_FREQ/cnt_fs
// �ȼ���õ����� cnt_fx*CLK_FS_FREQ
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        numer <= 57'd0;
    else if(cnt_gate_fs == CNT_GATE_MAX - CNT_GATE_LOW + TIME)
        numer <= cnt_fx_reg * CLK_FS_FREQ;
    else
        numer <= numer;
end

// ��һ�ĶԼ���õ���ֵ numer_reg(����) ����ͬ�����Ĵ�
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        numer_reg <=57'd0;
    else if(cnt_gate_fs == (CNT_GATE_MAX - (CNT_GATE_LOW / 2'd2) - TIME))
        numer_reg <= numer;
    else
        numer_reg <= numer_reg;
end

// ��һ�ĶԼ���õ���ֵ cnt_fs_reg_reg(��ĸ) ����ͬ�����Ĵ�
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_fs_reg_reg <=30'd0;
    else if(cnt_gate_fs == (CNT_GATE_MAX - (CNT_GATE_LOW / 2'd2)- TIME))
        cnt_fs_reg_reg <= cnt_fs_reg;
    else
        cnt_fs_reg_reg <= cnt_fs_reg_reg;
end        
        
// ���������־�ź�calc_flag
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        calc_flag   <=  1'b0;
    else if(cnt_gate_fs == (CNT_GATE_MAX - CNT_GATE_LOW / 2'd2 - 2'd2))
        calc_flag   <=  1'b1;
    else if(cnt_gate_fs == (CNT_GATE_MAX - CNT_GATE_LOW / 2'd2 - 2'd1))
        calc_flag   <=  1'b0;
    else
        calc_flag <= calc_flag;
end

// ����ʱ�������Ƿ�Ϊ��
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        fx_flag <= 1'b0;
    else if(clk_fx && gate_fx)
        fx_flag <= 1'b1;
    else 
        fx_flag <= fx_flag;
end

// բ��ʱ�����
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_dely <= 28'b0;
    else if(gate_fx_pose)
        cnt_dely <= 28'b0;
    else if(cnt_dely == CNT_TIME_MAX)
        cnt_dely <= CNT_TIME_MAX;
    else 
        cnt_dely <= cnt_dely +1'b1;
end

// �����ص�����2s����
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        flag_dely <= 1'b0;
    else if(cnt_dely >= CNT_TIME_MAX)               
        flag_dely <= 1'b1;
    else if(cnt_dely < CNT_TIME_MAX)               
        flag_dely <= 1'b0;
    else 
        flag_dely <= flag_dely;
end

// ��ñ����źŵ�Ƶ��ֵ
always@(posedge sys_clk  or negedge sys_rst_n)begin
    if(!sys_rst_n)
        data_fx <= 30'd0;
    else if(!fx_flag)                   //��������
        data_fx <= 30'd0;
    else if(flag_dely)                  //����ʱ�ӱ��ε�
        data_fx <= 30'd0;
    else if(vld_out)
        data_fx <= quotient;
    else
        data_fx <= data_fx;
end

always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        en <= 1'b0;
    else if(cnt_gate_fs == (CNT_GATE_MAX - CNT_GATE_LOW / 2'd2))
        en <= 1'b1;
    else if(vld_out)
        en <= 1'b0;
    else
        en <= en;        
end

always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        dividend <= 57'd0;
        divisor <= 57'd1;
        end
    else if(calc_flag)begin
        dividend <= numer_reg;
        divisor <= cnt_fs_reg_reg;
        end
    else begin
        dividend <= dividend;
        divisor <= divisor;
        end
end


endmodule