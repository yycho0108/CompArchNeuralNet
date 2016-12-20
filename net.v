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
for(i=0;i<N;i=i+1) begin: add_elem
	add_float #(.FLOAT_WIDTH(S)) add(rst_n, clk, start, 1'b0, a[(i+1)*S-1: i*S], b[(i+1)*S-1:i*S], o[(i+1)*S-1:i*S], nan, overflow, underflow, zero, done_elem[i]);
end
endgenerate

assign done = &done_elem; // done only when all done

endmodule


module layer
#(parameter S=32, I=1, O=1)
(
	input clk,
	input rst_n,
	input start,
	input [I*S-1:0] x,
	output [O*S-1:0] y,
	output done
);

reg [2:0] stage = 0;

reg [S-1:0] _W[0:O*I-1];
reg [S-1:0] _b[0:O-1];

wire [S*O*I-1:0] W;
wire [S*O-1:0] b;

// unpack
genvar i,o;
generate
for(o=0; o<O; o=o+1) begin
	assign `ELEM(b,o,0,O,1,S) = _b[o];
	//assign b[S*(o+1)-1:S*o] = _b[O-1-o]; // load backwards.
	for(i=0; i<I; i=i+1) begin
		assign `ELEM(W,o,i,O,I,S) = _W[o*I+i]; //m,i,j,h,w,s
	end
end


endgenerate

wire [S*O-1:0] o_1;
wire [S*O-1:0] o_2;

wire mul_start;
wire add_start;
wire sig_start;

wire mul_done;
wire add_done;
wire sig_done;

assign mul_start = (stage == 0);
assign add_start = (stage == 2);
assign sig_start = (stage == 4);

wire mul_rst_n = rst_n;
wire add_rst_n = (stage != 2);
wire sig_rst_n = (stage != 4);

assign done = (stage == 6);

always @(negedge clk) begin
	if(start) begin
		stage = 0;
	end 
end

always @(posedge clk) begin
	case(stage)
		0: begin
			stage = 1;
		end
		1: begin
			if(mul_done) begin
				stage = stage + 1;
			end
		end
		2: begin
			//$display("I : %H", x);
			//$display("O : %H", o_1);
			stage = 3;
		end
		3: begin
			if(add_done) begin
				//$display("B : %H", b);
				//$display("O_2 : %H", o_2);
				stage = stage + 1;
			end
		end
		4: begin
			stage = 5;
		end
		5: begin
			if(sig_done) begin
				//$display(".>Y : %H", y);
				stage = stage + 1;
			end
		end
		6: begin
			//stay at 6
		end
		default: begin

		end
	endcase
end

matmul #(.S(S), .W(1), .H(O), .C(I)) m(mul_rst_n, clk, mul_start, W, x, o_1, mul_done);
add_float_v #(.S(S), .N(O)) add(add_rst_n, clk, add_start, o_1, b, o_2, add_done); // o_1 -(+b)-> o_2
sigmoid #(.S(S), .N(O)) sig(clk, sig_rst_n, sig_start, o_2,  y, sig_done); //o_2 -(sig())-> y

endmodule


module net
#(
	parameter I = 784,
	parameter O = 10,
	parameter H = 75,
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

localparam S = 32;

reg [2:0] stage = 0;

wire [H*32-1:0] o_1; // intermediate unit for hidden layer
wire done_1, done_2;

layer #(.S(S), .I(I), .O(H)) l_1(clk, l_1_rst_n, start_1, x, o_1, done_1);
layer #(.S(S), .I(H), .O(O)) l_2(clk, l_2_rst_n, start_2, o_1, y, done_2);

initial begin
	$readmemh("data/w1.txt", l_1._W);
	$readmemh("data/b1.txt", l_1._b);
	$readmemh("data/w2.txt", l_2._W);
	$readmemh("data/b2.txt", l_2._b);
end

wire l_1_rst_n = !start_1;
wire l_2_rst_n = !start_2;

wire start_1 = (stage == 0);
wire start_2 = (stage == 2);

assign done = (stage == 4);

always @(posedge clk) begin
	if(start) begin
		stage = 0;
	end else begin

	case(stage)
		0: begin
			stage = stage + 1;
		end
		1: begin
			if(done_1)
				stage = stage + 1;
		end
		2: begin
			stage = stage + 1;
		end
		3: begin
			if(done_2)
				stage = stage + 1;
		end
		4: begin

		end
	endcase
end
end

endmodule

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


`endif
