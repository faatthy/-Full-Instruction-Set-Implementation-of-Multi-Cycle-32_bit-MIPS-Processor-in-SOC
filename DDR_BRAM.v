
//  Xilinx True Dual Port RAM Byte Write Read First Single Clock RAM
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  The behavior of this RAM is when data is written, the prior memory contents at the write
//  address are presented on the output port.
  module DDR_BRAM #(parameter 
    NB_COL = 4,                       // Specify number of columns (number of bytes)
    COL_WIDTH = 8,                  // Specify column width (byte width, typically 8 or 9)
    RAM_DEPTH = 750,                  // Specify RAM depth (number of entries)
    RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    INIT_FILE = "",                  // Specify name/location of RAM initialization file if using one (leave blank if not)
    RAM_WIDTH = NB_COL*COL_WIDTH 
  )(
    input clk,rst,en,  //  ena/enb always 1
    input regce, //always zero 
    input  wen, // write enables
    input [11:0] addr,
    input [(NB_COL*COL_WIDTH)-1:0]  wr_data,
    output [(NB_COL*COL_WIDTH)-1:0] rd
  );
                    

  /*<wire_or_reg>  addr_a;   // Port A address bus, width determined from RAM_DEPTH
  <wire_or_reg> [clogb2(RAM_DEPTH-1)-1:0] addr_b;   // Port B address bus, width determined from RAM_DEPTH
  <wire_or_reg>  wr_data_a;   // Port A RAM input data
  <wire_or_reg> [(NB_COL*COL_WIDTH)-1:0] <dinb>;   // Port B RAM input data
  <wire_or_reg> clk;                            // Clock
  <wire_or_reg>  <wea>;                // Port A write enable
  <wire_or_reg> [NB_COL-1:0] <web>;                // Port B write enable
  <wire_or_reg> ena;                             // Port A RAM Enable, for additional power savings, disable port when not in use
  <wire_or_reg> enb;                             // Port B RAM Enable, for additional power savings, disable port when not in use
  <wire_or_reg> <rsta>;				 // Port A output reset (does not affect memory contents)
  <wire_or_reg> <rstb>;                            // Port B output reset (does not affect memory contents)
  <wire_or_reg> <regcea>;                          // Port A output register enable
  <wire_or_reg> <regceb>;                          // Port B output register enable
  wire  rd_a; // Port A RAM output data
  wire [(NB_COL*COL_WIDTH)-1:0] <doutb>; // Port B RAM output data*/

  reg [(NB_COL*COL_WIDTH)-1:0] mem_arr [RAM_DEPTH-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data = {(NB_COL*COL_WIDTH){1'b0}};
  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
   // The following code either initializes the memory values to a specified file or to all zeros to match hardware
   generate
     if (INIT_FILE != "") begin: use_init_file
       initial
         $readmemh(INIT_FILE, mem_arr, 0, RAM_DEPTH-1);
     end else begin: init_bram_to_zero
       integer ram_index;
       initial
         for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
           mem_arr[ram_index] = {RAM_WIDTH{1'b0}};
     end
   endgenerate
 
   always @(posedge clk)
     if (en)
       if (wen)
         mem_arr[addr] <= wr_data;
         
   always@(negedge clk) ram_data <= mem_arr[addr];
 
   //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
   generate
     if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
 
       // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
        assign rd = ram_data;
 
     end else begin: output_register
 
       // The following is a 2 clock cycle read latency with improve clock-to-out timing
 
       reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
 
       always @(posedge clk)
         if (!rst)
           douta_reg <= {RAM_WIDTH{1'b0}};
         else if (regce)
           douta_reg <= ram_data;
 
       assign rd = douta_reg;
 
     end
   endgenerate
 
   //  The following function calculates the address width based on specified RAM depth
   function integer clogb2;
     input integer depth;
       for (clogb2=0; depth>0; clogb2=clogb2+1)
         depth = depth >> 1;
   endfunction
                        
                        
endmodule			
							