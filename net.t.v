`ifndef __NET_T_V__
`define __NET_T_V__
`include "net.v"

module test_net();

reg clk = 0;
always begin
	#10
	clk = !clk;
end

reg rst_n;
reg start;

reg [32*784*1-1:0] x;
wire [32*10*1-1:0] y;

wire done;

net #(.I(784), .O(10), .D(1)) n(clk, rst_n, start, x, y, done);

always @(posedge done) begin
	$display("%H", y);
end

initial begin
	$dumpfile("net.vcd");
	$dumpvars(0, test_net);
	rst_n = 1'b0;
	@(negedge clk);
	x = 0;
	start = 1'b1;
	@(negedge clk);
	rst_n = 1'b1;
	start = 1'b0;
	@(posedge done);
	#100;
	$finish;
end

endmodule

`endif
