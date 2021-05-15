#ifndef array_H
#define array_H

#include <stdlib.h>
#include <string.h>
#include "ft.h"
#include "line.h"

#define array_MAX 10

typedef struct {
	line **lines;
	int index;
	int maxsize;
	int comlines;
} array;

int array_create(array* arr);
int array_push(array* arr, struct filetype *ft, const char* item, int len);
int array_at(array* arr, line* target, int index);
void array_destroy(array*);

#endif
