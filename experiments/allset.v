module allset();

reg [7:0] b;

initial begin
	b = 8'b00000000;
	$display("%b %b", b, &b);
	#50
	b = 8'b11110000;
	$display("%b %b", b, &b);
	#50
	b = 8'b11111111;
	$display("%b %b", b, &b);
	$finish;
end

endmodule
