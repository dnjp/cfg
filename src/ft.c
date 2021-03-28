#include "ft.h"

char *ft_ext(char *filename) {
	if(filename == NULL)
		return NULL;
	return strchr(filename, '.');
}

int ft_parse(char *filename, FileType filetypes[], int len) {
	char *ext = NULL;
	ext = ft_ext(filename);
	for(int i = 0; i < len; i++) {
		FileType cur = filetypes[i];
		int j = 0;
		while(cur.extensions[j] != NULL) {
			if(strcmp(ext, cur.extensions[j]) == 0) {
				return i;
			}
			j++;
		}
	}
	return -1;
}

