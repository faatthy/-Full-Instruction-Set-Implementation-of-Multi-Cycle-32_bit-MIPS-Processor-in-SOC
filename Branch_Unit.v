module Branch_Unit (
    input [5:0] OpCode,              // Operation code from the instruction
    input [4:0] rt,                  // Register target from the instruction
    input signed [31:0] RD1, RD2,    // Register data 1 and 2 from the Register File
    output reg [5:0] Branch,         // Branch result for each type
    output reg Branch_flag_BEQ, Branch_flag_BNE, Branch_flag_BLEZ, Branch_flag_BGTZ, Branch_flag_BGEZ, Branch_flag_BLTZ,
    input [5:0] Branch_pred_unit,    // Predicted branch result
    output [5:0] wrong_taken, wrong_not_taken // Wrong prediction signals
);

always @(*) begin     
    // Default branch results
    Branch = 6'b000000;
    Branch_flag_BEQ = 0;
    Branch_flag_BNE = 0;
    Branch_flag_BLEZ = 0;
    Branch_flag_BGTZ = 0;
    Branch_flag_BGEZ = 0;
    Branch_flag_BLTZ = 0;
    
    // Determine branch condition based on OpCode
    case (OpCode)
        6'b000001: begin // BGEZ or BLTZ
            if (rt == 5'b00001) begin // BGEZ
                Branch[0] = (RD1 >= 0);
                Branch_flag_BGEZ = 1;
            end
            else if (rt == 5'b00000) begin // BLTZ
                Branch[1] = (RD1 < 0);
                Branch_flag_BLTZ = 1;
            end
        end
        6'b000100: begin // BEQ
            Branch[2] = (RD1 == RD2);
            Branch_flag_BEQ = 1;
        end
        6'b000101: begin // BNE
            Branch[3] = (RD1 != RD2);
            Branch_flag_BNE = 1;
        end
        6'b000110: begin // BLEZ
            Branch[4] = (RD1 <= 0);
            Branch_flag_BLEZ = 1;
        end
        6'b000111: begin // BGTZ
            Branch[5] = (RD1 > 0);
            Branch_flag_BGTZ = 1;
        end
        default: begin
            Branch = 6'b000000; // No branch
        end
    endcase
end

// Calculate wrong prediction signals for each branch type
assign wrong_taken[0] = (Branch[0] != Branch_pred_unit[0] && Branch_flag_BGEZ && Branch[0] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[0] = (Branch[0] != Branch_pred_unit[0] && Branch_flag_BGEZ && Branch[0] == 1) ? 1'b1 : 1'b0;

assign wrong_taken[1] = (Branch[1] != Branch_pred_unit[1] && Branch_flag_BLTZ && Branch[1] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[1] = (Branch[1] != Branch_pred_unit[1] && Branch_flag_BLTZ && Branch[1] == 1) ? 1'b1 : 1'b0;

assign wrong_taken[2] = (Branch[2] != Branch_pred_unit[2] && Branch_flag_BEQ && Branch[2] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[2] = (Branch[2] != Branch_pred_unit[2] && Branch_flag_BEQ && Branch[2] == 1) ? 1'b1 : 1'b0;

assign wrong_taken[3] = (Branch[3] != Branch_pred_unit[3] && Branch_flag_BNE && Branch[3] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[3] = (Branch[3] != Branch_pred_unit[3] && Branch_flag_BNE && Branch[3] == 1) ? 1'b1 : 1'b0;

assign wrong_taken[4] = (Branch[4] != Branch_pred_unit[4] && Branch_flag_BLEZ && Branch[4] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[4] = (Branch[4] != Branch_pred_unit[4] && Branch_flag_BLEZ && Branch[4] == 1) ? 1'b1 : 1'b0;

assign wrong_taken[5] = (Branch[5] != Branch_pred_unit[5] && Branch_flag_BGTZ && Branch[5] == 0) ? 1'b1 : 1'b0;
assign wrong_not_taken[5] = (Branch[5] != Branch_pred_unit[5] && Branch_flag_BGTZ && Branch[5] == 1) ? 1'b1 : 1'b0;

endmodule


