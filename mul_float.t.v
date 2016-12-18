`ifndef __MUL_FLOAT_T_V__
`define __MUL_FLOAT_T_V__
`include "mul_float.v"

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

	$dumpfile("mul_float.vcd");
    $dumpvars(0, test_mul);

	rst_n = 1'b0;
	@(negedge clk);
	op1 = 32'h40a00000;
	op2 = 32'h40a00000;
	start = 1;
	@(negedge clk);
	start = 0;
	rst_n = 1'b1;
	#500;
	$finish;
end


endmodule
`endif
