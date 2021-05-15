#include "ft.h"

static struct filetype filetypes[] = {
	{ "// ", NULL, {".go", NULL} },      /* Go */
	{ "/* ", " */", {".c", ".h", NULL} }, /* C */
};
