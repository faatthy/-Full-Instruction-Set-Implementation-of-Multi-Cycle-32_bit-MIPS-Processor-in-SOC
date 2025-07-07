
module DECODE_EXCUTE (
    //input  config
    input  wire         CLK       ,
    input  wire         RST       ,
    input  wire         CLR       ,
    //input control
    input  wire         RegWriteD   ,
    input  wire  [1:0]  MemtoRegD   ,
    input  wire         MemWriteD   , 
    input  wire  [4:0]  ALUControlD ,
    input  wire         ALUSrcD     ,
    input  wire   [1:0]      RegDstD     ,
    //input Register File
    input  wire  [31:0] RD1D        ,
    input  wire  [31:0] RD2D        ,
    //
    input  wire  [4:0]  RsD         ,     
    input  wire  [4:0]  RtD         ,
    input  wire  [4:0]  RdD         , 
    //
    input  wire  [31:0] SignImmD    ,
    input  wire  [31:0] PCPlus4D    ,
    // 
    input  wire  [4:0]   shamtD      ,
    input wire JAL_flagD,
    output reg JAL_flagE,
    //output
    output reg         RegWriteE   ,
    output reg  [1:0]  MemtoRegE   ,
    output reg         MemWriteE   ,
    output reg  [4:0]  ALUControlE ,
    output reg         ALUSrcE     ,
    output reg  [1:0]       RegDstE     ,
    //input Register File
    output reg  [31:0] RD1E        ,
    output reg  [31:0] RD2E        ,
    //
    output reg  [4:0]  RsE         ,
    output reg  [4:0]  RtE         ,
    output reg  [4:0]  RdE         , 
    //
    output reg  [31:0] SignImmE    ,
    output reg  [31:0] PCPlus4E    ,
    //
    output reg  [4:0]  shamtE      ,
    //
    input [2:0] load_choice_D,
    output reg [2:0] load_choice_E ,
    
    input [2:0] sw_choice_D,
    output reg [2:0] sw_choice_E,
    
    output reg  [4:0]  HI_TO_REG_E         ,
    input  [4:0]  HI_TO_REG_D     ,
    input SIGNED_D,START_D,
    output reg SIGNED_E,START_E ,
    input hi_lo_reg_control_D,hi_lo_en_D,
    output reg  hi_lo_reg_control_E,hi_lo_en_E,
    
    input DIV_START_D,
    output reg  DIV_START_E,
	
    output reg mfc0_E,
	input  mfc0_D,
	
	output reg [31:0] cp0_to_regfile_E,
	input 	[31:0] cp0_to_regfile_D
 );
 always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        RegWriteE  <= 0  ;
        MemtoRegE  <= 0  ;
        MemWriteE  <= 0  ;
        ALUControlE<= 0  ;
        ALUSrcE    <= 0  ;
        RegDstE    <= 0  ;
        //
        RD1E       <= 0  ;
        RD2E       <= 0  ;
        //
        RtE        <= 0  ;
        RdE        <= 0  ;
        RsE        <= 0  ;
        //
        SignImmE   <= 0  ;
        PCPlus4E   <= 0  ;
        load_choice_E<=0;
        sw_choice_E<=0;
        shamtE<=0;
        HI_TO_REG_E<=0;
        SIGNED_E<=0;
        START_E<=0;
        hi_lo_reg_control_E<=0;
        hi_lo_en_E<=0;
        DIV_START_E<=0;
		mfc0_E<=0;
		cp0_to_regfile_E<=0;
		JAL_flagE<=0;
    end
    else if (CLR)
    begin
            RegWriteE  <= 0  ;
            MemtoRegE  <= 0  ;
            MemWriteE  <= 0  ;
            ALUControlE<= 0  ;
            ALUSrcE    <= 0  ;
            RegDstE    <= 0  ;
            //
            RD1E       <= 0  ;
            RD2E       <= 0  ;
            //
            RtE        <= 0  ;
            RdE        <= 0  ;
            RsE        <= 0  ;
            //
            SignImmE   <= 0  ;
            PCPlus4E   <= 0  ;
            load_choice_E<=0;
            sw_choice_E<=0;
            shamtE<=0;
            HI_TO_REG_E<=0;
            SIGNED_E<=0;
            START_E<=0;
            hi_lo_reg_control_E<=0;
            hi_lo_en_E<=0;
            DIV_START_E<=0;
            mfc0_E<=0;
            cp0_to_regfile_E<=0;
            JAL_flagE<=0;
    end
    else begin
        RegWriteE  <= RegWriteD     ;
        MemtoRegE  <= MemtoRegD     ;
        MemWriteE  <= MemWriteD     ;
        ALUControlE<= ALUControlD   ;
        ALUSrcE    <= ALUSrcD       ;
        RegDstE    <= RegDstD       ;
        //
        RD1E       <= RD1D          ;
        RD2E       <= RD2D          ;
        //
        RtE        <= RtD           ;
        RdE        <= RdD           ;
        RsE        <= RsD           ;
        //
        JAL_flagE<=JAL_flagD;
        SignImmE   <= SignImmD      ;
        PCPlus4E   <= PCPlus4D      ;
        load_choice_E <= load_choice_D; 
        sw_choice_E<=sw_choice_D;
        shamtE<=shamtD;
        HI_TO_REG_E<=HI_TO_REG_D;
        SIGNED_E<=SIGNED_D;
        START_E<=START_D;
        hi_lo_reg_control_E<=hi_lo_reg_control_D;
        hi_lo_en_E<=hi_lo_en_D;
        DIV_START_E<=DIV_START_D;
		mfc0_E        <=mfc0_D;
		cp0_to_regfile_E<=cp0_to_regfile_D;
    end
 end  
endmodule

