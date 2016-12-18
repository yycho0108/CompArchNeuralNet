`ifndef __COMP_FLOAT_T_V__
`define __COMP_FLOAT_T_V__
`include "comp_float.v"

module test_comp_float();

wire [2:0] flag;
reg [31:0] a;
reg [31:0] b;

comp_float cmp(flag, a,b);

initial begin
	a = 32'h3f800000;
	b = 32'h40000000;
	#500;
	$display("%H %H | %b", a, b, flag);

	a = 32'h40000000;
	b = 32'h3f800000;
	#500;
	$display("%H %H | %b", a, b, flag);

	a = 32'h40000000;
	b = 32'h40000000;
	#500;
	$display("%H %H | %b", a, b, flag);
end

endmodule
`endif
