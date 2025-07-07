module Cache(
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] wdata,
    input write,
    output reg [31:0] rdata,
    output reg hit
);
    // Cache parameters
    parameter BLOCK_SIZE = 64;
    parameter CACHE_SIZE = 8192;
    parameter NUM_WAYS = 2;
    parameter NUM_SETS = CACHE_SIZE / (BLOCK_SIZE * NUM_WAYS);
    parameter INDEX_BITS = 6;
    parameter OFFSET_BITS = 6;
    parameter TAG_BITS = 32 - INDEX_BITS - OFFSET_BITS;
    
    // Cache storage
    reg [31:0] data[NUM_SETS-1:0][NUM_WAYS-1:0][BLOCK_SIZE/4-1:0]; // Data memory
    reg [TAG_BITS-1:0] tags[NUM_SETS-1:0][NUM_WAYS-1:0]; // Tag memory
    reg valid[NUM_SETS-1:0][NUM_WAYS-1:0]; // Valid bits
    reg dirty[NUM_SETS-1:0][NUM_WAYS-1:0]; // Dirty bits
    reg lru[NUM_SETS-1:0][NUM_WAYS-1:0]; // LRU bits
    
    wire [INDEX_BITS-1:0] index;
    wire [OFFSET_BITS-1:0] offset;
    wire [TAG_BITS-1:0] tag;

    assign index = addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    assign offset = addr[OFFSET_BITS-1:0];
    assign tag = addr[31:OFFSET_BITS+INDEX_BITS];
    
    integer i, j, k;
    integer lru_way;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize the cache
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                for (j = 0; j < NUM_WAYS; j = j + 1) begin
                    valid[i][j] <= 0;
                    tags[i][j] <= 0;
                    dirty[i][j] <= 0;
                    lru[i][j] <= j; // Initialize LRU bits
                    // Clear all data in the cache blocks
                    for (k = 0; k < BLOCK_SIZE/4; k = k + 1) begin
                        data[i][j][k] <= 0;
                    end
                end
            end
            hit <= 0;
            rdata <= 32'h00000000;
        end else begin
            hit <= 0;
            rdata <= 32'hxxxxxxxx;
            // Check all ways for a hit
            for (j = 0; j < NUM_WAYS; j = j + 1) begin
                if (valid[index][j] && (tags[index][j] == tag)) begin
                    // Cache hit
                    hit <= 1;
                    rdata <= data[index][j][offset[OFFSET_BITS-1:2]];
                    
                    if (write) begin
                        data[index][j][offset[OFFSET_BITS-1:2]] <= wdata;
                        dirty[index][j] <= 1; // Mark as dirty
                    end
                    
                    // Update LRU for all ways in this set
                    for (k = 0; k < NUM_WAYS; k = k + 1) begin
                        if (k != j) lru[index][k] <= 1; // Mark all others as less recently used
                        else lru[index][k] <= 0; // Mark this way as most recently used
                    end
                end
            end
            
            if (!hit) begin
                // Cache miss, select the LRU way
                for (j = 0; j < NUM_WAYS; j = j + 1) begin
                    if (lru[index][j] == 1) begin
                        lru_way = j;
                    end
                end
                
                // Write new data into cache if writing
                if (write) begin
                    data[index][lru_way][offset[OFFSET_BITS-1:2]] <= wdata;
                    dirty[index][lru_way] <= 1; // Mark as dirty
                end else begin
                    rdata <= data[index][lru_way][offset[OFFSET_BITS-1:2]];
                end
                
                tags[index][lru_way] <= tag;
                valid[index][lru_way] <= 1;
                
                // Update LRU for all ways in this set
                for (k = 0; k < NUM_WAYS; k = k + 1) begin
                    if (k != lru_way) lru[index][k] <= 1; // Mark all others as less recently used
                    else lru[index][k] <= 0; // Mark this way as most recently used
                end
            end
        end
    end
endmodule

