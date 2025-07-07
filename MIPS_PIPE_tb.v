module MIPS_PIPE_tb;

  // Clock and reset signals
  reg    RST;
  reg    CLK;
  reg [31:0] DATA_IN;
  reg  w_enable; 
  // Wire for the result output from DUT
  wire [31:0] result;
  
  // Instantiate the MIPS Pipeline module (DUT)
  MIPS_PIPE DUT (
    .RST (RST),
    .CLK (CLK),
    .result (result),
    .w_enable(w_enable),
    .DATA_IN(DATA_IN)
  );
  // Parameter for clock period
  parameter T_PERIOD = 10;
  
  // Clock generation
  always #(T_PERIOD/2) CLK = ~CLK;
  
  // Task to initialize the testbench
  task initialize;
    integer i;
    begin

          // Initialize the register file, if necessary
          DUT.rf.Mem_Reg[0] = 32'd0;  // Usually the $zero register
      // Load instructions into instruction memory
      //$readmemh("instructions.txt", DUT.im.Mem_Instr);
      //$display("Instruction Memory Contents:");
     // for (i = 0; i < 128; i = i + 1) begin
      //  $display("Address %0d: %h", i, DUT.im.Mem_Instr[i]);
     // end
      
      // Initialize the register file, if necessary
      DUT.rf.Mem_Reg[0] = 32'd0;  // Usually the $zero register
    end
  endtask
  
  // Monitor task to observe result changes
  task monitor;
    begin
      // Monitor the result output from DUT
      $monitor("At time %0t: Result = %0d", $time, DUT.rf.Mem_Reg[0]);
    end
  endtask
  
  // Initial block to start the simulation
  initial begin
    // Initialize signals
    RST = 0;
    CLK = 0;
    
    // Initialize DUT
    #(T_PERIOD);
    initialize();
    
    // Apply reset
    RST = 1;
    #1000;  // Simulation time

    // Display a specific register value
    //$display("Register 25 value = %d", DUT.rf.Mem_Reg[25]);

    // Stop the simulation
    $stop;
  end
  
  // Call monitor task
  

endmodule


