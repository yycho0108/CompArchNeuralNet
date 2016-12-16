`include "div_float.v"
`include "add_float.v"
`include "mul_float.v"

module lerp
#(parameter S=32)
(
	input clk,
	input start,
	input rst_n,
	input [31:0] x1,
	input [31:0] x2,
	input [31:0] y1,
	input [31:0] y2,
	input [31:0] x,
	output [31:0] y,
	output done
);

// x --> (x-x1),(x2-x1),(y2-y1) --> (x-x1)/(x2-x1) -> (x-x1)/(x2-x1)*(y2-y1)
// --> + y1

reg [31:0] xsx1;
reg [31:0] x2sx1;
reg [31:0] y2sy1;
reg [31:0] dxx; // (x-x1)/(x2-x1)

reg [2:0] sub_done;
reg [1:0] div_done;

// Phase 1
add_float #(.FLOAT_WIDTH(S)) s1(rst_n, clk, start, 1'b1, x, x1, xsx1, nan, overflow, underflow, zero, sub_done[0]);
add_float #(.FLOAT_WIDTH(S)) s2(rst_n, clk, start, 1'b1, x2, x1, x2sx1, nan, overflow, underflow, zero, sub_done[1]);
add_float #(.FLOAT_WIDTH(S)) s3(rst_n, clk, start, 1'b1, y2, y1, y2sy1, nan, overflow, underflow, zero, sub_done[2]);

div_float #(.FLOAT_WIDTH(S)) d1(rst_n, clk, start, x1, `DELTA, dxx, zero, nan, overflow, underflow, zero_reg, div_done[0]);

// Phase 2
div_float #(.FLOAT_WIDTH(S)) d2(rst_n, clk, &sub_done, xsx1, x2sx1, zero, nan, overflow, underflow, zero_reg, div_done[1]);

mul_float #(.FLOAT_WIDTH(S)) m1(rst_n, clk, div_done[1], x
