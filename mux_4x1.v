
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2024 11:20:11 PM
// Design Name: 
// Module Name: mux_4x1
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


module mux_4x1(
    input wire [31:0] RD, result, ALUOutM,
    input wire [1:0] selector,
    output reg [31:0] Src
    );
    
    always @(*) 
    begin
        case(selector)
            2'b00 : Src =  RD;
            2'b01 : Src =  result;
            2'b10 : Src =  ALUOutM;
            default : Src = 32'hFFFFFFFF;
        endcase    
    end
    
endmodule
