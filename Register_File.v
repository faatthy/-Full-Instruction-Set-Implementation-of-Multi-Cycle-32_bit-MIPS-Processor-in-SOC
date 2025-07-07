module Register_File  (
    //input
    input wire          CLK      ,
    input wire          RST      ,
    //
	input wire JAL_flagD,
	input [31:0]PCPLUS4D,
    input wire          WE3      ,
    input wire [4:0]    A1       ,
    input wire [4:0]    A2       ,
    input wire [4:0]    A3       ,      
    input wire [31:0]   WD3      ,
    //output    
    output  [31:0]   RD1      ,
    output  [31:0]   RD2      
);
   
reg [31:0]  Mem_Reg  [31:0]      ;
integer i;

assign    RD1 =   Mem_Reg[A1];
assign    RD2 =   Mem_Reg[A2];


always @(negedge CLK or negedge RST) begin
    if (!RST)
	begin
		Mem_Reg[A3] <= 0   ;
		for(i=0 ; i<32 ; i=i+1)
		begin
			Mem_Reg[i]<=32'd0;
		end
	end
	
    else
    begin
        if (WE3)
          Mem_Reg[A3] <= WD3 ;
      
	   Mem_Reg[31] <= (JAL_flagD)?PCPLUS4D:Mem_Reg[31];
	end
end
endmodule


    