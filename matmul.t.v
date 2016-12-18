`ifndef __MATMUL_T_V__
`define __MATMUL_T_V__

`include "matmul.v"

`define HEIGHT 4
`define WIDTH 1
`define COMMON 2


module test_matmul();

task print_mat;
	parameter height = 1;
	parameter width = 1;
	input [height*width*32-1:0] mat;
	integer i,j;
	begin
		$display("-----------------");
		for(i=0; i<height; i=i+1) begin
			for(j=0; j<width; j=j+1) begin
				//$write("%H ", `ELEM(mat, i, j, height, width, 32));
				$write("%H ", mat[height*width*32-1]);
			end
			$write("");
		end
	end

endtask

reg rst_n = 1'b0;
reg clk = 1'b0;
reg start = 1'b0;

reg [`HEIGHT*`COMMON*32-1:0] a; // A = H x C
reg [`COMMON*`WIDTH*32-1:0] b; // B = C x W

reg [31:0] data [0:7]; //dummy

wire [`HEIGHT*`WIDTH*32-1:0] o;

wire done;

matmul #(.S(32), .W(`WIDTH), .H(`HEIGHT), .C(`COMMON)) m(rst_n, clk, start, a, b, o, done);

always begin
	#10
	clk = !clk;
end

always @(posedge done) begin
	$display("a b o");
	//print_mat (a);
	//print_mat(`COMMON, `WIDTH, b);
	//print_mat(`HEIGHT, `WIDTH, o);
	$display("%H %H %H", a, b, o);
end

initial begin
	$dumpfile("matmul.vcd");
	$dumpvars(0, test_matmul);

	rst_n = 1'b0;
	@(negedge clk);

	$readmemh("data/w1.txt", data);
	assign a = {data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7]};
	b = {32'h3f800000, 32'h3f800000};

	//a = {32'h3f8e5eea, 32'hbeb0ce44, 32'h3f1ba995, 32'h3f2418fc, 32'hbf364b07, 32'h3f945f07, 32'hbfdc0666, 32'h3ed5be0b, 32'hbeccd3d2, 32'h4011fa6b, 32'hc01163de, 32'h3e668c73 };
//b = {32'h3f5dc7de, 32'h3fb18dc7, 32'hbf842b78, 32'h3e9dcabb, 32'hbeb7666c, 32'h3e99c756, 32'hbf8e9161, 32'hbea4892c, 32'h3d425861, 32'h3f9f40d8, 32'h3f5847eb, 32'hbfc3d228, 32'h400e584d, 32'h3ec9113c, 32'hbbd2492e, 32'h3ef21373, 32'hbf3ff53d, 32'h3f7b0d8d };

	start = 1'b1;
	@(negedge clk);
	start = 1'b0;
	rst_n = 1'b1;
	#500;

	//rst_n = 1'b0;
	//@(negedge clk);

	//a = {32'hbf4ac269, 32'h40a00000, 32'h40a00000, 32'h40a00000};
	//b = {32'h40a00000, 32'h40a00000, 32'h40a00000, 32'h40a00000};

	//start = 1'b1;
	//@(negedge clk);
	//start = 1'b0;
	//rst_n = 1'b1;
	//#500;
	$finish;
end

endmodule

`endif
