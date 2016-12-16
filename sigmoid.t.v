`include "sigmoid.v"

module test_sigmoid();

reg clk=0;
reg rst_n;
reg [31:0] x;
reg start;

wire [31:0] y;
wire done;

always begin
	#10
	clk = !clk;
end

initial begin
	rst_n = 1'b0;
	@(negedge clk);
	x = 32'h0;
	start = 1'b1;
	@(negedge clk);
	start = 1'b0;
	rst_n = 1'b1;
	#5000;
	$display("%H", y);
	$finish;
end

endmodule
