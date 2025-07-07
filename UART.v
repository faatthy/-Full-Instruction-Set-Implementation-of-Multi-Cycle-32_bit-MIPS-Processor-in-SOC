module UART (
    input  wire  [9:0]  A,
    input  wire         CLK,
    input  wire         RST,
    input  wire  [31:0] WD,
    input  wire         WE,
    input  wire  [2:0]  load_choice,
    input  wire  [2:0]  sw_choice,
    output reg   [31:0] RD
);

wire [31:0] RD_mem, WD_mem;
reg  [31:0] WD_mem_wire;

DDR_BRAM #(.NB_COL(4), .COL_WIDTH(8), .RAM_DEPTH(1024)) UART_BRAM (
    .clk(CLK),
    .regce(1'b0),
    .en(1'b1),
    .rst(RST),
    .wen(WE),
    .addr(A),
    .wr_data(WD_mem),
    .rd(RD_mem)
);

assign WD_mem = WD_mem_wire;
always @(*) begin
    WD_mem_wire = 0;
    if (WE) begin
        case(sw_choice)
            3'b001: WD_mem_wire = {{24{1'b0}}, WD[7:0]};
            3'b010: WD_mem_wire = {{16{1'b0}}, WD[15:0]};
            3'b011: WD_mem_wire = WD;
            default: WD_mem_wire = 0;
        endcase
    end
end

always @(*) begin
    RD = 0;
    case(load_choice)
        3'b000: RD = 0;
        3'b001: RD = {{24{RD_mem[7]}}, RD_mem[7:0]};   // Load byte signed
        3'b010: RD = {24'b0, RD_mem[7:0]};             // Load byte unsigned
        3'b011: RD = {{16{RD_mem[15]}}, RD_mem[15:0]}; // Load half-word signed
        3'b100: RD = {16'b0, RD_mem[15:0]};            // Load half-word unsigned
        3'b111: RD = RD_mem;                           // Load word
        default: RD = 0;
    endcase
end
endmodule
