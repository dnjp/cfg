#include "array.h"

/* 
 * array_create allocates memory for an array of size ARRAY_MAX and
 * initializes all properties.
 */
int array_create(Array *arr) {
	/* arr->items = (char**)calloc(ARRAY_MAX, sizeof(arr->items)); */
	arr->lines = (Line**)calloc(ARRAY_MAX, sizeof(arr->lines));
	if(arr->lines == NULL)
		return -1;
	arr->maxsize = ARRAY_MAX;
	arr->index = 0;
	return 0;
}

/* 
 * array_push adds item to the array, growing the maximum size of the
 * array if maxsize is reached. each string element has memory allocated
 * for it and the new items contents are copied into the element. if all
 * operations complete successfully, the current index is incremented by 1.
 */
int array_push(Array *arr, const char* item, int len) {
	if(arr == NULL)
		return -1;
	if(arr->maxsize == 0)
		return -1;
	if(arr->index == arr->maxsize) {
		arr->maxsize = arr->maxsize*2;
		arr->lines = (Line**)realloc(arr->lines, arr->maxsize*sizeof(arr->lines));
	}
	Line *line = (Line*)malloc(sizeof(Line));
	line->content = (char*)malloc(len*sizeof(char));
	strcpy(line->content, item);
	arr->lines[arr->index] = line;
	arr->index++;
	return 0;
}

/*
 * array_at populates the target with the array element at the given
 * index if it exists, otherwise -1 is returned.
 */
int array_at(Array *arr, Line* target, int index) {
	if(arr == NULL)
		return -1;
	if(target == NULL)
		return -1;
	if(arr->index < index)
		return -1;
	Line *line = arr->lines[index];
	if(line == NULL)
		return -1;
	*target = *line;
	return 0;
}

/* array_destroy frees all of the contents of the array and cleans up. */
void array_destroy(Array *arr) {
	if(arr == NULL)
		return;
	for(int i = 0; i < arr->index; i++) {
		if(arr->lines[i] != NULL) {
			free(arr->lines[i]);
			arr->lines[i] = NULL;
		}
	}
}
