`ifndef __SIGMOID_T_V__
`define __SIGMOID_T_V__
`include "sigmoid.v"

`define NUM 2
module test_sigmoid();

reg clk=0;
reg rst_n;
reg start;
reg [32*`NUM-1:0] x;
wire [32*`NUM-1:0] y;
wire done;

sigmoid #(.S(32), .N(`NUM)) s(clk,rst_n,start,x,y,done);

always begin
	#10
	clk = !clk;
end

always @(posedge done) begin
	$display("%H --> %H", x, y);
end

initial begin
	$dumpfile("sigmoid.vcd");
	$dumpvars(0, test_sigmoid);

	rst_n = 1'b0;
	@(negedge clk);
	x = {32'hc0733333,32'h40a00000};
	start = 1'b1;
	@(negedge clk);
	start = 1'b0;
	rst_n = 1'b1;
	@(posedge done);
	#100;

	rst_n = 1'b0;
	@(negedge clk);
	x = {32'h0, 32'h40a00000};
	start = 1'b1;
	@(negedge clk);
	start = 1'b0;
	rst_n = 1'b1;
	@(posedge done);
	#100;

	$finish;
end

endmodule
`endif
