module Instruction_Memory #(parameter RAM_WIDTH = 32, RAM_ADDR_BITS = 12)(
    // inputs
    input [RAM_ADDR_BITS-1:0] A,
    input [RAM_WIDTH -1:0] DATA_IN,
    input w_enable,CLK,
    // outputs
    output wire [RAM_WIDTH -1:0] RD
);
       (* ram_style="distributed" *)
       reg [RAM_WIDTH-1:0] Mem_Instr [(2**RAM_ADDR_BITS)-1:0];
       always @(posedge CLK)
          if (w_enable)
             Mem_Instr[A] <= DATA_IN;

initial
  begin
    $readmemh("test3.txt",Mem_Instr);
  end       
       assign RD = Mem_Instr[A>>2];
endmodule    

