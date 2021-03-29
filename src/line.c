#include "line.h"

/* line_annotate fills in details about the underlying string */
int line_annotate(line *line, struct filetype *ft)
{
	int scomlen = 0;
	int ecomlen = 0;
	int scom = -1;
	int ecom = -1;

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

	int fch = 0;
	char *str = line->content;
	for(int i = 0; i < line->len; i++) {
		if(str[fch] == ' ' || str[fch] == '\t') {
			continue;
		}
		if(fch == 0)
			fch = i;
		if(scomlen > 0 && i+(scomlen-1) != line->len) {
			int s = 0;
			for(int j = i; j < scomlen; j++) {
				if(str[j] == ft->comstart[j-i]) {
					s++;	
				}
			}
			if(s == scomlen)
				scom = i;
		}
		if(ecomlen > 0 && i+(ecomlen-1) != line->len) {
			int s = 0;
			for(int j = i; j < ecomlen; j++) {
				if(str[j] == ft->comend[j-i]) {
					s++;
				}
			}
			if(s == ecomlen)
				ecom = i;
		}
	}
	line->scom = scom;
	line->ecom = scom;
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
	substring(l->content, first, start, end);

	start = l->fch+1;
	end = l->len;
	second = (char*)malloc((end-start)+1*sizeof(char));
	substring(l->content, second, start, end);

	if(ft->comstart != NULL && ft->comend != NULL) {
		sprintf(l->content, "%s%s %s %s",
			first,
			ft->comstart,
			second,
			ft->comend
		);
	} else if(ft->comstart != NULL) {
		sprintf(l->content, "%s%s %s",
			first,
			ft->comstart,
			second
		);
	}
	return 0;
}

int line_uncomment(line* line, struct filetype *ft)
{
	return 0;
}


int substring(const char* from, char* to, int start, int end)
{
	int j = 0;
	for(int i = start; i <= end; i++, j++) 
		to[j] = from[i];
	to[j] = '\0';
	return 0;
}
