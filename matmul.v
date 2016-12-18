`ifndef __MATMUL_V__
`define __MATMUL_V__
`include "mul_float.v"

`include "add_float.v"

// TODO : check valid index
`define IDX(i,j,h,w) (((h)*(w)-1) - ((i)*(w)+j)) // indexed somewhat unconventionally
`define ELEM(m,i,j,h,w,s) m[s*(1+`IDX(i,j,h,w))-1:s*`IDX(i,j,h,w)]


`define S_INIT (2'b00)
`define S_MUL (2'b01)
`define S_ADD (2'b10)

module accumulate
// accumulate elements of I and put it into O
//X =  splitting line for recursive accumulation
#(parameter S=32, C=2, X=2**($clog2(C)-1))
(
	input rst_n,
	input clk,
	input start,
	input [S*C-1:0] I, // input array
	output [S-1:0] O, // 1 floating point number
	output done
);

reg [1:0] stage = 0; //accum --> add
wire add_start = (stage == 1);
wire add_rst_n = (stage == 2);

always @(negedge clk) begin
	if(rst_n == 0 | start) begin
		stage <= 0;
	end 
end

always @(posedge clk) begin
	case(stage)
		0: begin
			// accum left, right
			if(done_l && done_r) begin
				stage <= stage+1;
			end
		end
		1: begin
			// add-start
			stage <= stage+1;
		end
		2: begin
			if(add_done) begin
				stage <= stage+1;
			end
		end
		3: begin

		end
		default: begin

		end
	endcase

end

wire nan, overflow, underflow, zero; // don't really care for now
wire done_l, done_r;
wire add_done;

if(C == 1) begin
	assign done = 1'b1;
	// direct assignment
	assign O = I;
end else begin
	wire [S-1:0] o_l;
	wire [S-1:0] o_r;

	accumulate #(.S(S), .C(C-X)) ac_l(rst_n, clk, start, I[S*C-1:S*X], o_l, done_l); // accumulate left side
	accumulate #(.S(S), .C(X)) ac_r(rst_n, clk,  start, I[S*X-1:0], o_r, done_r); // accumulate right side
	add_float #(.FLOAT_WIDTH(S)) add(add_rst_n, clk, add_start, 1'b0, o_l, o_r, O, nan, overflow, underflow, zero, add_done);
	assign done = (stage == 3);
end
endmodule

module matmul // size = 32 bits, width, height, common
#(parameter S=32, W=2, H=2, C=2)
(
	// H x W
	// 2x5 * 5x3 = 2x3
	// H*C * C*W = H*W
	// row major
	input rst_n,
		input clk,
		input start,

		input [S*H*C-1:0] a,
		input [S*C*W-1:0] b,
		output [S*H*W-1:0] o,
		output done
	);

	reg [2:0] stage = 0;

	wire mul_start = (stage == 0);
	wire accum_start = (stage == 2);
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
					stage = stage + 1;
				end
				1: begin
					if(&mult_all_done)
						stage = stage + 1;
				end
				2: begin
					stage = stage + 1;
				end
				3: begin
					if(&add_done)
						stage = stage + 1;
				end
				4: begin

				end

			endcase
		end
	end

	wire nan;
	wire overflow;
	wire underflow;
	wire zero;

	wire [H*W-1:0] add_done;
	wire [H*W-1:0] mult_all_done;

	genvar i,j,k;
	integer l;

	generate

	for(i=0; i<H; i=i+1) begin: row
		for(j=0; j<W; j=j+1) begin: col
			wire [S*C-1:0] o_tmp; // store multiplication results
			wire [C-1:0] mult_done;

			// multiply
			for(k=0; k<C; k=k+1) begin : mul
				mul_float #(.FLOAT_WIDTH(S)) mul(rst_n, clk, start, `ELEM(a,i,k,H,C,S), `ELEM(b,k,j,C,W,S), `ELEM(o_tmp,0,k,1,C,S), nan, overflow, underflow, zero, mult_done[k]);
				// -->outputs stored to C-length array o_tmp
				// debugging
				//always @(o_tmp) begin
				//	if(i == 0 && j == 1) begin
					//		$write("(%d, %d) * (%d,%d)", i, k, k, j);
					//		$write("%H * ", `ELEM(a,i,k,H,C,S));
					//		$write("%H = ", `ELEM(b,k,j,C,W,S));
					//		$write("%H", `ELEM(o_tmp,0,k,1,C,S));
					//	end
					//end
				end

				assign mult_all_done[i*W+j] = &mult_done;

				// accumulate
				accumulate #(.S(32), .C(C)) acc(rst_n, clk, accum_start, o_tmp, `ELEM(o,j,i,W,H,S), add_done[i*W+j]);
			end
		end

		endgenerate

		assign done = &add_done; // only done when all elements are completed

		endmodule
	`endif
