#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include "config.h"
#include "array.h"

#define MAXBUF 1024

int main(int argc, char **argv)
{
	char in[MAXBUF];
	ssize_t len;

	Array arr;
	if(array_create(&arr) != 0) {
		fprintf(stderr, "could not allocate array");
		exit(-1);
	}

	while((len = read(0, in, sizeof(in))) > 0) {
		in[len] = '\0';
		len++;
		if(array_push(&arr, in, len) != 0) {
			fprintf(stderr, "could not add item to array");
			exit(-1);
		}
	}
	for(int i = 0; i < arr.index; i++) {
		char *t = (char*)malloc(MAXBUF*sizeof(char));
		if(array_at(&arr, t, i) != 0) {
			fprintf(stderr, "could not retreive item from array");
			exit(-1);
		}
		if(t == NULL) {
			fprintf(stderr, "item not popped from array");
			exit(-1);
		}
		printf("%s", t);

		free(t);
	}
	array_destroy(&arr);
	exit(0);
}
