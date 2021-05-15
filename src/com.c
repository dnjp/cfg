#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "array.h"
#include "line.h"
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
	array arr;
	struct filetype *ft;
	bool touch;
	enum line_action act;
	char in[MAXBUF];
	char *filename;
	int ft_len;
	int ft_idx;
	int lines;
	ssize_t in_len;

	ft = NULL;
	filename = (char*)malloc(MAXBUF*sizeof(char));
	ft_len = sizeof(filetypes)/sizeof(struct filetype);
	touch = false;
	
	if(get_filename(argc, argv, filename) < 0 || filename == NULL) {
		fprintf(stderr, "filename must be provided with -f flag");
		exit(-1);
	}
	if(array_create(&arr) != 0) {
		fprintf(stderr, "could not allocate array");
		exit(-1);
	}
	if((ft_idx = ft_parse(filename, filetypes, ft_len)) >= 0) {
		touch = true;
		ft = &filetypes[ft_idx];
	}
	while((in_len = read(0, in, sizeof(in))) > 0) {
		in[in_len] = '\0';
		in_len++;
		char *t = strtok(in, "\n");
		while(t != NULL) {
			if(array_push(&arr, ft, t, in_len) != 0) {
				fprintf(stderr, "could not add item to array");
				exit(-1);
			}
			t = strtok(NULL, "\n");
		}
	}
	if(arr.comlines > (arr.index - arr.comlines)) {
		act = UNCOMMENT;
	} else {
		act = COMMENT;
	}
	for(int i = 0; i < arr.index; i++) {
		line *l = (line*)malloc(sizeof(line));
		if(array_at(&arr, l, i) != 0) {
			fprintf(stderr, "could not retreive item from array");
			exit(-1);
		}
		if(l == NULL) {
			fprintf(stderr, "item not popped from array");
			exit(-1);
		}
		if(touch) {
			switch(act) {
			case COMMENT:
				line_comment(l, ft);
				break;
			case UNCOMMENT:
				line_uncomment(l, ft);
				break;
			}
		}
		printf("%s\n", l->content);
		free(l);
	}
	array_destroy(&arr);
	exit(0);
}
