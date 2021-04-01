#include "line.h"

/* line_annotate fills in details about the underlying string */
int line_annotate(line *line, struct filetype *ft)
{
	char *str = line->content;
	int scomlen = 0;
	int ecomlen = 0;

	int scom = -1;
	int ecom = -1;
	int fch = -1;
	int idx = -1;

	if(ft == NULL)
		return 0;
	if(line->len == 0)
		return 0;

	if(ft->comstart != NULL) {
		scomlen = strlen(ft->comstart);
	}
	if(ft->comend != NULL) {
		ecomlen = strlen(ft->comend);
	}

	for(int i = 0; i < line->len; i++) {
		if((isalpha(str[i]) != 0 || (str[i] != ' ' && str[i] != '\t')) && fch < 0)
			fch = i;
		if((idx = str_find(str, ft->comstart, i, scomlen)) >= 0)
			scom = idx;
		if((idx = str_find(str, ft->comend, i, ecomlen)) >= 0)
			ecom = idx;
	}

	line->scom = scom;
	line->ecom = ecom;
	line->fch = fch;
	return 0;
}

int line_comment(line* l, struct filetype *ft)
{
	int start;
	int end;
	char *first;
	char *second;

	start = 0;
	end = l->fch;
	first = (char*)malloc((end-start)+1*sizeof(char));
	str_sub(l->content, first, start, end);

	start = l->fch;
	end = l->len;
	second = (char*)malloc((end-start)+1*sizeof(char));
	str_sub(l->content, second, start, end);

	if(ft->comstart != NULL && ft->comend != NULL) {
		sprintf(l->content, "%s%s%s%s",
			first,
			ft->comstart,
			second,
			ft->comend
		);
	} else if(ft->comstart != NULL) {
		sprintf(l->content, "%s%s%s",
			first,
			ft->comstart,
			second
		);
	}
	return 0;
}

int line_uncomment(line* l, struct filetype *ft)
{
	int start;
	int end;
	char *first;
	char *second;
	int scomlen = 0;
	int ecomlen = 0;

	if(ft->comstart != NULL) {
		/* before the comment */
		scomlen = strlen(ft->comstart);
		start = 0;
		end = l->scom;
		first = (char*)malloc((end-start)+1*sizeof(char));
		str_sub(l->content, first, start, end);

		/* after the comment */
		int start = l->scom + scomlen;
		int end = l->len;
		second = (char*)malloc((end-start)+1*sizeof(char));
		str_sub(l->content, second, start, end);

		/* put string together */
		sprintf(l->content, "%s%s", first, second);
	}
	if(ft->comend != NULL) {
		/* before the comment */
		ecomlen = strlen(ft->comend);
		start = 0;
		end = l->ecom - scomlen;
		first = (char*)malloc((end-start)+1*sizeof(char));
		str_sub(l->content, first, start, end);
		
		/* after the comment */
		int start = l->ecom + ecomlen;
		int end = l->len;
		second = (char*)malloc((end-start)+1*sizeof(char));
		str_sub(l->content, second, start, end);

		/* put string together */
		sprintf(l->content, "%s%s", first, second);
	}
	return 0;
}

int str_find(const char* str, const char* sub, int start, int len)
{
	int idx = -1;
	int found = 0;
	for(int i = start; i < start+len; i++) {
		if(str[i] == sub[i-start]) {
			found++;
			idx = i;
		}
	}
	if(idx > 0 && found == len)
		return idx-(len-1);
	return -1;
}

int str_sub(const char* from, char* to, int start, int end)
{
	int j = 0;
	for(int i = start; i < end; i++, j++) 
		to[j] = from[i];
	to[j] = '\0';
	return 0;
}

