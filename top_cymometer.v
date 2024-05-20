//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_cymometer
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        top_cymometer
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module top_cymometer#(
    //parameter define
    parameter       DIV_N        = 26'd10_000_000   ,   // ��Ƶϵ��
    parameter       CHAR_POS_X   = 11'd1            ,   // �ַ�������ʼ�������
    parameter       CHAR_POS_Y   = 11'd1            ,   // �ַ�������ʼ��������
    parameter       CHAR_WIDTH   = 11'd88           ,   // �ַ�������
    parameter       CHAR_HEIGHT  = 11'd16           ,   // �ַ�����߶�
    parameter       WHITE        = 24'hFFFFFF       ,   // ����ɫ����ɫ
    parameter       BLACK        = 24'h0            ,   // �ַ���ɫ����ɫ
    parameter       CNT_GATE_MAX = 28'd75_000_000   ,   // ��Ƶ����ʱ��Ϊ1.5s  
    parameter       CNT_GATE_LOW = 28'd12_500_000   ,   // բ��Ϊ�͵�ʱ��0.25s
    parameter       CNT_TIME_MAX = 28'd80_000_000   ,   // ��Ƶ����ʱ��Ϊ1.6s
    parameter       CLK_FS_FREQ  = 28'd100_000_000  ,
    parameter       DATAWIDTH    = 8'd57
)(
    input              sys_clk    ,             // ʱ���ź�
    input              sys_rst_n  ,             // ��λ�ź�
    input              clk_fx     ,             // ����ʱ��

    output             clk_out1   ,             // ���ʱ��5hz
    output             clk_out2   ,             // ���ʱ��133.3333Mhz
	output             lcd_hs     ,             // LCD ��ͬ���ź�
	output             lcd_vs     ,             // LCD ��ͬ���ź�
	output             lcd_de     ,             // LCD ��������ʹ��
	inout      [23:0]  lcd_rgb    ,             // LCD RGB��ɫ����
	output             lcd_bl     ,             // LCD ��������ź�
	output             lcd_clk    ,             // LCD ����ʱ��
    output             lcd_rst
);
//wire define
wire    [29:0]       data_fx;        // �����źŲ���ֵ       
wire                 clk_fs;

wire        en;             

wire [56:0] dividend;       
wire [56:0] divisor;        

wire        ready;          
wire [56:0] quotient;       
wire [56:0] remainder;     
wire        vld_out;        

//*****************************************************
//**                    main code
//*****************************************************

// ������׼ʱ��100M
pll_100m u_pll_100m(
    .clk_out1       (clk_fs     ),      // ��׼ʱ�ӣ�100M
    .clk_out2       (clk_out2  ),       // 50M���ϱ����ź�
    .reset          (~sys_rst_n ),      // ��λ�ź�
    .clk_in1        (sys_clk    )
);

//�����Ⱦ���Ƶ�ʼ�ģ�� 
cymometer#(
    .CNT_GATE_MAX   (CNT_GATE_MAX),      // ��Ƶ����ʱ��Ϊ1.5s  
    .CNT_GATE_LOW   (CNT_GATE_LOW),      // բ��Ϊ�͵�ʱ��0.25s
    .CNT_TIME_MAX   (CNT_TIME_MAX),
    .CLK_FS_FREQ    (CLK_FS_FREQ )
)
u_cymometer(
    .sys_clk        (sys_clk    ),       // ϵͳʱ�ӣ�50M
    .clk_fs         (clk_fs     ),       // ��׼ʱ�ӣ�100M
    .sys_rst_n      (sys_rst_n  ),       // ϵͳ��λ���͵�ƽ��Ч
    .clk_fx         (clk_fx     ),       // ����ʱ���ź�
    .data_fx        (data_fx    ),       // ����ʱ��Ƶ��ֵ
    .dividend       (dividend   ),       
    .divisor        (divisor    ),       
    .en             (en         ),    
    .ready          (ready      ),       
    .quotient       (quotient   ),       
    .remainder      (remainder  ),       
    .vld_out        (vld_out    )        
    
);

//������ģ��
div_fsm
#(
    .DATAWIDTH      (DATAWIDTH  )
)
u_div_fsm(
    .clk            (sys_clk    ),      
    .rst_n          (sys_rst_n  ),      
    .en             (en         ),      

    .dividend       (dividend   ),      
    .divisor        (divisor    ),      

    .ready          (ready      ),      
    .quotient       (quotient   ),      
    .remainder      (remainder  ),      
    .vld_out        (vld_out    )       
);

//��������ʱ��ģ�飬��������ʱ��
clk_test 
#(
    .DIV_N          (DIV_N      )
)
u_clk_test(
    .clk_in         (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    .clk_out        (clk_out1    )
);

//����LCD��ʾģ��
lcd_rgb_char 
#(
    .CHAR_POS_X     (CHAR_POS_X ),
    .CHAR_POS_Y     (CHAR_POS_Y ),
    .CHAR_WIDTH     (CHAR_WIDTH ),
    .CHAR_HEIGHT    (CHAR_HEIGHT),
    .WHITE          (WHITE      ),
    .BLACK          (BLACK      )
)
u_lcd_rgb_char(
    .sys_clk        (sys_clk    ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (data_fx    ),     
    .lcd_hs         (lcd_hs     ),          // LCD ��ͬ���ź�
    .lcd_vs         (lcd_vs     ),          // LCD ��ͬ���ź�
    .lcd_de         (lcd_de     ),          // LCD ��������ʹ��
    .lcd_rgb        (lcd_rgb    ),          // LCD RGB888��ɫ����
    .lcd_bl         (lcd_bl     ),          // LCD ��������ź�
    .lcd_clk        (lcd_clk    ),          // LCD ����ʱ��
    .lcd_rst        (lcd_rst    )
);

endmodule