`ifndef __NET_V__
`define __NET_V__

`include "sigmoid.v"
`include "matmul.v"
`include "add_float.v"


/// vectorized float addition

module add_float_v
#(parameter S=32, N=1)
(
	input rst_n,
	input clk,
	input start,
	input [S*N-1:0] a,
	input [S*N-1:0] b,
	output [S*N-1:0] o,
	output done
);

wire nan, overflow, underflow, zero; // don't care

wire [N-1:0] done_elem;

genvar i;
generate
for(i=0;i<N;i=i+1) begin
	add_float #(.FLOAT_WIDTH(S)) add(rst_n, clk, start, 1'b0, a[(i+1)*S-1: i*S], b[(i+1)*S-1:i*S], o[(i+1)*S-1:i*S], nan, overflow, underflow, zero, done_elem[i]);
end
endgenerate

assign done = &done_elem; // done only when all done

endmodule

module net
#(
	parameter I = 784,
	parameter O = 10,
	parameter D = 1 // depth of array
)
(
	input clk,
	input rst_n,
	input start,
	input [I*32-1:0] x,
	output [O*32-1:0] y,
	output done
);

reg [2:0] stage = 0;

wire start_1;
wire start_2;

wire done_1;
wire done_2;

//reg [32*H*I-1:0] w_1; // H x I, I --> H
//reg [32*O*H-1:0] w_2; // O x H, H --> O
//
//reg [32*H*1-1:0] b_1;
//reg [32*O*1-1:0] b_2;
//
//wire [32*H*1-1:0] o_1;
//wire [32*O*1-1:0] o_2;
//
//assign start_1 = start;
//matmul #(.S(32), .W(1), .H(H), .C(I)) m_1(rst_n, clk, start_1, w_1, x, o_1, done_1);
//assign start_2 = done_1;
//matmul #(.S(32), .W(1), .H(O), .C(H)) m_2(rst_n, clk, start_2, w_2, o_1, o_2, done_2);
//assign done = done_2;

reg [32*O*I-1:0] W=0;
reg [32*O-1:0] b=0;

wire [32*O-1:0] o_1;
wire [32*O-1:0] o_2;

wire mul_start;
wire add_start;
wire sig_start;

wire mul_done;
wire add_done;
wire sig_done;

assign mul_start = (stage == 0);
assign add_start = (stage == 2);
assign sig_start = (stage == 4);

always @(posedge clk) begin
	if(start) begin
		stage = 0;
	end else begin
		case(stage)
			0: begin
				stage = 1;
			end
			1: begin
				if(mul_done) begin
					stage = 3;
				end
			end
			2: begin
				stage = 3;
			end
			3: begin
				if(add_done) begin
					stage = 2;
				end
			end
			4: begin
				stage = 5;
			end
			5: begin

			end
			default: begin

			end
		endcase
	end
end

matmul #(.S(32), .W(1), .H(O), .C(I)) m(rst_n, clk, mul_start, W, x, o_1, mul_done);
add_float_v #(.S(32), .N(O)) add(rst_n, clk, add_start, o_1, b, o_2, add_done); // o_1 -(+b)-> o_2
sigmoid #(.S(32), .N(O)) sig(clk, rst_n, o_2, sig_start, y, sig_done); //o_2 -(sig())-> y
assign done = sig_done;

//genvar i;
//generate
//
//for(i=0; i<D;i=i+1) begin
//	initial begin
//		// initialize weight elem.
//		matmul #(.S(32) .W()m(rst_n, clk, start_1, w_1, x, o_1, done_1); // matrix mult.
//		sigmoid s(clk, rst_n, o_1, start_2, o_2, done_2); // activation
//	end
//end
//if(i == 0) begin
	//	matmul m(rst_n, clk, start_1, w_1, x, o_1, done_1); // matrix mult.
	//	sigmoid s(clk, rst_n, o_1, start_2, o_2, done_2); // activation
	//end
	//// (... add bias)
	//endgenerate
	//
	//initial begin
	//	// $loadmemh(w_1, "");
	//	// load weights and biases
	//end

	endmodule
`endif
