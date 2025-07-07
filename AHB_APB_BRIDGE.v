module AHB_APB_BRIDGE(
	input clk,rst,
	input [11:0] haddr,
	input bridge_enable,
	input write_enable,
	
	/// outputs
	output reg [11:0] uart_addr,
	output reg [11:0] timer_addr,
	output reg uart_enable,
	output reg timer_enable,
	output reg penable,
	output reg ready
	
);
	reg we_access_phase ;
	reg wait_for_access_phase ;
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			we_access_phase<='b0;
			
		end
		else if(wait_for_access_phase) begin
			we_access_phase<=1'b1;
		end
	end
	
	
	always@(*)
	begin
		uart_addr    = 32'hA000_0800;
		timer_addr   = 32'hA000_0A00;
		uart_enable  = 1'b0;
		timer_enable = 1'b0;
		penable      = 1'b1;
		wait_for_access_phase = 1'b0;
		ready = 1'b1;
		
		if(bridge_enable && ready) begin
			penable = 1'b0;
			
			if(write_enable) begin
				wait_for_access_phase = 1'b1;
				ready = 1'b0;
			end
			
			if( haddr>= 32'hA000_0800 && haddr<=32'hA000_09FF)
			begin
				uart_addr = haddr - 32'hA000_0800 ;
				uart_enable = 1'b1;
			end
			
			else if( haddr>= 32'hA000_0A00 && haddr<=32'hA000_0BFF)
			begin
				timer_addr = haddr - 32'hA000_0A00 ;
				timer_enable = 1'b1;
			end
		end
		
		else if(we_access_phase) begin 
			ready = 1'b1;
		end
	end


endmodule   