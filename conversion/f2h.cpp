#include <cstdlib>
#include <cstdio>
#include <iostream>

void usage(){
	fprintf(stderr, "USAGE : f2h <a> <b>\n");
}

int main(int argc, char* argv[]){
	if(argc != 3){
		usage();
		return -1;
	}

	float a = std::atof(argv[1]);
	float b = std::atof(argv[2]);

	float c = a*b;

	printf("a : %x\n",*(unsigned int*)(&a)); 
	printf("b : %x\n",*(unsigned int*)(&b)); 
	printf("a*b : %x",*(unsigned int*)(&c)); 
}
