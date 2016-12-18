`timescale 1ns / 1ps

`include "net.v"
`include "comp_float.v"
`include "input_conditioner.v"

module net_wrapper 
(
    input        clk,
    input  [3:0] sw,
    input  [3:0] btn,
    output [3:0] led
);

// sw[0],sw[1] are inputs to the XOR Classifier
// btn[0] triggers the computation
// led[0] indicates the output
// led[1] indicates true XOR output
// led[2] indicates that the calculation is done

reg [2:0] stage = 0; // idle, reset+load, start, progress

wire [31:0] one = 32'h3f800000; 
wire [31:0] zero = 32'h00000000; 
wire [31:0] half = 32'h3f000000;

wire [31:0] a = sw[0]? one:zero;
wire [31:0] b = sw[1]? one:zero;
wire [63:0] x = {a,b};
wire [31:0] y;

wire [2:0] flag;
wire rst_n = (stage != 1);
wire start = (stage == 1);
wire done;

wire btn_cnd; // conditioned button input
wire btn_posedge;
wire btn_negedge;

input_conditioner ic(clk, btn[0], btn_cnd, btn_posedge, btn_negedge);
net #(.I(2), .O(1), .H(4), .D(1)) n(clk, rst_n, start, x, y, done);
comp_float cmp(flag,y,half); // compare against 0.5

always @(posedge clk) begin
	case (stage)
		0: begin //idle
			if(btn_negedge)
				stage <= 1; // start
		end
		1: begin
			stage <= 2;
		end
		2: begin
			stage <= 3;
		end
		3: begin
			if(done)
				stage <= 4; // back to idle
		end
		4: begin

		end
	endcase

end

// outputs
assign led[0] = flag[2];
assign led[1] = sw[0] ^ sw[1];
assign led[2] = done;
//assign led[3:1] = n.stage;

endmodule
