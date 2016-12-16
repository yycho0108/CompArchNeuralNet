all : mul_float.o comp_float.o matmul.o sigmoid.o

mul_float.o : mul_float.v mul_float.t.v
	iverilog mul_float.t.v -o mul_float.o

comp_float.o : comp_float.v comp_float.t.v
	iverilog comp_float.t.v -o comp_float.o

matmul.o : matmul.v matmul.t.v
	iverilog matmul.t.v -o matmul.o

sigmoid.o : sigmoid.v sigmoid.t.v
	iverilog sigmoid.t.v -o sigmoid.o
