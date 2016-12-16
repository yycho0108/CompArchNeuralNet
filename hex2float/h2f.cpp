#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <sstream>

void usage(){
	fprintf(stderr, "USAGE : h2f <hex>\n");
}

int main(int argc, char* argv[]){
	if(argc != 2){
		usage();
		return -1;
	}

	unsigned int x;
	std::stringstream ss;
	ss << std::hex << argv[1];
	ss >> x;
	float f = reinterpret_cast<float&>(x);
	printf("%f\n", f);
}
