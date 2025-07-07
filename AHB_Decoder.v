module AHB_Decoder (
    input  wire [15:0] haddr,
	input wire 		  bridge_ready,
    output reg        gpio_enable,
    output reg        data_mem_enable,
    output reg        bridge_enable,
    output reg        default_slave_enable,
    output reg [11:0]  gpio_addr,
    output reg [11:0]  data_mem_addr,
    output reg [11:0]  bridge_addr,
    output reg [11:0]  default_slave_addr
);

    always @(*) begin
            // Reset all enable signals and addresses
            gpio_enable              = 1'b0;
            data_mem_enable          = 1'b0;
            bridge_enable            = 1'b0;
            default_slave_enable     = 1'b0;
            gpio_addr                = 32'hA000_0000;
            data_mem_addr            = 32'hA000_0400;
            bridge_addr              = 32'hA000_0800;
            default_slave_addr       = 32'hA000_1000;
			
            // Update enable signals based on address
            if (haddr >= 32'hA000_0000 && haddr <= 32'hA000_03FF) begin
                gpio_enable           = 1'b1;
                gpio_addr             = haddr - 32'hA000_0000; // Compute address within GPIO
            end else begin
                gpio_enable  = 1'b0;
            end

            if (haddr >= 32'hA000_0800 && haddr <= 32'hA000_07FF && bridge_ready) begin
                bridge_enable            = 1'b1;
                bridge_addr              = haddr - 32'hA000_0800; // Compute address within APB range (UART)
            end else begin
                bridge_enable  = 1'b0;
            end
            if (haddr >= 32'hA000_0C00 && haddr <= 32'hA000_0FFF && bridge_ready) begin
                bridge_enable            = 1'b1;
                bridge_addr              = haddr - 32'hA000_0800; // Compute address within APB range (TIMER)
            end else begin
                bridge_enable  = 1'b0;
            end
            if (haddr >= 32'h1001_1100 && haddr <= 32'hA000_7FFC) begin
                data_mem_enable           = 1'b1;
                data_mem_addr             = haddr - 32'h1001_1100; // Compute address within Data Mem
				
            end else begin
                data_mem_enable  = 1'b0;
            end

            if (haddr >= 32'hA000_1000) begin
                default_slave_enable  = 1'b1;
                default_slave_addr    = haddr - 32'hA000_1000; // Compute address within Default Slave
            end else begin
                default_slave_enable  = 1'b0;
            end
    end

endmodule
