module ALU (
    // Inputs
    input  wire signed [31:0] SrcA,       // Source operand A
    input  wire signed [31:0] SrcB,       // Source operand B
    input  wire [4:0] ALUControl,         // Control signal to determine the operation
    input  wire signed [4:0] shamt,       // Shift amount

    // Outputs
    output wire Zero,                     // Zero flag
	output reg  OverFlow,
    output reg signed [31:0] ALUResult    // Result of the ALU operation
);

    reg [31:0] hi, lo;                    // Temporary registers for intermediate results
     
    always @(*) begin
        hi = 0;
        lo = 0;
        ALUResult = 0;
		OverFlow = 0;

        // ALU operations based on ALUControl signal
        case (ALUControl)
            5'b01001: ALUResult = (SrcA <= 0) ? 1 : 0;                       // Set if SrcA <= 0
            5'b01010: ALUResult = (SrcA > 0) ? 1 : 0;                        // Set if SrcA > 0
            5'b01100: ALUResult = ($unsigned(SrcA) < $unsigned(SrcB)) ? 1 : 0; // Unsigned less than comparison
            5'b01101: ALUResult = SrcA ^ SrcB;                               // XOR
            5'b01110: ALUResult = SrcA * SrcB;                               // Multiplication
            5'b00010:                                                        // Signed addition
			begin
				ALUResult = SrcA + SrcB;
				OverFlow = (SrcA[31]==SrcB[31] && SrcA[31]!=ALUResult[31]) ? 1:0;
			end
			
            5'b00011: ALUResult = $unsigned(SrcA) + $unsigned(SrcB);   // Unsigned addition
            5'b00110: 							                              	  // Signed subtraction
			begin
				ALUResult = SrcA - SrcB;
				OverFlow = (SrcA[31]!=SrcB[31] && SrcA[31]!=ALUResult[31]) ? 1:0;
			end
            5'b01111: ALUResult = $unsigned(SrcA) - $unsigned(SrcB);   // Unsigned subtraction
			
            5'b00000: ALUResult = SrcA & SrcB;                               // AND
            5'b01011: ALUResult = SrcA ^ SrcB;                               // XOR (duplicate case)
            5'b00001: ALUResult = SrcA | SrcB;                               // OR
            5'b00100: ALUResult = ~(SrcA | SrcB);                            // NOR
            5'b00111: ALUResult = (SrcA < SrcB) ? 1 : 0;                     // Signed less than comparison
            5'b00101: ALUResult = ($unsigned(SrcA) < $unsigned(SrcB)) ? 1 : 0; // Unsigned less than comparison
            5'b10000: ALUResult = SrcB << $unsigned(shamt);                  // Logical shift left by immediate
            5'b10001: ALUResult = SrcB >> $unsigned(shamt);                  // Logical shift right by immediate
            5'b10010: ALUResult = SrcB >>> $unsigned(shamt);                 // Arithmetic shift right by immediate
            5'b10011: ALUResult = SrcB << SrcA[4:0];                         // Logical shift left by register
            5'b10100: ALUResult = SrcB >> SrcA[4:0];                         // Logical shift right by register
            5'b10101: ALUResult = SrcB >>> SrcA[4:0];                        // Arithmetic shift right by register
            5'b11000: {hi, lo} = $unsigned(SrcA) * $unsigned(SrcB);          // Unsigned multiplication
            5'b11001: {hi, lo} = SrcA * SrcB;                                // Signed multiplication
            5'b11010: begin                                                  // Unsigned division
                lo = $unsigned(SrcA) / $unsigned(SrcB);
                hi = $unsigned(SrcA) % $unsigned(SrcB);
            end
            5'b11011: begin                                                  // Signed division
                lo = SrcA / SrcB;
                hi = SrcA % SrcB;
            end
            5'b11100: ALUResult = hi;                                        // Move from hi
            5'b11101: hi = SrcA;                                             // Move to hi
            5'b11110: ALUResult = lo;                                        // Move from lo
            5'b10110: lo = SrcA;   			// Move to lo
			5'b11111: ALUResult = SrcB ;    //lui
            default: ALUResult = 10;                                         // Default case with dummy value
        endcase
    end

    assign Zero = ~|ALUResult; // Zero flag is set when ALUResult is zero

endmodule



