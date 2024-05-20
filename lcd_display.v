//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_display
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        lcd_display
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module lcd_display(
    input             lcd_pclk  ,               //lcd����ʱ��
    input             sys_rst_n ,               //��λ�ź�
	input      [35:0] data      ,
    input      [10:0] pixel_xpos,               //���ص������
    input      [10:0] pixel_ypos,               //���ص�������

    output reg [23:0] pixel_data                //���ص�����
);
//parameter define
parameter  CHAR_POS_X  = 11'd1      ;           //�ַ�������ʼ�������
parameter  CHAR_POS_Y  = 11'd1      ;           //�ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd88     ;           //�ַ�������
parameter  CHAR_HEIGHT = 11'd16    ;           //�ַ�����߶�
parameter  WHITE       = 24'hFFFFFF ;     		//����ɫ����ɫ
parameter  BLACK       = 24'h0      ;     	    //�ַ���ɫ����ɫ 

//reg define
reg     [127:0] char        [11:0]  ;           //�ַ�����
//wire define
wire [3:0]      data0    ;            // ��λ��
wire [3:0]      data1    ;            // ʮλ��
wire [3:0]      data2    ;            // ��λ��
wire [3:0]      data3    ;            // ǧλ��
wire [3:0]      data4    ;            // ��λ��
wire [3:0]      data5    ;            // ʮ��λ��
wire [3:0]      data6    ;            // ����λ��
wire [3:0]      data7    ;            // ǧ��λ��
wire [3:0]      data8    ;            // ��λ��
//*****************************************************
//**                    main code
//*****************************************************
assign  data8 = data[35:32];    // ��λ��
assign  data7 = data[31:28];    // ǧ��λ��
assign  data6 = data[27:24];    // ����λ��
assign  data5 = data[23:20];    // ʮ��λ��
assign  data4 = data[19:16];    // ��λ��
assign  data3 = data[15:12];    // ǧλ��
assign  data2 = data[11:8];     // ��λ��
assign  data1 = data[7:4];      // ʮλ��
assign  data0 = data[3:0];      // ��λ��

//���ַ����鸳ֵ�����ڴ洢��ģ����
always @(posedge lcd_pclk) begin
    char[0 ]  <= 128'h00000018244242424242424224180000 ; // "0"
    char[1 ]  <= 128'h000000107010101010101010107C0000 ; // "1"
    char[2 ]  <= 128'h0000003C4242420404081020427E0000 ; // "2"
    char[3 ]  <= 128'h0000003C424204180402024244380000 ; // "3"
    char[4 ]  <= 128'h000000040C14242444447E04041E0000 ; // "4"
    char[5 ]  <= 128'h0000007E404040586402024244380000 ; // "5"
    char[6 ]  <= 128'h0000001C244040586442424224180000 ; // "6"
    char[7 ]  <= 128'h0000007E444408081010101010100000 ; // "7"
    char[8 ]  <= 128'h0000003C4242422418244242423C0000 ; // "8"
    char[9 ]  <= 128'h0000001824424242261A020224380000 ; // "9"
    char[10]  <= 128'h000000E7424242427E42424242E70000 ; // "H"
    char[11]  <= 128'h000000000000007E44081010227E0000 ; // "z"
end 

//����ͬ������ֵ��ͬ����������
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd11 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data8][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data7][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data6][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data3][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end        
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) -11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end 
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[11][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end	
	else begin
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
end

endmodule 