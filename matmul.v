`include "mul_float.v"

`include "add_float.v"

`define IDX(i,j,h,w) (h*w - (i*w+j) - 1)
`define ELEM(m,i,j,h,w,s) m[s*(1+`IDX(i,j,h,w))-1:s*`IDX(i,j,h,w)]

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
	input [S*H*W-1:0] o
);

// stage : multiplication -> accumulation

reg [1:0] stage;

always@(posedge clk or negedge rst_n) begin
	stage <= 0;
end

always @(posedge stage_done) begin
	stage <= stage + 1;
end

wire nan;
wire overflow;
wire underflow;
wire zero;
wire done;
wire stage_done;

generate
genvar i,j,k;

for(i=0; i<H; i=i+1) begin: row
	for(j=0; j<W; j=j+1) begin: col

		wire [S*C-1:0] o_tmp; // store multiplication results
		wire [C-1:0] done_tmp;

		wire add_start = &done_tmp;

		// instantiate modules
		
		// multiply
		for(k=0; k<C; k=k+1) begin
			mul_float #(.FLOAT_WIDTH(S)) mul(rst_n, clk, start, `ELEM(a,i,k,H,C,S), `ELEM(b,k,j,C,W,S), `ELEM(o_tmp,0,k,1,C,S), nan, overflow, underflow, zero, done_tmp[k]);
		end

		// accumulate
		for(k=0; k<C; k=k+1) begin
			if (k == 0) begin

			end
			// here, 1'b0 == add, 1'b1 == sub
			add_float #(.FLOAT_WIDTH(S)) add(rst_n, clk, start, 1'b0, o_tmp_2, o_tmp[(k+1)*S-1:k*S], o_tmp[(k+2)*S-1:(k+1)*S], nan, overflow, underflow, zero, done_2);
		end

		always @(posedge clk) begin
			//assign stage_done = &done_tmp;
		end


	end
end

endgenerate

endmodule


module test_mul();

reg rst_n;
reg clk=0;
reg start;

reg [31:0] op1;
reg [31:0] op2;

wire [31:0] out;
wire nan;
wire overflow;
wire underflow;
wire zero;
wire done;

mul_float #(.FLOAT_WIDTH(32)) dut(
	//inputs
	.rst_n(rst_n), 
	.clk(clk), 
	.start(start),
	.op1(op1), 
	.op2(op2),
	//outputs
	.out_reg(out),
	.nan_reg(nan),
	.overflow_reg(overflow),
	.underflow_reg(underflow),
	.zero_reg(zero),
	.done_reg(done)
);

always begin
	#10
	clk = !clk;
end

always @(posedge done) begin
	$display("a b o");
	$display("%H %H %H", op1, op2, out);
end

initial begin
	rst_n = 1'b0;
	@(negedge clk);
	op1 = 32'h40a00000;
	op2 = 32'h40a00000;
	start = 1;
	@(negedge clk);
	start = 0;
	rst_n = 1'b1;
	#500;

	#500;
	$finish;
end


endmodule
