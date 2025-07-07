module MIPS_PIPE (
        //input 
        input  wire         CLK ,
        input  wire         RST ,
        input  wire   [31:0] DATA_IN,
        input wire          w_enable, 
        //output
        output wire [31:0]  result 
    );
    wire JR_flagM,JR_flagE,JR_flag;
    // Signals     
    reg  [31:0] PCF;
    wire [31:0] InstrF,InstrD,ReadDataW, ResultW , SignImmE, RD1D,RD1E, RD2D,RD2E ,PCN ,PCBranchM,PCBranchD,PCPlus4D,PCPlus4F,PCPlus4E,PCJumpD;
    wire signed [31:0]  ALUOutM , ALUOutE;
    wire [5:0] opcode, Funct;
    wire [4:0] A1, A2 , RsD, RsE, RtD,RtE,RdD,RdE ,WriteRegE,WriteRegM,WriteRegW,HI_TO_REG_D,HI_TO_REG_E;
    //wire [4:0] A3;
    wire [4:0] ALUControlD     , ALUControlE;
    wire MemWriteD  , ALUSrcD , RegWriteD                      ; // DECODE
    wire MemWriteE  , ALUSrcE , RegWriteE         , ZeroE              ; //EXECUTE
    wire  MemWriteM                      , RegWriteM         , ZeroM   ; //MEMORY
    wire RegWriteW                              ; // WRITEBACK
    wire [1:0] MemtoRegD,MemtoRegE,MemtoRegM,MemtoRegW,RegDstD,RegDstE;
    //
    wire [4:0] shamtD , shamtE ;
    ////added 
    wire  [31:0] WriteDataM;
    wire  [31:0] ALUOutW;
    wire  [31:0] WriteDataE;
    wire  [31:0] PCBranchE ;
    wire  [31:0] SignImmD;
    wire sign_flag;
    wire lui_flag;
    wire [2:0] load_choice_D;
    wire [2:0] load_choice_E;
    wire [2:0] load_choice_M;

    wire [2:0] sw_choice_D;
    wire [2:0] sw_choice_E;
    wire [2:0] sw_choice_M;

    wire hi_lo_reg_control_D,hi_lo_reg_control_E,hi_lo_reg_control_M;
    wire hi_lo_en_D,hi_lo_en_E,hi_lo_en_M;
    wire [31:0] hi_rd_W,lo_rd_W,lo_rd_M,hi_rd_M;
    wire [31:0] RD1_M;
    wire START_D,SIGNED_D,START_E,SIGNED_E;
    wire [63:0] product_E,product_M;
    wire mult_ready_E,mult_ready_M;
    
    wire DIV_START_E,DIV_START_D;
    wire [63:0] REMAINDER_E,REMAINDER_M;
    wire [31:0] QUOTIENT_E,QUOTIENT_M;
    wire div_ready_E,div_ready_M;
	
    wire [1:0] JumpD ;
	wire [31:0] cp0_to_regfile_D,cp0_to_regfile_E;
	wire [31:0] cp0_to_regfileM,cp0_to_regfileW;
	wire [31:0] exc_handler_add,PCN1;
	wire mfc0_D , mfc0_E ,mfc0M,mfc0W , cp0_write , overflow , divide_zero , exception;
	wire [1:0] CauseSelect;
	
	wire stallF, stallD, CLRF, FlushE, ForwardAD, ForwardBD ;
    wire [1:0] ForwardAE, ForwardBE ;
    wire [31:0] Comp_mux1, Comp_mux2 ; // Branch comparator values from muxs
    wire EqualD ;
	wire [31:0] SrcAE, SrcBE ;
	
	
	wire [31:0] pred_target,pred_target_D;
	wire  Branch_taken_pred;
	wire [5:0]Branch_taken_pred_out;
    wire [5:0]Branch_taken_pred_out_D;
	wire [5:0] wrong_taken;
	wire [5:0] wrong_not_taken;
	wire Branch_flag_BEQ, Branch_flag_BNE, Branch_flag_BLEZ, Branch_flag_BGTZ, Branch_flag_BGEZ, Branch_flag_BLTZ;
	wire [5:0] Branch;
	wire jump_flag;
	wire [31:0]jump_target;
	wire JAL_flag,JAL_flagD;
	
	
    //################################
    //       AHP & APB SIGNALS
    //################################
	
	wire gpio_enable , gpio_enableW;
	wire data_mem_enable , data_mem_enableW;
	wire bridge_enable;
	wire timer_enable , timer_enableW;
	wire default_slave_enable , default_slave_enableW;
	wire [11:0]gpio_addr,uart_addr;
	wire [11:0]data_mem_addr;
	wire [11:0]bridge_addr;
	wire [11:0]timer_addr;
	wire [11:0]default_slave_addr;
	wire [31:0]rd_data_mem;
	wire [31:0]rd_timer;
	wire [31:0]rd_default_slave;
	wire [31:0]rd_gpio;
	wire [31:0]WriteDataW;
	wire MemWriteW;
	wire timer_ready,gpio_ready,gpio_resp;
	wire timer_interrupt,gpio_comb_interrupt;
	wire timer_err;
	wire timer_external_input;
	wire [15:0] gpio_interrupt,gpio_external_input, gpio_out;
    //################################
    //  Fetch    stage 
    //################################
	// PCN : next pc
	// PCF : input to the instruction mem
	
	assign exc_handler_add = 32'h80000180;
    assign PCN1 = (wrong_not_taken!=0) ? pred_target_D : (wrong_taken!=0) ? PCPlus4D : (jump_flag)? jump_target : (JumpD[1])? RD1D : (Branch_taken_pred) ? pred_target : PCPlus4F;
	assign PCN  = (exception || timer_interrupt || gpio_comb_interrupt) ? exc_handler_add : (JR_flag&&ForwardAE[1])? ALUOutM:PCN1;
	

    always @(posedge CLK or negedge RST) begin
        if(!RST)
            PCF<=0;
        else if (!stallF)  
		begin
            PCF <= PCN ;  
        end 
    end
	
    // Instruction Memory
    Instruction_Memory im (
        .A(PCF[11:0]),
        .RD(InstrF),
        .CLK(CLK),
        .DATA_IN(DATA_IN),
        .w_enable(1'b0)     
    );
    assign PCPlus4F = PCF + 4 ;


Branch_Prediction  BP(
    .instruction_Branch(InstrF),
    .clk(CLK),
    .rst(RST),
    .Branch_taken(Branch),
    .pred_target(pred_target),
    .PC(PCF[31:28]) ,
	.PCPlus4F(PCPlus4F),
    .Branch_taken_pred_out(Branch_taken_pred_out),
    .Branch_taken_pred(Branch_taken_pred),
    .Branch_flag_BEQ(Branch_flag_BEQ),
	.Branch_flag_BNE(Branch_flag_BNE), 
	.Branch_flag_BLEZ(Branch_flag_BLEZ), 
	.Branch_flag_BGTZ(Branch_flag_BGTZ), 
	.Branch_flag_BGEZ(Branch_flag_BGEZ), 
	.Branch_flag_BLTZ(Branch_flag_BLTZ),
	.jump_flag(jump_flag),
	.jump_target(jump_target),
	.JAL_flag(JAL_flag)
);
    //################################
    //  Decode stage    
    //################################
     assign CLRF= ( (wrong_not_taken!=0) || wrong_taken!=0 ) |JR_flag;
    FETCH_DECODE   F2D (
        .CLK(CLK),
        .RST(RST),
        .InstrF(InstrF)    , .InstrD(InstrD)   ,
        .stallD(stallD)    , .CLR(CLRF)        ,
        .PCPlus4F(PCPlus4F), .PCPlus4D(PCPlus4D) ,
        .Branch_taken_pred_out(Branch_taken_pred_out),
        .Branch_taken_pred_out_D(Branch_taken_pred_out_D),
		.pred_target_D(pred_target_D),
		.pred_target(pred_target),
		.JAL_flagF(JAL_flag),
		.JAL_flagD(JAL_flagD)
    );

    // Decode instruction
    assign opcode = InstrD[31:26]  ;
    assign Funct  = InstrD[5:0]    ;
    assign A1     = InstrD[25:21]  ;
    assign A2     = InstrD[20:16]  ;
    assign RsD    = InstrD[25:21]  ;
    assign RtD    = InstrD[20:16]  ;
    assign RdD    = InstrD[15:11]  ;
    assign HI_TO_REG_D = InstrD[25:21];
    assign shamtD = InstrD[10:6]   ;

    //assign A3 = RegDst ? Instr[15:11] : Instr[20:16];

    // Control Unit
    Control_ALU cu (
        .Funct(Funct),
        .opcode(opcode),
        .RegWrite(RegWriteD),
        .MemtoReg(MemtoRegD),
        .MemWrite(MemWriteD),
        // .Branch(BranchD), to be drived from the branch unit
        .ALUControl(ALUControlD),
        .ALUSrc(ALUSrcD),
        .RegDst(RegDstD),
        .Jump(JumpD),
        .sign_flag(sign_flag),
        .lui_flag(lui_flag),
        .load_choice(load_choice_D),
        .sw_choice  (sw_choice_D),
        .START(START_D),
        .SIGNED(SIGNED_D),
        .hi_lo_reg_control(hi_lo_reg_control_D),
        .hi_lo_write_en(hi_lo_en_D),
        .DIV_START(DIV_START_D),
		.cp0_write(cp0_write),
		.mfc0(mfc0_D),
		.overflow(overflow),
		.divide_zero(divide_zero),
		.exception(exception),
		.CauseSelect(CauseSelect),
		.JR_flag(JR_flag)
    );
    
    // Branch Unit
    Branch_Unit bu (
        .OpCode(opcode),
        .rt(RtD),
        .RD1(Comp_mux1),
        .RD2(Comp_mux2),
        .Branch(Branch),
        .Branch_pred_unit(Branch_taken_pred_out_D),
		.wrong_taken(wrong_taken),
		.wrong_not_taken(wrong_not_taken),
		.Branch_flag_BEQ(Branch_flag_BEQ),
		.Branch_flag_BNE(Branch_flag_BNE), 
		.Branch_flag_BLEZ(Branch_flag_BLEZ), 
		.Branch_flag_BGTZ(Branch_flag_BGTZ), 
		.Branch_flag_BGEZ(Branch_flag_BGEZ), 
		.Branch_flag_BLTZ(Branch_flag_BLTZ)
    );

    // Register File
    Register_File rf (
        .CLK(CLK),
        .RST(RST),
        .WE3(RegWriteW),
        .A1(A1),
        .A2(A2),
        .A3(WriteRegW),
        .WD3(ResultW),
        .RD1(RD1D),
        .RD2(RD2D),
		.JAL_flagD(JAL_flagD),
		.PCPLUS4D(PCPlus4D)
    );

    assign Comp_mux1 = (ForwardAD)? ALUOutM : RD1D ;
    assign Comp_mux2 = (ForwardBD)? ALUOutM : RD2D ;
    assign EqualD = (Comp_mux1== Comp_mux2) ;
    // Sign Extend
    Sign_Extend se (
        .IN_SE(InstrD[15:0]),
        .sign_flag(sign_flag),
        .SignImm(SignImmD),
        .lui_flag(lui_flag)
    );

	wire [4:0] cp0_address,EPC;
	wire [31:0] write_cp0;

	assign EPC = 5'd14; //exception program counter reg address
	assign write_cp0 = (exception) ? PCPlus4D : RD2D ; 
	assign cp0_address = (exception)? EPC : InstrD[15:11] ; 
		
	// co_procesor 0
	CP0 cp0(
		.clk(CLK),
		.rst(RST),
		.rd(cp0_address),  // Rd or EPC
		.write_data(write_cp0),   // store pc+4 in EPC or store value from regfile (in the same cycle)
		.cp0_write(cp0_write),
		.read_data(cp0_to_regfile_D),
		.CauseSelect(CauseSelect)
);

    assign PCJumpD   = {PCPlus4D[31:28],InstrD[25:0]<<2} ;

    //################################
    //  Execute stage    
    //################################

    DECODE_EXCUTE  D2E(
        .CLK(CLK),
        .RST(RST),
        .CLR(FlushE),
        .RegWriteD(RegWriteD)    , .RegWriteE(RegWriteE),
        .MemtoRegD(MemtoRegD)    , .MemtoRegE(MemtoRegE),
        .MemWriteD(MemWriteD)    , .MemWriteE(MemWriteE),
        .ALUControlD(ALUControlD), .ALUControlE(ALUControlE),
        .ALUSrcD(ALUSrcD)        , .ALUSrcE(ALUSrcE),
        .RegDstD(RegDstD)        , .RegDstE(RegDstE),
        .RD1D(RD1D)              , .RD1E(RD1E),
        .RD2D(RD2D)              , .RD2E(RD2E),
        .RsD(RsD)                , .RsE(RsE),
        .RtD(RtD)                , .RtE(RtE),
        .RdD(RdD)                , .RdE(RdE),
        .SignImmD(SignImmD)      , .SignImmE(SignImmE),
        .PCPlus4D(PCPlus4D)      , .PCPlus4E(PCPlus4E),
        .shamtD(shamtD)          , .shamtE(shamtE)    ,
        .load_choice_D(load_choice_D),.load_choice_E(load_choice_E),
        .sw_choice_D  (sw_choice_D),.sw_choice_E  (sw_choice_E),
        .HI_TO_REG_D(HI_TO_REG_D),.HI_TO_REG_E(HI_TO_REG_E),
        .SIGNED_D(SIGNED_D),.SIGNED_E(SIGNED_E),
        .START_D(START_D),.START_E(START_E),
        .hi_lo_reg_control_D(hi_lo_reg_control_D),.hi_lo_reg_control_E(hi_lo_reg_control_E),
        .hi_lo_en_D(hi_lo_en_D),.hi_lo_en_E(hi_lo_en_E),
        .DIV_START_E(DIV_START_E),.DIV_START_D(DIV_START_D),
		.mfc0_D(mfc0_D),       .mfc0_E(mfc0_E),
		.cp0_to_regfile_D(cp0_to_regfile_D) ,   .cp0_to_regfile_E(cp0_to_regfile_E),
		.JAL_flagE(JR_flagE),.JAL_flagD(JR_flag)
     );
     
       mux_4x1 mux1_hazard(
        .RD(RD1E), .result(ResultW), .ALUOutM(ALUOutM),
        .selector(ForwardAE),
        .Src(SrcAE)
        );
        
       mux_4x1 mux2_hazard(
        .RD(RD2E), .result(ResultW), .ALUOutM(ALUOutM),
        .selector(ForwardBE),
        .Src(SrcBE)
        );
     
     
    // ALU
    ALU alu (
        .SrcA(SrcAE),
        .SrcB(ALUSrcE ? SignImmE : SrcBE),
        .ALUControl(ALUControlE),
        .Zero(ZeroE),
        .shamt(shamtE),
        .ALUResult(ALUOutE),
		.OverFlow(overflow)
    );
    assign WriteRegE = (RegDstE[1])? (RegDstE[0]? 5'b0:HI_TO_REG_E):(RegDstE[0]? RdE : RtE) ;
    assign PCBranchE = PCPlus4E + (SignImmE<<2) ;
    assign PCBranchD = PCPlus4D + (SignImmD<<2) ;
    //################################
    //  Memory stage    
    //################################
    assign WriteDataE=RD2E;
    EXCUTE_MEMORY E2M(
        .CLK(CLK) , .RST(RST) ,
        .RegWriteE(RegWriteE) , .RegWriteM(RegWriteM) ,
        .MemtoRegE(MemtoRegE) , .MemtoRegM(MemtoRegM) ,
        .MemWriteE(MemWriteE) , .MemWriteM(MemWriteM) ,
        .ZeroE(ZeroE)         , .ZeroM(ZeroM)         ,
        .ALUOutE(ALUOutE)     , .ALUOutM(ALUOutM)     ,
        .WriteDataE(WriteDataE), .WriteDataM(WriteDataM),
        .WriteRegE(WriteRegE) , .WriteRegM(WriteRegM) ,
        .PCBranchE(PCBranchE) , .PCBranchM(PCBranchM) ,
        .load_choice_E(load_choice_E),.load_choice_M(load_choice_M),
        .sw_choice_E  (sw_choice_E),.sw_choice_M  (sw_choice_M),
        .product_M(product_M),.product_E(product_E),
        .mult_ready_M(mult_ready_M),.mult_ready_E(mult_ready_E),
        .hi_lo_reg_control_M(hi_lo_reg_control_M),.hi_lo_reg_control_E(hi_lo_reg_control_E),
        .hi_lo_en_M(hi_lo_en_M),.hi_lo_en_E(hi_lo_en_E),
        .RD1_E(RD1E),.RD1_M(RD1_M),
        .REMAINDER_E(REMAINDER_E),.REMAINDER_M(REMAINDER_M),
        .QUOTIENT_E(QUOTIENT_E),.QUOTIENT_M(QUOTIENT_M),
        .div_ready_M(div_ready_M),.div_ready_E(div_ready_E),
		.mfc0E(mfc0_E),        .mfc0M(mfc0M),
		.cp0_to_regfileE(cp0_to_regfile_E), .cp0_to_regfileM(cp0_to_regfileM),
		.JAL_flagE(JR_flagE),.JAL_flagM(JR_flagM)
    );
	
	
	//################################
    //           AHB
    //################################


    // Data Memory
     Data_Memory dm(
        .A(data_mem_addr),
        .RST(RST),
        .CLK(CLK),
        .WD(WriteDataM),
        .WE(MemWriteM&&data_mem_enable),
        .RD(rd_data_mem),
        .load_choice(load_choice_M),
        .sw_choice(sw_choice_M)
    );
    //assign PCSrcD = BranchD; // Condition was already checked in the Decode Stage



Default_Slave Default_Slave0 (
        .A(default_slave_addr),
        .RST(RST),
        .CLK(CLK),
        .WD(WriteDataM),
        .WE(MemWriteM&&default_slave_enable),
        .RD(rd_default_slave),
        .load_choice(load_choice_M),
        .sw_choice(sw_choice_M)
    );


assign ReadDataW= (!MemWriteW)?((data_mem_enableW)?rd_data_mem:(timer_enableW)?rd_timer:(default_slave_enableW)?rd_default_slave:(gpio_enableW)?rd_gpio:32'd0) : 32'd0;


  AHB_Decoder ahb(
    .haddr(ALUOutE[15:0]),
	.bridge_ready(bridge_ready),
    .gpio_enable(gpio_enable),
    .data_mem_enable(data_mem_enable),
    .bridge_enable(bridge_enable),
    .default_slave_enable(default_slave_enable),
    .gpio_addr(gpio_addr),
    .data_mem_addr(data_mem_addr),
    .bridge_addr(bridge_addr),
    .default_slave_addr(default_slave_addr)
);


  AHB_APB_BRIDGE ahb_apb_bridge(
    .clk(CLK),
    .rst(RST),
    .haddr(bridge_addr),
	.bridge_enable(bridge_enable),
	.write_enable(MemWriteM),
	
	/////// outputs  ///////////
    .uart_enable(uart_enable),
    .timer_enable(timer_enable),
    .uart_addr(uart_addr),
    .timer_addr(timer_addr),
	.penable(penable),
	.ready(bridge_ready)  
);

cmsdk_apb_timer timer (
  .PCLK(CLK),    	// PCLK for timer operation
  .PCLKG(1'b1),   	// Gated clock
  .PRESETn(RST), 	// Reset

  .PSEL(timer_enable),    	// Device select
  .PADDR(timer_addr[11:2]),   	// Address
  .PENABLE(penable), 	// Transfer control
  .PWRITE(MemWriteW && timer_enableW),  	// Write control
  .PWDATA(WriteDataW),  	// Write data

  .ECOREVNUM(4'b0000), // Engineering-change-order revision bits

  .PRDATA(rd_timer),  	// Read data
  .PREADY(timer_ready),  	// Device ready
  .PSLVERR(timer_err), 	// Device error response

  .EXTIN(timer_external_input),   	// External input

  .TIMERINT(timer_interrupt)   );// Timer interrupt output
  
  
  cmsdk_ahb_gpio gpio(// AHB Inputs
   .HCLK(CLK),      // system bus clock
   .HRESETn(RST),   // system bus reset
   .FCLK(CLK),      // system bus clock
   .HSEL(gpio_enable),      // AHB peripheral select
   .HREADY(1'b1),    // AHB ready input
   .HTRANS(2'b10),    // AHB transfer type (always single)
   .HSIZE(3'b010),     // AHB hsize (always word)
   .HWRITE(MemWriteW && gpio_enableW),    // AHB hwrite
   .HADDR(gpio_addr),     // AHB address bus
   .HWDATA(WriteDataW),    // AHB write data bus
                        
   .ECOREVNUM(4'b0000),  // Engineering-change-order revision bits
                        
   .PORTIN(gpio_external_input),     // GPIO Interface input
                        
   // AHB Outputs                         
   .HREADYOUT(gpio_ready), // AHB ready output to S->M mux
   .HRESP(gpio_resp),     // AHB response
   .HRDATA(rd_gpio),
                        
   .PORTOUT(gpio_out),    // GPIO output
   .PORTEN(),     // GPIO output enable
   .PORTFUNC(),   // Alternate function control
   .ALT_FUNC(),   // Alternate function selector
   .GPIOINT(gpio_interrupt),    // Interrupt output for each pin
   .COMBINT(gpio_comb_interrupt) );   // Combined interrupt


    //################################
    //  Writeback stage    
    //################################

    MEMORY_WB M2W (
        .CLK(CLK)                , .RST(RST)  ,
        .RegWriteM(RegWriteM)    , .RegWriteW(RegWriteW)  ,
        .MemtoRegM(MemtoRegM)    , .MemtoRegW(MemtoRegW) ,
        .ALUOutM(ALUOutM)        , .ALUOutW(ALUOutW)   ,
        .WriteRegM(WriteRegM)    , .WriteRegW(WriteRegW),
        .hi_rd_M(hi_rd_M),.hi_rd_W(hi_rd_W),.lo_rd_M(lo_rd_M),.lo_rd_W(lo_rd_W),
		.mfc0M(mfc0M),             .mfc0W(mfc0W),
		.cp0_to_regfileM(cp0_to_regfileM), .cp0_to_regfileW(cp0_to_regfileW),
		.WriteDataM(WriteDataM),			   .WriteDataW(WriteDataW), //use it with apb pripherals
		.MemWriteM(MemWriteM),				   .MemWriteW(MemWriteW),
		.data_mem_enable(data_mem_enable),     .data_mem_enableW(data_mem_enableW),
		.uart_enable(uart_enable),			   .uart_enableW(uart_enableW),
		.timer_enable(timer_enable),		   .timer_enableW(timer_enableW),
		.default_slave_enable(timer_enable),   .default_slave_enableW(default_slave_enableW),
        .gpio_enable(timer_enable),		   .gpio_enableW(gpio_enableW)
		
        );
    
    hi_lo_reg HILO( .hi_lo_reg_control(hi_lo_reg_control_M),
                    .CLK(CLK),
                    .RST(RST),
                    .hi_lo_en(hi_lo_en_M),
                    .hi_lo_wd(RD1_M),
                    .hi_rd(hi_rd_M),
                    .lo_rd(lo_rd_M),
                    .product(product_M),
                    .mult_ready(mult_ready_M),
                    .remainder(REMAINDER_M),
                    .quotient(QUOTIENT_M),
                    .div_ready(div_ready_M)
                   );
                   
    booth_multi multi( .CLK(CLK),
                       .START(START_E),
                       .SIGNED(SIGNED_E),
                       .multiplicand(RD1E),
                       .multiplier(RD2E),
                       .product(product_E),
                       .ready(mult_ready_E),
                       .busy(busy),
                       .RST(RST)
                      );   
                      
    divide div(.CLK(CLK),
               .DIV_START(DIV_START_E),
               .DIVIDEND(RD1E),
               .div_busy(div_busy),
               .RST(RST),
               .DIVISOR(RD2E),
               .SIGNED(SIGNED_E),
               .REMAINDER(REMAINDER_E),
               .QUOTIENT(QUOTIENT_E),
			   .divide_zero(divide_zero),
               .ready(div_ready_E));
			   
    // Write Data
	wire [31:0] temp;
    assign temp = MemtoRegW[1]? (MemtoRegW[0]? lo_rd_W: hi_rd_W):(MemtoRegW[0]? ReadDataW : ALUOutW );
	assign ResultW = (mfc0W)? cp0_to_regfileW : temp ;  //what to write in the reg file 
    assign result= ALUOutW;

   hazard_unit HU (
            .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .MemtoRegE(MemtoRegE[0]),
            .BranchD({Branch_flag_BEQ,Branch_flag_BNE,Branch_flag_BLEZ,Branch_flag_BGTZ,Branch_flag_BGEZ,Branch_flag_BLTZ}),     .RegWriteE(RegWriteE), .MemtoRegM(MemtoRegM[0]),
            .RsE(RsE), .RtE(RtE), .RsD(RsD), .RtD(RtD),.busy_M(busy),.div_busy(div_busy),
            .WriteRegM(WriteRegM), .WriteRegW(WriteRegW), .WriteRegE(WriteRegE),
            .wrong_taken(wrong_taken), .wrong_not_taken(wrong_not_taken),
            .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
            .ForwardAD(ForwardAD), .ForwardBD(ForwardBD),
            .FlushE(FlushE), .StallD(stallD), .StallF(stallF),
            .START_E(START_E),.RST(RST),.div_start(DIV_START_E),
            .JR_flag(JR_flag)
        );
endmodule



   

