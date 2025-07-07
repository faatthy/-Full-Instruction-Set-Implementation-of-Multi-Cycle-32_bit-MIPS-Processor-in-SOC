module Sign_Extend (
    //input 
    input wire  [15:0] IN_SE  ,
    input wire         sign_flag,
    input wire lui_flag,
    //output
    output reg  [31:0] SignImm 
);
always @(*) begin
    if(lui_flag)
         SignImm = {IN_SE,16'b0};
    else if (sign_flag) 
        SignImm = {{16{IN_SE[15]}},IN_SE} ;
    else
        SignImm = {16'b0,IN_SE} ;
end    
endmodule
     

   