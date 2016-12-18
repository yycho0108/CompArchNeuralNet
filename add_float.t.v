`ifndef __ADD_FLOAT_T_V__
`define __ADD_FLOAT_T_V__
`include "add_float.v"

module test_add();


reg rst_n, clk=0, start;
reg [31:0] a, b;
wire [31:0] o;
wire nan, overflow, underflow, zero, done;

add_float #(.FLOAT_WIDTH(32)) add(rst_n, clk, start, 1'b0, a, b, o, nan, overflow, underflow, zero, done);

always begin
	#10
	clk = !clk;
end

always @(posedge done) begin
	$display("%H %H %H %d", a, b, o, $time);
end


initial begin
	$display("a b o");
	check(32'h40a00000, 32'h00000000);
	#500
	check(32'h00000000, 32'h40a00000);
	#500
	$finish;
end

task check;
	input [31:0] lhs, rhs;
	begin
		rst_n = 1'b0;
		@(negedge clk);
		a = lhs; 
		b = rhs;
		start = 1;
		@(negedge clk);
		start = 0;
		rst_n = 1'b1;
	end
endtask

endmodule
`endif
