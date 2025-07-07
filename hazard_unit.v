
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2024 01:36:41 PM
// Design Name: 
// Module Name: hazard_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      
//////////////////////////////////////////////////////////////////////////////////


module hazard_unit
    (
        input  wire RegWriteM, RegWriteW, RegWriteE, 
		input  wire [5:0] BranchD,
		input wire START_E,RST,div_start,
        input  wire [4:0] RsE, RtE, RsD, RtD, WriteRegM, WriteRegW, WriteRegE,
        input wire  MemtoRegE,MemtoRegM,
        input wire [5:0] wrong_taken, wrong_not_taken,
        output reg  [1:0] ForwardAE, ForwardBE,
        output wire ForwardAD, ForwardBD,
        output wire FlushE, StallD, StallF,
	input wire busy_M,div_busy,
	input wire JR_flag
    );

wire lwstall;
wire branchstall;
wire branch_wrong_taken, branch_wrong_not_taken ;
reg MUL_STALL;
always@(*)
  begin
    if(!RST)
      MUL_STALL=0;
    else if(START_E|div_start|busy_M|div_busy)
      MUL_STALL=1;
    else
      MUL_STALL=0;
  end

always @(*) 
begin
    if ((RsE != 5'b0) && (RsE == WriteRegM) && RegWriteM) 
    begin
        ForwardAE = 2'b10;
    end
    else if ((RsE != 5'b0) && (RsE == WriteRegW) && RegWriteW)
    begin 
        ForwardAE = 2'b01;
    end
    else
    begin 
        ForwardAE = 2'b00;
    end
end

always @(*) 
begin
    if ((RtE != 5'b0) && (RtE == WriteRegM) && RegWriteM) 
    begin
        ForwardBE = 2'b10;
    end
    else if ((RtE != 5'b0) && (RtE == WriteRegW) && RegWriteW) 
    begin
        ForwardBE = 2'b01;
    end
    else 
    begin
        ForwardBE = 2'b00;
    end
end

assign lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;


assign branchstall = ( (BranchD!=6'd0) && RegWriteE && ((WriteRegE == RsD) || (WriteRegE == RtD))) || ((BranchD!=6'd0) && MemtoRegM && ((WriteRegM == RsD) || (WriteRegM == RtD)));


assign branch_wrong_taken = wrong_taken[0] || wrong_taken[1] || wrong_taken[2] || wrong_taken[3] || wrong_taken[4] || wrong_taken[5] ;


assign branch_wrong_not_taken = wrong_not_taken[0] || wrong_not_taken[1] || wrong_not_taken[2] || wrong_not_taken[3] || wrong_not_taken[4] || wrong_not_taken[5] ;

assign ForwardAD = (RsD != 5'b0) && (RsD == WriteRegM) && RegWriteM;
assign ForwardBD = (RtD != 5'b0) && (RtD == WriteRegM) && RegWriteM;
assign JRstall = (WriteRegE == RsD)&&JR_flag;////////////////////////////////////////////////////
assign StallF = lwstall || branchstall || MUL_STALL||JRstall;
assign StallD = lwstall || branchstall || MUL_STALL||JRstall;
assign FlushE = lwstall || branchstall || branch_wrong_taken || branch_wrong_not_taken || MUL_STALL;
endmodule
