`ifndef __SIGMOID_V__
`define __SIGMOID_V__

`include "div_float.v"
`include "mul_float.v"
`include "add_float.v"
`define GET(v,e,s) v[(e+1)*s-1:e*s]

module sigmoid
#(parameter S=32, parameter N=2)
(
	input clk,
	input rst_n,
	input start,
	input [S*N-1:0] x,
	output [S*N-1:0] y,
	output done
);

// implements fast sigmoid, x / (1 + abs(x))

// x -> abs(x) -> 1.0 + % -> x/% -> 1 + % -> 0.5 * %
reg [3:0] stage = 0; // up to 8
wire [31:0] one = 32'h3f800000;
wire [31:0] half = 32'h3f000000;

wire [S*N-1:0] opax; // one plus abs x
wire [S*N-1:0] xdo; // x div. opax
wire [S*N-1:0] hpx; // half plus xdo

wire [3:0] stage_done;

wire add_start = (stage == 0);
wire div_start = (stage == 2);
wire add_start_2 = (stage == 4);
wire mul_start = (stage == 6);

wire add_rst_n = (stage != 0);
wire div_rst_n = (stage != 2); //negedge right before stage == 2
wire add_rst_n_2 = (stage != 4);
wire mul_rst_n = (stage != 6);

wire nan, zero, overflow, underflow,  divzero;

assign done = (stage == 8);

always @(negedge clk) begin
	if(start)
		stage = 0;
end

always @(posedge clk) begin
	if(start)
		stage = 0;
	else begin
		case(stage)
			0: begin
				if(!start)
					stage = stage + 1;
			end
			1: begin
				if(stage_done[0]) begin
					stage = stage + 1;	
				end
			end
			2: begin
				stage = stage + 1;
			end
			3: begin
				if(stage_done[1]) begin
					stage = stage+1;
				end
			end
			4: begin
				stage = stage + 1;
			end
			5: begin
				if(stage_done[2]) begin
					stage = stage + 1;
				end
			end
			6: begin
				stage = stage + 1;
			end
			7: begin
				if(stage_done[3]) begin
					stage = stage + 1;
				end
			end
			8: begin

			end
			default: begin

			end
		endcase
	end
end

// TODO : change start/done signals
generate
genvar i;
for(i=0; i<N; i=i+1) begin : each
	wire [S-1:0] absx = {1'b0, x[S*(i+1)-2:S*i]};
	add_float #(.FLOAT_WIDTH(S)) a1(add_rst_n, clk, add_start, 1'b0, absx, one, `GET(opax,i,S), nan, overflow, underflow, zero, stage_done[0]); // abs(x) + 1
	div_float #(.FLOAT_WIDTH(S)) d1(div_rst_n, clk, div_start, `GET(x,i,S), `GET(opax,i,S), `GET(xdo,i,S), divzero, nan, overflow, underflow, zero, stage_done[1]); // x / (abs(x)+1)
	add_float #(.FLOAT_WIDTH(S)) a2(add_rst_n_2, clk, add_start_2, 1'b0, `GET(xdo,i,S), one, `GET(hpx,i,S), nan, overflow, underflow, zero, stage_done[2]);
	mul_float #(.FLOAT_WIDTH(S)) mul(mul_rst_n, clk, mul_start, `GET(hpx,i,S), half, `GET(y,i,S), nan, overflow, underflow, zero, stage_done[3]);
end
endgenerate

endmodule
`endif
