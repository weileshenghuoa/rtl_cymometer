//****************************************Copyright (c)***********************************//
//??????????????www.yuanzige.com
//????????http://www.openedv.com/forum.php
//????????https://zhengdianyuanzi.tmall.com
//????????????????"???????"???????ZYNQ & FPGA & STM32 & LINUX?????
//??????§µ?????????
//Copyright(C) ??????? 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           clk_div
// Created by:          ???????
// Created date:        2023??2??3??14:17:02
// Version:             V1.0
// Descriptions:        clk_div
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module clk_div(
    input               clk     ,       //50Mhz
    input               rst_n   ,
    input       [15:0]  lcd_id  ,

    output  reg         lcd_pclk        //??????
    );
//reg define
reg     clk_25m     ;
reg     clk_12_5m   ;
reg     div_4_cnt   ;

//*****************************************************
//**                    main code
//*****************************************************

//???2??? ???25MHz??? 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_25m <= 1'b0;
    else 
        clk_25m <= ~clk_25m;
end

//???4??? ???12.5MHz??? 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        div_4_cnt <= 1'b0;
        clk_12_5m <= 1'b0;
    end    
    else begin
        div_4_cnt <= div_4_cnt + 1'b1;
        if(div_4_cnt == 1'b1)
            clk_12_5m <= ~clk_12_5m;
    end        
end

always @(*) begin
    case(lcd_id)
        16'h4342 : lcd_pclk = clk_12_5m;
        16'h7084 : lcd_pclk = clk_25m;       
        16'h7016 : lcd_pclk = clk;
        16'h4384 : lcd_pclk = clk_25m;
        16'h1018 : lcd_pclk = clk;
        default :  lcd_pclk = 1'b0;
    endcase      
end

endmodule
