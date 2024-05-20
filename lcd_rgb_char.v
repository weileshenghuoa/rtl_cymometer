//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_char
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        lcd_rgb_char
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module  lcd_rgb_char(
    input              sys_clk      ,
    input              sys_rst_n    ,
	input      [29:0]  data         , 

    output             lcd_hs       ,       // LCD ��ͬ���ź�
    output             lcd_vs       ,       // LCD ��ͬ���ź�
    output             lcd_de       ,       // LCD ��������ʹ��
    inout      [23:0]  lcd_rgb      ,       // LCD RGB565��ɫ����
    output             lcd_bl       ,       // LCD ��������ź�
    output             lcd_clk      ,       // LCD ����ʱ��
    output             lcd_rst              // LCD ��λ
);
//parameter define
parameter  CHAR_POS_X  = 11'd1      ;       // �ַ�������ʼ�������
parameter  CHAR_POS_Y  = 11'd1      ;       // �ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd88     ;       // �ַ�������
parameter  CHAR_HEIGHT = 11'd16     ;       // �ַ�����߶�
parameter  WHITE       = 24'hFFFFFF ;       // ����ɫ����ɫ
parameter  BLACK       = 24'h0      ;       // �ַ���ɫ����ɫ

//wire define
wire  [10:0]  pixel_xpos            ;
wire  [10:0]  pixel_ypos            ;
wire  [23:0]  pixel_data            ;
wire  [15:0]  lcd_id                ;
wire  [23:0]  lcd_rgb_o             ;
wire          lcd_pclk              ;
wire  [35:0]  bcd_data;       //9λ

//*****************************************************
//**                    main code
//*****************************************************

//RGB565�������
assign lcd_rgb = lcd_de ? lcd_rgb_o : {24{1'bz}};

//��rgb lcd ID ģ��
rd_id u_rd_id(
    .clk            (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    .lcd_rgb        (lcd_rgb    ), 
    
    .lcd_id         (lcd_id     )
);

//��Ƶģ�飬���ݲ�ͬ��LCD ID�����Ӧ��Ƶ�ʵ�����ʱ��
clk_div  u_clk_div(
    .clk            (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    
    .lcd_id         (lcd_id     ),
    .lcd_pclk       (lcd_pclk   )
);

//������תBCD��
binary2bcd u_binary2bcd(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (data    ),
    
    .bcd_data       (bcd_data)
);

//lcd��ʾģ��
lcd_display 
#(
    .CHAR_POS_X     (CHAR_POS_X  ),
    .CHAR_POS_Y     (CHAR_POS_Y  ),
    .CHAR_WIDTH     (CHAR_WIDTH  ),
    .CHAR_HEIGHT    (CHAR_HEIGHT ),
    .WHITE          (WHITE       ),
    .BLACK          (BLACK       )
)
u_lcd_display(
    .lcd_pclk       (lcd_pclk   ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (bcd_data   ),
    
    .pixel_xpos     (pixel_xpos ),
    .pixel_ypos     (pixel_ypos ),
    .pixel_data     (pixel_data )
);

//lcd����ģ��    
lcd_driver u_lcd_driver(
    .lcd_pclk       (lcd_pclk   ),
    .rst_n          (sys_rst_n  ),
    .lcd_id         (lcd_id     ),
    .pixel_data     (pixel_data ),

    .pixel_xpos     (pixel_xpos ),
    .pixel_ypos     (pixel_ypos ),
    .lcd_de         (lcd_de     ),
    .lcd_hs         (lcd_hs     ),
    .lcd_vs         (lcd_vs     ),
    .lcd_bl         (lcd_bl     ),
    .lcd_clk        (lcd_clk    ),
    .lcd_rst        (lcd_rst    ),
    .lcd_rgb        (lcd_rgb_o  )
);

endmodule