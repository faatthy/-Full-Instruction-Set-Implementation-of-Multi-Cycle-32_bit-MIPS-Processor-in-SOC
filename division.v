module divide (
    input CLK, DIV_START,RST,
    input signed [31:0] DIVIDEND, DIVISOR,
    input SIGNED,
    output signed [63:0] REMAINDER,
    output signed [31:0] QUOTIENT,
    output ready,
	output divide_zero,
	output reg div_busy
);     
    reg enable;
    reg signed [63:0] DIVISOR_reg;
    wire write;
    wire signed [63:0] alu_res;
    reg [5:0] count;
    wire signed [31:0] abs_dividend;
    wire signed [31:0] abs_divisor;
    wire dividend_sign;
    wire divisor_sign;
    reg dividend_sign_reg,divisor_sign_reg;
    reg sign_en;
    reg signed [31:0] quotient_temp;
    reg signed [63:0] REMAINDER_temp;
	  
    always @(posedge CLK) begin
             if (DIV_START) begin
            // Determine the sign of the inputs
            
            if(SIGNED)
              begin
                dividend_sign_reg<=DIVIDEND[31];
                divisor_sign_reg<=DIVISOR[31];
                sign_en<=1;
                DIVISOR_reg <= {abs_divisor, 32'b0};
                // Initialize the divisor register
              end
            else
              begin
                dividend_sign_reg<=0;
                divisor_sign_reg<=0;
                sign_en<=0;
                DIVISOR_reg <= {abs_divisor, 32'b0};
              end
        end else begin
            DIVISOR_reg <= DIVISOR_reg >> 1;
        end
    end

    always @(posedge CLK or negedge RST) begin
     if(!RST)
      begin
        div_busy<=0;
      end
    else if (DIV_START) begin
            enable<=1;
            quotient_temp <= 0;
            count <= 0;
            div_busy<=1;
        end else if ((count != 33)&&enable) begin
            quotient_temp <= {quotient_temp[30:0], write};
            count <= count + 1;
            div_busy<=~(count==32);
        end   
        else
            begin
            count <= 0;
            enable<=0;
            end
    end

    always @(posedge CLK) begin
        if (DIV_START) begin
            REMAINDER_temp <= {32'b0, abs_dividend};
        end else if (count != 33&&enable) begin
            if (write) begin
                REMAINDER_temp <= alu_res;
            end
        end else begin
            // Adjust the sign of the remainder
            
        end
    end
    assign abs_dividend = SIGNED? (DIVIDEND[31] ? -DIVIDEND : DIVIDEND) : DIVIDEND;
    assign abs_divisor  = SIGNED? (DIVISOR[31] ? -DIVISOR : DIVISOR) : DIVISOR;
    assign dividend_sign = sign_en? dividend_sign_reg : 0;
    assign divisor_sign = sign_en? divisor_sign_reg : 0;
    assign QUOTIENT = (count!=33)? 0:((dividend_sign ^ divisor_sign) ? -quotient_temp : quotient_temp);
    assign REMAINDER = (count!=33)? 0:(dividend_sign ? -REMAINDER_temp : REMAINDER_temp);
    assign alu_res = REMAINDER_temp - DIVISOR_reg;
    assign write = (alu_res < 0 || !DIVISOR_reg) ? 0 : 1;
    assign ready = (count!=33)? 0:1; 
	
	assign divide_zero = (DIV_START)? ( (DIVISOR==32'd0)? 1 :0 ) : 0;

endmodule



