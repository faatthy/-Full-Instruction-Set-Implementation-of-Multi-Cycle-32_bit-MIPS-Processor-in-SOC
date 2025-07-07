module FETCH_DECODE (
    //input 
    input  wire         CLK       ,
    input  wire         RST       ,
    //input
    input  wire [31:0]  InstrF    ,
    input  wire [31:0]  PCPlus4F  ,
    input  wire         stallD    ,
    input  wire         CLR       ,
    input [5:0] Branch_taken_pred_out,
    //output 
    output reg [31:0]  InstrD   ,
    output reg [31:0]  PCPlus4D  ,
    output reg [5:0] Branch_taken_pred_out_D,
    input [31:0] pred_target,
    output reg[31:0] pred_target_D,
	input  JAL_flagF,
	output reg JAL_flagD
);
           
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        InstrD   <= 0            ;
        PCPlus4D <= 0            ;
        Branch_taken_pred_out_D<=6'b0   ;
	pred_target_D<=32'b0     ;
	JAL_flagD<=0;
    end
    else if (CLR && !stallD)
    begin
        InstrD   <= 0;
        PCPlus4D <= 0;
	Branch_taken_pred_out_D<=6'b0;
	pred_target_D<=32'b0;
	JAL_flagD<=0;
    end
    else if (!stallD) begin
        InstrD   <= InstrF       ;
        PCPlus4D <= PCPlus4F     ;
	Branch_taken_pred_out_D<=Branch_taken_pred_out;
	pred_target_D<=pred_target;
	JAL_flagD<=JAL_flagF;
    end 
         
end   
endmodule



