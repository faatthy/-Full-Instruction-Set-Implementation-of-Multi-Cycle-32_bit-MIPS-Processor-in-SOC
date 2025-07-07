module Branch_Prediction (
    input [31:0] instruction_Branch,  
    input clk,
    input rst,
    input [5:0] Branch_taken,         // Indicates if each branch type was taken
    output reg [31:0] pred_target,
    input [31:0] PCPlus4F,
    input [3:0] PC,
    input Branch_flag_BEQ, Branch_flag_BNE, Branch_flag_BLEZ, Branch_flag_BGTZ, Branch_flag_BGEZ, Branch_flag_BLTZ,
    output reg [5:0] Branch_taken_pred_out ,// Output: indicates which branch prediction was made
	output Branch_taken_pred,
	output wire   [31:0]jump_target,
	output reg jump_flag,JAL_flag
);
    wire [31:0] SIGNIMMD;    
    reg [1:0] pred_table [5:0]; // Prediction table for each branch type
     
    // Sign extend the immediate field
    assign SIGNIMMD = {{16{instruction_Branch[15]}}, instruction_Branch[15:0]};
    // Initialize the prediction table on reset
   /* always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pred_table[0] <= 2'b00; // BGEZ
            pred_table[1] <= 2'b00; // BLTZ
            pred_table[2] <= 2'b00; // BEQ
            pred_table[3] <= 2'b00; // BNE
            pred_table[4] <= 2'b00; // BLEZ
            pred_table[5] <= 2'b00; // BGTZ
        end
    end
*/
    always @(*) begin
        // Default prediction values
        Branch_taken_pred_out = 6'b000000;
        pred_target = 32'b0;
		jump_flag=0;
		JAL_flag=0;
        // Determine branch prediction based on instruction opcode
        case (instruction_Branch[31:26])
            6'b000001: begin // BGEZ or BLTZ
                case (instruction_Branch[20:16])
                    5'b00001: Branch_taken_pred_out = (pred_table[0] == 2'b10 || pred_table[0] == 2'b11) ? 6'b000001 : 6'b000000; // BGEZ
                    5'b00000: Branch_taken_pred_out = (pred_table[1] == 2'b10 || pred_table[1] == 2'b11) ? 6'b000010 : 6'b000000; // BLTZ
                    default: Branch_taken_pred_out = 6'b000000;
                endcase
            end   
            6'b000100: Branch_taken_pred_out = (pred_table[2] == 2'b10 || pred_table[2] == 2'b11) ? 6'b000100 : 6'b000000; // BEQ
            6'b000101: Branch_taken_pred_out = (pred_table[3] == 2'b10 || pred_table[3] == 2'b11) ? 6'b001000 : 6'b000000; // BNE
            6'b000110: Branch_taken_pred_out = (pred_table[4] == 2'b10 || pred_table[4] == 2'b11) ? 6'b010000 : 6'b000000; // BLEZ
            6'b000111: Branch_taken_pred_out = (pred_table[5] == 2'b10 || pred_table[5] == 2'b11) ? 6'b100000 : 6'b000000; // BGTZ
            6'b000010: begin
						Branch_taken_pred_out=0;
						jump_flag=1;
						end
			6'b000011: begin
						Branch_taken_pred_out=0;
						jump_flag=1;
						JAL_flag=1;
						end
			6'b000000:begin
			     if(instruction_Branch[5:0]==6'b001001)
			       begin
			         JAL_flag=1;
			       end
			     else
			        JAL_flag=0;
			  end
			default: Branch_taken_pred_out = 6'b000000;
        endcase

        // Calculate the predicted target address if branch is predicted to be taken
            pred_target = PCPlus4F + (SIGNIMMD << 2);
      
    end
	
    // Update the prediction table based on the actual branch outcome
   // Update the prediction table based on the actual branch outcome
always @(posedge clk , negedge rst) begin
    if (!rst) begin
        pred_table[0] <= 2'b11; // BGEZ
        pred_table[1] <= 2'b11; // BLTZ
        pred_table[2] <= 2'b00; // BEQ
        pred_table[3] <= 2'b11; // BNE
        pred_table[4] <= 2'b11; // BLEZ
        pred_table[5] <= 2'b11; // BGTZ
    end else begin
        // Update prediction based on branch flags
        if (Branch_flag_BGEZ) begin
            if (Branch_taken[0]) begin
                if (pred_table[0] != 2'b11) pred_table[0] <= pred_table[0] + 2'b01;
            end else begin
                if (pred_table[0] != 2'b00) pred_table[0] <= pred_table[0] - 2'b01;
            end
        end
        else if (Branch_flag_BLTZ) begin
            if (Branch_taken[1]) begin
                if (pred_table[1] != 2'b11) pred_table[1] <= pred_table[1] + 2'b01;
            end else begin
                if (pred_table[1] != 2'b00) pred_table[1] <= pred_table[1] - 2'b01;
            end
        end
        else if (Branch_flag_BEQ) begin
            if (Branch_taken[2]) begin
                if (pred_table[2] != 2'b11) pred_table[2] <= pred_table[2] + 2'b01;
            end else begin
                if (pred_table[2] != 2'b00) pred_table[2] <= pred_table[2] - 2'b01;
            end
        end
        else if (Branch_flag_BNE) begin
            if (Branch_taken[3]) begin
                if (pred_table[3] != 2'b11) pred_table[3] <= pred_table[3] + 2'b01;
            end else begin
                if (pred_table[3] != 2'b00) pred_table[3] <= pred_table[3] - 2'b01;
            end
        end
        else if (Branch_flag_BLEZ) begin
            if (Branch_taken[4]) begin
                if (pred_table[4] != 2'b11) pred_table[4] <= pred_table[4] + 2'b01;
            end else begin
                if (pred_table[4] != 2'b00) pred_table[4] <= pred_table[4] - 2'b01;
            end
        end
        else if (Branch_flag_BGTZ) begin
            if (Branch_taken[5]) begin
                if (pred_table[5] != 2'b11) pred_table[5] <= pred_table[5] + 2'b01;
            end else begin
                if (pred_table[5] != 2'b00) pred_table[5] <= pred_table[5] - 2'b01;
            end
        end
    end
end


assign Branch_taken_pred = (Branch_taken_pred_out != 6'b0) ? 1'b1 : 1'b0;
assign jump_target={PC,instruction_Branch[25:0]<<2};
endmodule