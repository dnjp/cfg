#ifndef LINE_H
#define LINE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "ft.h"

typedef struct {
	char *content;
	int fch;
	int scom;
	int ecom;
	int len;
} line ;

enum line_action { COMMENT, UNCOMMENT };

int line_annotate(line* l, struct filetype *ft);
int line_comment(line* l, struct filetype *ft);
int line_uncomment(line* l, struct filetype *ft);

int str_find(const char* str, const char* sub, int start, int len);
int str_sub(const char* from, char* to, int start, int end);

#endif
