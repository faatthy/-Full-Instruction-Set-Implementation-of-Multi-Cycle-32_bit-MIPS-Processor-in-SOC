module CP0 (
    input wire clk,rst,
    input wire [4:0] rd,
    input wire [31:0] write_data,
    input wire cp0_write,
	input wire [1:0] CauseSelect,
    output wire [31:0] read_data
);
    reg [31:0] cp0_registers [0:31];
	integer i;

    // Read data    
    assign read_data = cp0_registers[rd];

    // Write data
    always @(posedge clk or negedge rst) begin
	         if(!rst)
			 begin
			    for(i=0 ; i<32 ; i=i+1)
				begin
					cp0_registers[i]<='d0;
				end
			 end
			 
             else if (cp0_write)  
			 begin 
                case(CauseSelect)			 
				2'b00:   cp0_registers[rd] <= 32'd48;     //arithmatic overflow
				2'b01:   cp0_registers[rd] <= 32'd40;     //undefined instruction
				2'b10:   cp0_registers[rd] <= 32'd36;     //divide by zero
				default: cp0_registers[rd] <= write_data; //normal write operation from the regfile
				endcase
            end
		
    end
endmodule

