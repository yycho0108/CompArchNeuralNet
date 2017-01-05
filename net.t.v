`ifndef __NET_T_V__
`define __NET_T_V__
`include "net.v"

`define INPUT 2
`define HIDDEN 4
`define OUTPUT 1

module test_net();

task test_xor;
	input [31:0] a;
	input [31:0] b;
	begin
		rst_n = 1'b0;
		#100
		@(negedge clk);
		x = {a,b};
		start = 1'b1;
		@(negedge clk);
		rst_n = 1'b1;
		start = 1'b0;
		@(posedge done);
	end
endtask


reg clk = 0;
always begin
	#10
	clk = !clk;
end

reg rst_n;
reg start;

reg [32*`INPUT*1-1:0] x;
wire [32*`OUTPUT*1-1:0] y;

wire [31:0] zero = 32'h00000000;
wire [31:0] one  = 32'h3f800000; 

wire done;

net #(.I(`INPUT), .O(`OUTPUT), .H(`HIDDEN), .D(1)) n(clk, rst_n, start, x, y, done);

always @(posedge done) begin
	$display("%H ^ %H = %H", x[31:0], x[63:32], y);
end

initial begin
	$dumpfile("net.vcd");
	$dumpvars(0, test_net);
	#500;
	test_xor(zero,zero); // --> 0
	#500;
	test_xor(zero,one); // --> 1
	#500;
	test_xor(one,zero); // --> 1
	#500;
	test_xor(one,one); // --> 0
	#500;
	$finish;
end

endmodule

`endif
