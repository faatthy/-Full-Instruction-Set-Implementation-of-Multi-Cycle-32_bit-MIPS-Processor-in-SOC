module hi_lo_reg ( input  hi_lo_reg_control,
                   input CLK,RST,hi_lo_en,mult_ready,div_ready,
                   input [63:0] product,remainder,
                   input [31:0] hi_lo_wd,quotient,
                   output [31:0] hi_rd,lo_rd
                   );
reg [31:0] hi_lo_mem [0:1];
integer i;
always@(posedge CLK, negedge RST)
  begin
    if(!RST)
      begin
        for(i=0;i<2;i=i+1)
          begin
            hi_lo_mem[i]<=0;
          end
      end    
    else if(mult_ready)
      begin
        {hi_lo_mem[0],hi_lo_mem[1]}<=product;
      end
    else if(div_ready)
      begin
        hi_lo_mem[0]<=remainder[31:0];
        hi_lo_mem[1]<=quotient;
      end  
    else if(hi_lo_en)
      if(hi_lo_reg_control)
          begin
            hi_lo_mem[0]<=hi_lo_wd[31:0];
          end
      else
          begin
            hi_lo_mem[1]<=hi_lo_wd[31:0];
          end 
  end
assign hi_rd=hi_lo_mem[0];
assign lo_rd=hi_lo_mem[1];
endmodule

