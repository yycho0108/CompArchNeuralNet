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

// x -> abs(x) -> 1.0 + % -> x/% -> 1 + % -> 0.5 * %
reg [2:0] stage; // up to 8
wire [31:0] absx;
assign absx = {1'b0, x[S*N-2:0]};
wire [31:0] one = 32'h3f800000;
wire [31:0] half = 32'h3f000000;

wire [S*N-1:0] opax; // one plus abs x
wire [S*N-1:0] xdo; // x div. opax
wire [S*N-1:0] hpx; // half plus xdo

wire [3:0] stage_done;

wire add_start;
wire div_start;
wire add_start_2;
wire mul_start;

assign add_start = (stage == 0);
assign div_start = (stage == 2);
assign add_start_2 = (stage == 4);
assign mul_start = (stage == 6);

wire add_rst_n = (stage == 1);
wire div_rst_n = (stage == 3);
wire add_rst_n_2 = (stage == 5);
wire mul_rst_n = (stage == 7);

initial begin
	stage = 0;
end

always @(posedge clk) begin

	if(rst_n == 0 | start) begin
		stage = 0;
	end else begin

		case(stage)
			0: begin
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
				//if(stage_done[3]) begin
				//	stage = stage + 1;
				//end
			end
			default: begin

			end
		endcase
	end
end

// TODO : change start/done signals
add_float #(.FLOAT_WIDTH(S)) a1(add_rst_n, clk, add_start, 1'b0, absx, one, opax, nan, overflow, underflow, zero, stage_done[0]); // abs(x) + 1
div_float #(.FLOAT_WIDTH(S)) d1(div_rst_n, clk, div_start, x, opax, xdo, zero, nan, overflow, underflow, zero_reg, stage_done[1]); // x / (abs(x)+1)
add_float #(.FLOAT_WIDTH(S)) a2(rst_n, clk, add_start_2, 1'b0, xdo, one, hpx, nan, overflow, underflow, zero, stage_done[2]);
mul_float #(.FLOAT_WIDTH(S)) mul(mul_rst_n, clk, mul_start, hpx, half, y, nan, overflow, underflow, zero, stage_done[3]);

assign done = stage_done[3];
endmodule
