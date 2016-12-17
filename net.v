`include "sigmoid.v"
`include "matmul.v"
`include "add_float.v"

module net
#(
	parameter T = 3
	parameter [7:0] topology [T-1:0] = {784,75,10}
)
(
	input [N-1:0] x,
	output [M-1:0] y
);

matmul m1(rst_n, clk, start_1, w_1, x, o_1, done_1);
sigmoid s1(clk, rst_n, o_1, start_2, o_2, done_2);
//matmul m2(rst_n, clk, start_1, w_1, x, o_1, done_1);
//sigmoid s1(clk, rst_n, o_1, start_2, o_2, done_2);

initial begin
	// load weights and biases
end

endmodule
