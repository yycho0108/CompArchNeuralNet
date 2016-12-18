`ifndef __ADD_FLOAT_T_V__
`define __ADD_FLOAT_T_V__
`include "add_float.v"

module test_add();

reg rst_n, clk=0, start;
reg [31:0] a, b;
wire [31:0] o;
wire nan, overflow, underflow, zero, done;

add_float #(.FLOAT_WIDTH(32)) add(rst_n, clk, start, 1'b0, a, b, o, nan, overflow, underflow, zero, done);

always begin
	#10
	clk = !clk;
end

always @(posedge done) begin
	$display("%H %H %H", a, b, o);
end

initial begin
	$display("a b o");

	rst_n = 1'b0;
	@(negedge clk);
	a = 32'h40a00000;
	b = 32'h40a00000;
	start = 1;
	@(negedge clk);
	start = 0;
	rst_n = 1'b1;
	#500;
	$finish;
end

endmodule
`endif
