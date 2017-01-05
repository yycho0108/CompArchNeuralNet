all : mul_float.o add_float.o comp_float.o matmul.o sigmoid.o net.o net_wrapper.o

.PHONY: run

run: all
	@echo "===== -- mul_float -- ====="
	./mul_float.o
	@echo "===== -- add_float -- ====="
	./add_float.o
	@echo "===== -- comp_float -- ====="
	./comp_float.o
	@echo "===== -- matmul -- ====="
	./matmul.o
	@echo "===== -- sigmoid -- ====="
	./sigmoid.o
	@echo "===== -- net -- ====="
	./net.o
	@echo "===== -- net_wrapper -- ====="
	./net_wrapper.o

mul_float.o : mul_float.v mul_float.t.v
	iverilog mul_float.t.v -o mul_float.o

add_float.o : add_float.v add_float.t.v
	iverilog add_float.t.v -o add_float.o

comp_float.o : comp_float.v comp_float.t.v
	iverilog comp_float.t.v -o comp_float.o

matmul.o : matmul.v matmul.t.v mul_float.v add_float.v
	iverilog matmul.t.v -o matmul.o

sigmoid.o : sigmoid.v sigmoid.t.v add_float.v mul_float.v div_float.v
	iverilog sigmoid.t.v -o sigmoid.o

net.o : net.v net.t.v sigmoid.o matmul.o
	time iverilog net.t.v -o net.o

net_wrapper.o : net_wrapper.v net_wrapper.t.v net.o
	iverilog net_wrapper.t.v -o net_wrapper.o
clean:
	rm *.o
