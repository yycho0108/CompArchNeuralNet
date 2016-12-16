`include "mul_float.v"

`include "add_float.v"

// TODO : check valid index
`define IDX(i,j,h,w) (h*w - (i*w+j) - 1)
`define ELEM(m,i,j,h,w,s) m[s*(1+`IDX(i,j,h,w))-1:s*`IDX(i,j,h,w)]


`define S_INIT (2'b00)
`define S_MUL (2'b01)
`define S_ADD (2'b10)

module accumulate
// accumulate elements of I and put it into O
#(parameter S=32, parameter C=2)
(
	input rst_n,
	input clk,
	input start,
	input [S*C-1:0] I, // input array
	output [S-1:0] O, // 1 floating point number
	output done
);

localparam X = 2 ** ($clog2(C)-1); // splitting line for recursive accumulation

reg stage = 0; //accum --> add
reg add_start;
reg add_rst_n;

always @(posedge clk or negedge rst_n) begin
	case(stage)
		0: begin
			add_rst_n = 1'b0;
			if(done_l && done_r) begin
				stage = 1; // go to next stage
				add_start = 1'b1;
			end
		end
		1: begin
			add_start = 1'b0;
			add_rst_n = 1'b1;
		end
		default: begin

		end
	endcase
end

wire nan, overflow, underflow, zero; // don't really care for now
wire done_l, done_r;
wire [C-1:0] wtf;

if(C == 1) begin
	// direct assignment
	assign O = I;
	assign done = 1'b1;
end else begin
	wire [S-1:0] o_l;
	wire [S-1:0] o_r;

	accumulate #(.S(S), .C(C-X)) ac_l(rst_n, clk, start, I[S*C-1:S*X], o_l, done_l); // accumulate left side
	accumulate #(.S(S), .C(X)) ac_r(rst_n, clk,  start, I[S*X-1:0], o_r, done_r); // accumulate right side

	add_float #(.FLOAT_WIDTH(S)) add(add_rst_n, clk, add_start, 1'b0, o_l, o_r, O, nan, overflow, underflow, zero, done);
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

// stage : multiplication -> accumulation

reg [1:0] stage;
reg stage_done;

wire nan;
wire overflow;
wire underflow;
wire zero;

assign done = 1'b1;

always@(posedge clk or negedge rst_n) begin
	stage <= 0;
end

always @(posedge clk) begin
	if(stage_done) begin
		stage <= stage + 1;
		stage_done <= 1'b0;
		// reset stage_done
	end
end

genvar i,j,k;
integer l;

generate
wire add_start;

assign mul_start = start;
assign add_start = stage_done & (stage == `S_MUL);

for(i=0; i<H; i=i+1) begin: row
	for(j=0; j<W; j=j+1) begin: col

		//case(stage)
		//	default:
		//endcase

		wire [S*C-1:0] o_tmp; // store multiplication results
		wire [S-1:0] o_tmp_2;
		wire [C-1:0] done_tmp;

		wire add_start = &done_tmp; // triggered when all multiplications are over for this element

		// instantiate modules
		
		// multiply
		for(k=0; k<C; k=k+1) begin : mul
			mul_float #(.FLOAT_WIDTH(S)) mul(rst_n, clk, mul_start, `ELEM(a,i,k,H,C,S), `ELEM(b,k,j,C,W,S), `ELEM(o_tmp,0,k,1,C,S), nan, overflow, underflow, zero, done_tmp[k]);
			// -->outputs stored to C-length array o_tmp
		end

		// accumulate
		wire accum_done;
		accumulate #(.S(32), .C(C)) acc(rst_n, clk, add_start, o_tmp, `ELEM(o,i,j,H,W,S), accum_done);

		//always @(posedge add_start) begin
		//end

		// accumulate
		//for(k=C-1; k>0; k=k/2) begin
		//	//if (k == 0) begin

		//	//end
		//	// here, 1'b0 == add, 1'b1 == sub
		//	add_float #(.FLOAT_WIDTH(S)) add(rst_n, clk, add_start, 1'b0, o_tmp_2, o_tmp[(k+1)*S-1:k*S], o_tmp[(k+2)*S-1:(k+1)*S], nan, overflow, underflow, zero, done_2);
		//end

		always @(posedge clk) begin
			//assign stage_done = &done_tmp;
		end


	end
end

endgenerate

endmodule

