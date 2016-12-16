all: h2f.o f2h.o gen_data.o

h2f.o: h2f.cpp
	g++ h2f.cpp -o h2f.o

f2h.o: f2h.cpp
	g++ f2h.cpp -o f2h.o

gen_data.o : gen_data.cpp
	g++ -std=c++11 gen_data.cpp -L/usr/lib -larmadillo -o gen_data.o
