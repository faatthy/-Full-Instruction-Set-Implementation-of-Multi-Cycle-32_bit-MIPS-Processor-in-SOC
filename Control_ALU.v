module Control_ALU (
    input  wire [5:0] Funct,
    input  wire [5:0] opcode,
	input  wire       divide_zero,
	input  wire       overflow,
	   
	//output        
    output reg  [1:0]   MemtoReg,
    output reg          MemWrite,
    output reg  [4:0]   ALUControl,
    output reg          ALUSrc,
    output reg  [1:0]   RegDst,
    output reg          RegWrite,
    output reg   [1:0]  Jump,
    output reg          sign_flag,
    output reg  [2:0]   load_choice,
    output reg  [2:0]   sw_choice,  
    output reg          lui_flag,
    output reg 			SIGNED,START,
    output reg 			hi_lo_reg_control,hi_lo_write_en,
    output reg 			DIV_START,
	output reg 			JR_flag,
	output reg          cp0_write,
	output reg          mfc0,       //for writing to the reg file fron CP0
	output reg  [1:0]   CauseSelect,
	output reg          exception
	);

always @(*) begin
    // Default values
    MemtoReg       = 0;
    MemWrite       = 0;
    ALUControl     = 5'b00010;
    ALUSrc         = 0;
    RegDst         = 0;
    RegWrite       = 0;
    Jump           = 0;    
    sign_flag      = 1'b1;
    load_choice    = 3'b000;
    sw_choice      = 3'b000;
    lui_flag       = 0;
    JR_flag=0;
    START=0;
    SIGNED=0;
    hi_lo_reg_control=0;
    hi_lo_write_en=0;
    DIV_START=0;
	cp0_write       = 0;
	CauseSelect    = 2'b00;
	exception      =0;	
	mfc0           =0;
	if(overflow)
	begin 
        cp0_write      = 1;
	    CauseSelect    = 2'b00;
        exception      = 1;		
	end
	
	else if(divide_zero)
	begin 
        cp0_write      = 1;
	    CauseSelect    = 2'b10;
        exception      = 1;		
	end
	
	else
	begin
		
		case (opcode)
			6'b000000 : begin // R-type
				RegWrite = 1;
				RegDst = 1;
				START=0;
				SIGNED=0;
				hi_lo_reg_control=0;
				hi_lo_write_en=0;
				case (Funct)
					6'b100000: ALUControl = 5'b00010;  // add
					6'b100001: begin
					ALUControl = 5'b00011;  // add unsigned
					end
					6'b100010: ALUControl = 5'b00110;  // subtract
					6'b100011: begin
					ALUControl = 5'b01111;  // subtract unsigned
					end
					6'b100100: ALUControl = 5'b00000;  // and
					6'b100101: ALUControl = 5'b00001;  // or
					6'b100110: ALUControl = 5'b01011;  // xor
					6'b100111: ALUControl = 5'b00100;  // nor
					6'b101010: ALUControl = 5'b00111;  // set less than
					6'b101011: begin ALUControl = 5'b00101;  // set less than unsigned
					end
					6'b000000: ALUControl = 5'b10000;  // shift left logical
					6'b000010: ALUControl = 5'b10001;  // shift right logical
					6'b000011: ALUControl = 5'b10010;  // shift right arithmetic
					6'b000100: ALUControl = 5'b10011;  // shift left logical variable
					6'b000110: ALUControl = 5'b10100;  // shift right logical variable
					6'b000111: ALUControl = 5'b10101;  // shift right arithmetic variable
					6'b001000: begin 				   // Jr
							RegWrite = 0;
							Jump = 2;
							JR_flag=1;
					end
					
					6'b001001: begin 				   // Jalr
							RegWrite = 0;
							Jump = 2;
							JR_flag=1;
					end
					
					6'b011001: begin
						  ALUControl = 5'b00010;       // multiply unsigned
						  START=1;
						  SIGNED=0;
						  RegWrite = 0;
						  RegDst = 0;
					end       
					6'b011000: begin
						  ALUControl = 5'b00010;       // multiply signed
						  START=1;
						  SIGNED=1;
						  RegWrite = 0;
						  RegDst = 0;
					end
					6'b011010:  begin
						  ALUControl = 5'b00010;       // divide signed
						  DIV_START=1;
						  SIGNED=1;
						  RegWrite = 0;
						  RegDst = 0;
					end
					6'b011011: begin
						  ALUControl = 5'b00010;       // divide Unsigned
						  DIV_START=1;
						  SIGNED=0;
						  RegWrite = 0;
						  RegDst = 0;
					end         
					
					6'b010000: begin //mfhi
						  ALUControl = 5'b00010;
						  MemtoReg = 2'b10;
						  RegDst=2'b10;
					end
					6'b010010: begin //mflo
						  ALUControl = 5'b00010;
						  MemtoReg = 2'b11;
						  RegDst=2'b10;
					end
					6'b010001: begin                  // move to hi
							  ALUControl = 5'b00010;
							  hi_lo_reg_control=1;
							  hi_lo_write_en=1;
							  RegWrite = 0;
							  RegDst = 0;
					end
					6'b010011: begin                  // move to hi
							  ALUControl = 5'b00010;
							  hi_lo_reg_control=0;
							  hi_lo_write_en=1;
							  RegWrite = 0;
							  RegDst = 0;
					end 
					default:   ALUControl = 5'b00010;  // default add
				endcase
			end
			6'b000100 : begin // beq
			   
				ALUControl = 5'b00110; // subtract
			end
			6'b001000 : begin // addi
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00010; // add
			end
			6'b000010 : begin // j
				Jump = 1;
			end
			6'b000001 : begin // bltz/bgez
				
				ALUControl = 5'b00111; // set less than
			end
			6'b000011 : begin // jal
				Jump = 1;
			end
			6'b000101 : begin // bne
				
				ALUControl = 5'b00110; // subtract
			end
			6'b000110 : begin // blez
				
				ALUControl = 5'b01001; // less than or equal to zero
			end
			6'b000111 : begin // bgtz
				
				ALUControl = 5'b01010; // greater than zero
			end
			6'b001001 : begin // addiu
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00011; // add unsigned
			end
			6'b001010 : begin // slti
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00111; // set less than
			end
			6'b001011 : begin // sltiu
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00101; // set less than unsigned
			end
			6'b001100 : begin // andi
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00000; // and
				sign_flag      = 0;
			end
			6'b001101 : begin // ori
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b00001; // or
				sign_flag      = 0;
			end
			6'b001110 : begin // xori
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b01011; // xor
				sign_flag      = 0;
			end
			6'b001111 : begin // lui
				ALUSrc = 1;
				RegWrite = 1;
				ALUControl = 5'b11111; // lui
				lui_flag = 1;
			end
			
			6'b010000:begin //mfco / mtc0
			
				if(Funct == 6'd0) //mfc0
				begin
				    mfc0=1;
					RegWrite = 1;
					RegDst = 0;  //destination register is in Rt field
				end
				
				else   //mtc0
				begin
					cp0_write = 1;
				end
			end
			
			6'b011100 : begin // multiply
				RegWrite = 1;
				RegDst = 1;
				ALUControl = 5'b01110; // multiply (32-bit result)
			end
			6'b100000 : begin // lb
				ALUSrc = 1;
				RegWrite = 1;
				MemtoReg = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				load_choice = 3'b001;
			end
			6'b100001 : begin // lh
				ALUSrc = 1;
				RegWrite = 1;
				MemtoReg = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				load_choice = 3'b011;
			end
			6'b100011 : begin // lw
				ALUSrc = 1;
				RegWrite = 1;
				MemtoReg = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				load_choice = 3'b111;
			end
			6'b100100 : begin // lbu
				ALUSrc = 1;
				RegWrite = 1;
				MemtoReg = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				load_choice = 3'b010;
				sign_flag      = 0;
			end
			6'b100101 : begin // lhu
				ALUSrc = 1;
				RegWrite = 1;
				MemtoReg = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				load_choice = 3'b100;
				sign_flag      = 0;
			end
			6'b101000 : begin // sb
				ALUSrc = 1;
				MemWrite = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				sw_choice = 3'b001;
			end
			6'b101001 : begin // sh
				ALUSrc = 1;
				MemWrite = 1;
				ALUControl = 5'b0010; // add (for address calculation)
				sw_choice = 3'b010;
			end
			6'b101011 : begin // sw
				ALUSrc = 1;
				MemWrite = 1;
				ALUControl = 5'b00010; // add (for address calculation)
				sw_choice = 3'b011;
			end
			default: begin
				cp0_write      = 1;   //for writing into Cause register
				CauseSelect    = 2'b01; //undefined instruction exception
				exception      = 1;
			end
		endcase
	end
end

endmodule




