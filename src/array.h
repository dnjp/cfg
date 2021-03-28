#ifndef ARRAY_H
#define ARRAY_H

#include <stdlib.h>
#include <string.h>

#define ARRAY_MAX 10

typedef struct {
	char *content;
	int fch;
} Line;

typedef struct {
	Line **lines;
	int index;
	int maxsize;
} Array;

int array_create(Array* arr);
int array_push(Array* arr, const char* item, int len);
int array_pop(Array* arr, char* target);
int array_at(Array* arr, char* target, int index);
void array_destroy(Array*);

#endif
