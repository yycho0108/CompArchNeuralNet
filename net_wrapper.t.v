`include "net_wrapper.v"

module test_net_wrapper();

reg clk = 0;
reg [3:0] sw;
reg [3:0] btn;
wire [3:0] led;

integer i;

net_wrapper wrap(clk, sw, btn, led);

always begin
	#10;
	clk=!clk;
end

initial begin
	#500;
	sw[0] = 1;
	sw[1] = 0;
	for(i=0; i<5; i=i+1) begin
		btn[0] = 1;
		@(negedge clk);
	end
	btn[0] = 0;
	@(posedge led[2]); // wait until led comes up... (indicating "done")
	$display("%b %b %d", led[0], led[1], $time);
	$finish;
end

endmodule
