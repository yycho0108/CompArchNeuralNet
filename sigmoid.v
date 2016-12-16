`include "div_float.v"
`include "mul_float.v"
`include "add_float.v"

module sigmoid
#(parameter S=32, parameter N=1)
(
	input clk,
	input rst_n,
	input [S*N-1:0] x,
	input start,
	output [S*N-1:0] y,
	output done
);
// implements fast sigmoid, x / (1 + abs(x))


// x -> abs(x) -> 1.0 + % -> x/% -> 1 + % + 0.5 * %
reg [2:0] stage;
wire [31:0] absx;
assign absx = {1'b0, x[S*N-2:0]};
wire [31:0] one = 32'h3f800000;
wire [31:0] half = 32'h3f000000;

wire [S*N-1:0] opax; // one plus abs x
wire [S*N-1:0] xdo; // x div. opax

wire stage_done[3:0];

reg add_start;
reg div_start;
reg add_start_2;
reg mul_start;

initial begin
	stage = 0;
	add_start = 0;
	div_start = 0;
	add_start_2 = 0;
	mul_start = 0;
end

always @(posedge clk) begin
	case(stage)
		0: begin
			add_start = 1'b1;
			stage = stage + 1;
		end
		1: begin
			add_start = 1'b0;
			if(stage_done[0])
			   stage = stage + 1;	
		end
		2: begin
			div_start = 1'b1;
			stage = stage + 1;
		end
		3: begin
		end
		default: begin
		end
	endcase
end
// TODO : change start/done signals
add_float #(.FLOAT_WIDTH(S)) a1(rst_n, clk, start, 1'b0, absx, one, opax, nan, overflow, underflow, zero, stage_done[0]);
div_float #(.FLOAT_WIDTH(S)) d1(rst_n, clk, stage_done[0], x, opax, xdo, zero, nan, overflow, underflow, zero_reg, stage_done[1]);
add_float #(.FLOAT_WIDTH(S)) a2(rst_n, clk, stage_done[1], 1'b0, absx, one, opax, nan, overflow, underflow, zero, stage_done[2]);
mul_float #(.FLOAT_WIDTH(S)) mul(rst_n, clk, stage_done[2], xdo, half, y, nan, overflow, underflow, zero, stage_done[3]);

assign done = stage_done[3];
endmodule
