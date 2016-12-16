#include <random>
#include <string>
#include <sstream>
#include <iostream>

#define ARMA_DONT_USE_CXX11
#include <armadillo>

std::string f2h(const float& f){
	char str[9] = {};
	snprintf(str, 9, "%x", *(unsigned int*)(&f));
	return str;
}

float h2f(const std::string& h){
	unsigned int x;
	std::stringstream ss;
	ss << std::hex << h;
	ss >> x;
	return reinterpret_cast<float&>(x);
}
void print_hex(char name, const arma::mat& m){
	std::cout << name << std::endl;
	for(unsigned int i=0; i<m.n_rows; ++i){
		for(unsigned int j=0; j<m.n_cols; ++j){
			std::cout << f2h(m(i,j)) << ' ';
			// verification std::cout << '[' << h2f(f2h(m(i,j))) << ']';
		}
		std::cout << std::endl;
	}
}

int main(){
	int w = 2;
	int h = 3;
	int c = 1;

	//std::cout << f2h(2.0) << std::endl;
	//std::cout << h2f(f2h(2.0)) << std::endl;

	arma::mat a = arma::randn<arma::mat>(h,c);
	arma::mat b = arma::randn<arma::mat>(c,w);
	arma::mat o = a*b;

	std::cout << a << std::endl;
	std::cout << b << std::endl;
	std::cout << o << std::endl;


	print_hex('a', a);
	print_hex('b', b);
	print_hex('o', a*b);
}
