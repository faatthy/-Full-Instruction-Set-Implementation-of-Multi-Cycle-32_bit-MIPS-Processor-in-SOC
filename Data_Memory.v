module Data_Memory (
    //input
    input  wire  [11:0]  A    ,
    input  wire          CLK  ,
    input  wire          RST  ,
    input  wire  [31:0]  WD   ,
    input  wire          WE   ,
    input wire [2:0] load_choice,
    input wire [2:0] sw_choice,
    //output
    output reg    [31:0]  RD   
);

reg [7:0]temp;
integer i;     
wire [31:0] RD_mem,WD_mem;
reg [31:0] WD_mem_wire;

DDR_BRAM #(.NB_COL(4),.COL_WIDTH(8),.RAM_DEPTH(1024))DM_BRAM(
.clk(CLK),
.regce(1'b0),
.en(1'b1),
.rst(RST),
.wen(WE),
.addr(A),
.wr_data(WD_mem),
.rd(RD_mem)
);



assign WD_mem=WD_mem_wire;
always @(*) begin
    WD_mem_wire=0;
    if (WE) begin
       case(sw_choice)
        3'b001: begin
            WD_mem_wire={{24{1'b0}},WD[7:0]};
        end
        3'b010:begin
            WD_mem_wire={{16{1'b0}},WD[15:0]};
        end
        3'b011:begin
             WD_mem_wire = WD;
        end
        default:begin
            WD_mem_wire=0;
        end
       endcase
    end    
end 

    //for load operation
     always @(*) begin
            RD=0;
         case(load_choice)
            3'b000: begin
                RD=0;    
            end
            3'b001: begin //load byte signed
                RD = {{24{RD_mem[7]}},RD_mem[7:0]}; 
            end
            3'b010: begin //load byte unsigned
                 RD = {24'b0,RD_mem[7:0]}; 
            end
            3'b011: begin //load half word signed
                RD = {{16{RD_mem[15]}},RD_mem[15:0]}; 
            end
            3'b100: begin //load half word unsigned
            RD = {16'b0,RD_mem[15:0]};
            end
            3'b111: begin
                RD = RD_mem; 
            end
            default: begin
                RD=0;        
            end
         endcase
     end
endmodule


