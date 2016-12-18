`ifndef __COMP_FLOAT_V__
`define __COMP_FLOAT_V__
module comp_float(
	output [2:0] flag, 
	input [31:0] a,
	input [31:0] b
);

wire s1, s2;
wire [7:0] e1, e2;
wire [22:0] m1, m2;

assign {s1,e1,m1} = a;
assign {s2,e2,m2} = b;

wire [1:0] sign, exp, mag;                                   

assign sign= {s1,s2};

assign exp= (e1 > e2) ? 2'b10:
            (e2 > e1) ? 2'b01: 2'b00;

assign mag= (exp == 2'b00) ? ((m1 > m2) ? 2'b10:
                                (m2 > m1) ? 2'b01: 2'b00): 2'b11;
                                    
assign flag= (sign == 2'b00) ? ((exp == 2'b10) ? 3'b100:
                                (exp == 2'b01) ? 3'b001:
       				(mag == 2'b10) ? 3'b100:
				(mag == 2'b01) ? 3'b001:3'b010):
             (sign == 2'b11) ? ((exp == 2'b10) ? 3'b001:
                                (exp == 2'b01) ? 3'b100: 
                                (mag == 2'b10) ? 3'b001:
                                (mag == 2'b01) ? 3'b100:3'b010):
             (sign == 2'b10) ? 3'b100 : 3'b001;                    
endmodule
`endif
