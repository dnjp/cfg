#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "array.h"
#include "config.h"
#include "ft.h"

#define MAXBUF 1024


int main(int argc, char **argv)
{
	char in[MAXBUF];
	ssize_t in_len;
	Array arr;
	int ft_len;
	int ft_idx;
	bool should_comment;
	int opt;
	char *filename;

	filename = NULL;
	should_comment = false;
	ft_len = sizeof(FileTypes)/sizeof(FileType);
	
	while((opt = getopt(argc, argv, ":f:")) != -1) 
	{ 
		switch(opt) 
		{ 
			case 'f': 
				filename = optarg; 
				break;
		} 
	} 
	if(filename == NULL) {
		fprintf(stderr, "filename must be provided with -f flag");
		exit(-1);
	}
	if(array_create(&arr) != 0) {
		fprintf(stderr, "could not allocate array");
		exit(-1);
	}
	if((ft_idx = ft_parse(filename, FileTypes, ft_len)) >= 0) {
		should_comment = true;
	} 
	while((in_len = read(0, in, sizeof(in))) > 0) {
		in[in_len] = '\0';
		in_len++;
		char *t = strtok(in, "\n");
		while(t != NULL) {
			if(array_push(&arr, t, in_len) != 0) {
				fprintf(stderr, "could not add item to array");
				exit(-1);
			}
			t = strtok(NULL, "\n");
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
		printf("%s\n", t);

		free(t);
	}
	array_destroy(&arr);
	exit(0);
}
