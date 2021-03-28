#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "array.h"
#include "config.h"
#include "ft.h"

#define MAXBUF 1024

int get_filename(int argc, char **argv, char *filename)
{
	int opt;
	while((opt = getopt(argc, argv, ":f:")) != -1) { 
		switch(opt) { 
			case 'f': 
				strcpy(filename, optarg); 
				return 0;
		} 
	} 
	return -1;
}

int main(int argc, char **argv)
{
	Array arr;
	bool should_comment;
	char in[MAXBUF];
	char *filename;
	int ft_len;
	int ft_idx;
	int lines;
	int fch;
	ssize_t in_len;

	fch = 0;
	filename = (char*)malloc(MAXBUF*sizeof(char));
	ft_len = sizeof(FileTypes)/sizeof(FileType);
	lines = 0;
	should_comment = false;
	
	if(get_filename(argc, argv, filename) < 0 || filename == NULL) {
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
			lines++;
			while(t[fch] != '\0') {
				if(t[fch] == ' ' || t[fch] == '\t') {
					fch++;
					continue;
				}
				break;
			}
			if(array_push(&arr, t, in_len) != 0) {
				fprintf(stderr, "could not add item to array");
				exit(-1);
			}
			t = strtok(NULL, "\n");
		}
	}
	for(int i = 0; i < arr.index; i++) {
		Line *line = (Line*)malloc(sizeof(Line));
		if(array_at(&arr, line, i) != 0) {
			fprintf(stderr, "could not retreive item from array");
			exit(-1);
		}
		if(line == NULL) {
			fprintf(stderr, "item not popped from array");
			exit(-1);
		}
		printf("%s\n", line->content);
		free(line);
	}
	array_destroy(&arr);
	exit(0);
}
