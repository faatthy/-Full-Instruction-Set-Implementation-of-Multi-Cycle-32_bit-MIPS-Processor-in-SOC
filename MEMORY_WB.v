module MEMORY_WB (
    //input  config
    input  wire         CLK       ,
    input  wire         RST         ,
    //input control
    input  wire         RegWriteM   ,
	input  wire         mfc0M,
    input  wire   [1:0]      MemtoRegM   ,
    //
    input  wire [31:0]  ALUOutM     ,
    //
    input  wire [4:0]   WriteRegM   ,
    //
	input wire [31:0]   cp0_to_regfileM,
	input wire [31:0] WriteDataM,
	input wire MemWriteM,
    
    //output        
    output  reg         RegWriteW   ,
	output  reg  MemWriteW,
	output  reg         mfc0W,
    //
    output  reg   [1:0]      MemtoRegW   ,
    //
    output  reg [31:0]  ALUOutW     ,
    //
    output  reg [4:0]   WriteRegW   ,
	output reg  [31:0] WriteDataW,
    //
    output reg [31:0] hi_rd_W,
    output reg [31:0] lo_rd_W,
    input [31:0] hi_rd_M,lo_rd_M,
	output reg [31:0] cp0_to_regfileW,

	input data_mem_enable,     
	output reg data_mem_enableW,
	
    input uart_enable,			   
	output reg uart_enableW,
	
	input timer_enable,
	output reg timer_enableW,
	
	input default_slave_enable,
	output reg default_slave_enableW,
	
    input gpio_enable,
	output reg gpio_enableW
		
);

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        RegWriteW  <= 0  ;
        MemtoRegW  <= 0  ;
        ALUOutW    <= 0  ;
        WriteRegW  <= 0  ;
        hi_rd_W<=0;
        lo_rd_W<=0;
		cp0_to_regfileW<=0;
		mfc0W<=0;
		WriteDataW<=0;
		MemWriteW<=1'b0;
		data_mem_enableW<='d0;
		uart_enableW<='d0;
		timer_enableW<='d0;
		default_slave_enableW<='d0;
		gpio_enableW<='d0;
    end
    else begin
        RegWriteW  <= RegWriteM  ;
        MemtoRegW  <= MemtoRegM  ;
        ALUOutW    <= ALUOutM    ;
        WriteRegW  <= WriteRegM  ;
        hi_rd_W<=hi_rd_M;
        lo_rd_W<=lo_rd_M;
		cp0_to_regfileW<=cp0_to_regfileM;
		mfc0W<=mfc0M;
		WriteDataW<=WriteDataM;
		MemWriteW<=MemWriteM;
		data_mem_enableW<=data_mem_enableW;
		uart_enableW<=uart_enable;
		timer_enableW<=timer_enable;
		default_slave_enableW<=default_slave_enable;
		gpio_enableW<=gpio_enable;
    end
end       
endmodule

