all : mul_float.o matmul.o

mul_float.o : mul_float.v mul_float.t.v
	iverilog mul_float.t.v -o mul_float.o

matmul.o : matmul.v matmul.t.v
	iverilog matmul.t.v -o matmul.o
