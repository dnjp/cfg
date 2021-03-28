#include <stdio.h>
#include "config.h"

#define MAXBUF 1024

int main(int argc, char **argv)
{
	char in[MAXBUF];
	ssize_t len;

	while((len = read(0, in, sizeof(in))) > 0) {
		in[len] = '\0';
		printf("%s", in);
	}

	return 0;
}
