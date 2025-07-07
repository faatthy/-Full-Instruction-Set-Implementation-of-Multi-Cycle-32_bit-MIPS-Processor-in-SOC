module booth_multi #(parameter N=32,S=5)( input CLK,START,SIGNED,RST,
                                      input [N-1:0] multiplicand,multiplier,
                                      output reg [2*N-1:0] product,
                                      output ready,
                                      output reg busy
                                      );
reg [N-1:0] Q,M_bar,M;
wire [N-1:0] ACC_neg,ACC_pos;
wire [2*N-1:0] product_new;
reg Q_1;
reg [S:0]count;
wire [1:0] Q_Q_1;
reg sign_en,enable;

always@(posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
          busy<=0;
          enable<=0;
                  sign_en<=(SIGNED)? 1:0;
                  M<=0;
                  Q<=0;
                  M_bar<=0;
                  count<=N;
                  product<=0;
                  Q_1<=0;
                  busy<=0;
                  product<=0;
end    
    else if(START)
      begin
        enable<=1;
        sign_en<=(SIGNED)? 1:0;
        M<=multiplicand;
        Q<=multiplier;
        M_bar<=({N{1'b1}}-multiplicand)+1;
        count<=N;
        product<=0;
        Q_1<=0;
        busy<=1;
        product<=product_new;
      end
    else if((count!=0)&&enable)
      begin
        if(sign_en)
          begin
            case({product[0],Q_1})
              2'b00,2'b11:
                begin
                  product <= {product[2*N-1],product[2*N-1:1]};
                end
              2'b01:
                begin
                  product <= {ACC_pos[N-1],ACC_pos,product[N-1:1]};
                end
              2'b10:
                begin
                  product <= {ACC_neg[N-1],ACC_neg,product[N-1:1]};
                end
            endcase
          end
        else
          begin
            if(Q_Q_1)
              begin
                product<={(product[2*N-1:N]+M),product[N-1:1]};
              end
            else
              begin
                product<={1'b0,product[2*N-1:1]};
              end
          end 
        Q_1<=product[0];
        count<=count-1;
        busy<=~(count==1);
      end
    else begin
      enable<=0;
      count<=N;
    end
  end
assign ready = count? 0:1; 
assign product_new=(START)? {{N{1'b0}},multiplier}:product;
assign ACC_neg=(START)? 0:(product[2*N-1:N]+M_bar);
assign ACC_pos=(START)? 0:(product[2*N-1:N]+M);
assign Q_Q_1 = product[0];
endmodule




