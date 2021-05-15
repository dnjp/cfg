#include "array.h"

/* 
 * array_create allocates memory for an array of size array_MAX and
 * initializes all properties.
 */
int array_create(array *arr) {
	/* arr->items = (char**)calloc(array_MAX, sizeof(arr->items)); */
	arr->lines = (line**)calloc(array_MAX, sizeof(arr->lines));
	if(arr->lines == NULL)
		return -1;
	arr->maxsize = array_MAX;
	arr->index = 0;
	arr->comlines = 0;
	return 0;
}

/* 
 * array_push adds item to the array, growing the maximum size of the
 * array if maxsize is reached. each string element has memory allocated
 * for it and the new items contents are copied into the element. if all
 * operations complete successfully, the current index is incremented by 1.
 */
int array_push(array *arr, struct filetype *ft, const char* item, int len) {
	if(arr == NULL)
		return -1;
	if(arr->maxsize == 0)
		return -1;
	if(arr->index == arr->maxsize) {
		arr->maxsize = arr->maxsize*2;
		arr->lines = (line**)realloc(arr->lines, arr->maxsize*sizeof(arr->lines));
	}
	line *l = (line*)malloc(sizeof(line));
	l->content = (char*)malloc(len*sizeof(char));
	strcpy(l->content, item);
	l->len = len;
	if(line_annotate(l, ft) < 0)
		return -1;
	if(l->scom >= 0)
		arr->comlines++;
	arr->lines[arr->index] = l;
	arr->index++;
	return 0;
}

/*
 * array_at populates the target with the array element at the given
 * index if it exists, otherwise -1 is returned.
 */
int array_at(array *arr, line* target, int index) {
	if(arr == NULL)
		return -1;
	if(target == NULL)
		return -1;
	if(arr->index < index)
		return -1;
	line *line = arr->lines[index];
	if(line == NULL)
		return -1;
	*target = *line;
	return 0;
}

/* array_destroy frees all of the contents of the array and cleans up. */
void array_destroy(array *arr) {
	if(arr == NULL)
		return;
	for(int i = 0; i < arr->index; i++) {
		if(arr->lines[i] != NULL) {
			free(arr->lines[i]);
			arr->lines[i] = NULL;
		}
	}
}
