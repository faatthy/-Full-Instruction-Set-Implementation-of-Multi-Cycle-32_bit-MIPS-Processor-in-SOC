module Cache_tb;
    reg clk;
    reg rst;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg write;
    wire [31:0] rdata;
    wire hit;
    
    // Instantiate the Cache module
    Cache uut (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .write(write),
        .rdata(rdata),
        .hit(hit)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Monitor signals
    initial begin
       
    $monitor("Time: %0d | Addr: %08x | Write: %0d | WData: %08x | RData: %08x | Hit: %0d", $time, addr, write, wdata, rdata, hit);
    // Check the state of LRU, valid bits, and tags
    //$monitor("LRU[%0d]: %0d, Valid: %b, Tags: %h, %h", index, lru[index], valid[index], tags[index][0], tags[index][1]);


    end
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        addr = 0;
        wdata = 0;
        write = 0;
        
        // Apply reset
        rst = 1;
        #10 rst = 0;
        
        // Test 1: Write to address 0x00000000
        addr = 32'h00000000;
        wdata = 32'hAAAA5555;
        write = 1;
        #10;
        
        // Test 2: Write to address 0x00000040
        addr = 32'h00000040;
        wdata = 32'hBBBB6666;
        write = 1;
        #10;
        
        // Test 3: Write to address 0x00000080
        addr = 32'h00000080;
        wdata = 32'hCCCC7777;
        write = 1;
        #10;
        
        // Test 4: Read from address 0x00000000 (should hit)
        addr = 32'h00000000;
        write = 0;
        #10;
        
        // Test 5: Read from address 0x00000040 (should hit)
        addr = 32'h00000040;
        write = 0;
        #10;
        
        // Test 6: Read from address 0x00000080 (should hit)
        addr = 32'h00000080;
        write = 0;
        #10;
        
        // Test 7: Write to address 0x000000C0 (should cause LRU replacement)
        addr = 32'h000000C0;
        wdata = 32'hDDDD8888;
        write = 1;
        #10;
        
        // Test 8: Read from address 0x00000000 (should miss if LRU replaced)
        addr = 32'h00000000;
        write = 0;
        #10;
        
        // Test 9: Read from address 0x00000040 (should hit)
        addr = 32'h00000040;
        write = 0;
        #10;
        
        // Test 10: Read from address 0x00000080 (should hit)
        addr = 32'h00000080;
        write = 0;
        #10;
        
        // Test 11: Read from address 0x000000C0 (should hit)
        addr = 32'h000000C0;
        write = 0;
        #10;

        // End simulation
        $stop;
    end
    
endmodule

