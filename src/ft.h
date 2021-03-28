#ifndef FT_H
#define FT_H

#include <string.h>

#define EXT_MAX 50

struct filetype {
	char *comstart;
	char *comend;
	char *extensions[EXT_MAX];
};

char * ft_ext(char *filename);
int ft_parse(char *filename, struct filetype filetypes[], int len);

#endif
