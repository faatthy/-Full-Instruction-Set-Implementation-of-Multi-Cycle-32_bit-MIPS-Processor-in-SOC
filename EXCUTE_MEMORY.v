module EXCUTE_MEMORY (
    //input  config
    input  wire         CLK       ,
    input  wire         RST       ,
    //input control
    input  wire         RegWriteE   ,
    input  wire   [1:0]      MemtoRegE   ,
    input  wire         MemWriteE   ,
	input  wire         mfc0E,
    // ALU signal
    input  wire         ZeroE       ,
    input  wire  [31:0] ALUOutE     ,
    //
    input  wire  [31:0] WriteDataE  ,
    //     
    input  wire  [4:0]  WriteRegE   ,
    input  wire  [31:0] PCBranchE   ,
	input wire [31:0] cp0_to_regfileE,
  input wire JAL_flagE,
  output reg JAL_flagM,
    //output  
    output  reg         RegWriteM   ,
    output  reg   [1:0]      MemtoRegM   ,
    output  reg         MemWriteM   ,
	output  reg         mfc0M,
    // ALU signal
    output  reg         ZeroM       ,
    output  reg  [31:0] ALUOutM     ,
    //
    output  reg  [31:0] WriteDataM  ,
    //
    output  reg  [4:0]  WriteRegM   ,
    output  reg  [31:0] PCBranchM   ,

    input [2:0] load_choice_E,
    output reg [2:0] load_choice_M,
    input [2:0] sw_choice_E,
    output reg [2:0] sw_choice_M,
    input [63:0] product_E,
    input mult_ready_E,hi_lo_reg_control_E,hi_lo_en_E,
    output reg [63:0] product_M,
    output reg mult_ready_M,hi_lo_reg_control_M,hi_lo_en_M,
    output reg [31:0] RD1_M,
    input [31:0] RD1_E,
    input div_ready_E,
    input [63:0] REMAINDER_E,
    input [31:0] QUOTIENT_E,
    output reg [31:0] QUOTIENT_M,
    output reg div_ready_M,
    output reg [63:0] REMAINDER_M,
	output reg [31:0] cp0_to_regfileM
);

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        RegWriteM  <= 0  ;
        MemtoRegM  <= 0  ;
        MemWriteM  <= 0  ;
        //
        ZeroM      <= 0  ;
        ALUOutM    <= 0  ;
        //
        JAL_flagM <=0;
        WriteDataM <= 0  ;
        WriteRegM  <= 0  ;
        PCBranchM  <= 0  ;
        load_choice_M<=0;
        sw_choice_M<=0;
        mult_ready_M<=0;
        product_M<=0;
        RD1_M<=0;
        hi_lo_reg_control_M<=0;
        hi_lo_en_M<=0;
        REMAINDER_M<=0;
        QUOTIENT_M<=0;
        div_ready_M<=0;
		cp0_to_regfileM<=0;
		mfc0M<=0;
    end
    else begin 
        RegWriteM  <= RegWriteE  ;
        MemtoRegM  <= MemtoRegE  ;
        MemWriteM  <= MemWriteE  ;
        //
        ZeroM      <= ZeroE      ;
        ALUOutM    <= ALUOutE    ;
        //
        JAL_flagM <=JAL_flagE;
        WriteDataM <= WriteDataE ;
        WriteRegM  <= WriteRegE  ;
        PCBranchM  <= PCBranchE  ;
        load_choice_M<=load_choice_E;
        sw_choice_M<=sw_choice_E;
        mult_ready_M<=mult_ready_E;
        product_M<=product_E;
        RD1_M<=RD1_E;
        hi_lo_reg_control_M<=hi_lo_reg_control_E;
        hi_lo_en_M<=hi_lo_en_E;
        REMAINDER_M<=REMAINDER_E;
        QUOTIENT_M<=QUOTIENT_E;
        div_ready_M<=div_ready_E;
		cp0_to_regfileM<=cp0_to_regfileE;
		mfc0M<=mfc0E;
    end
end
endmodule

