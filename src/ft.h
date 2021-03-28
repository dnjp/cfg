#ifndef FT_H
#define FT_H

#include <string.h>

#define EXT_MAX 50

typedef struct {
	char *comment;
	char *extensions[EXT_MAX];
} FileType;

char * ft_ext(char *filename);
int ft_parse(char *filename, FileType filetypes[], int len);

#endif
