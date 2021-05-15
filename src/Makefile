include config.mk

SRC = com.c array.c ft.c line.c
OBJ = ${SRC:.c=.o}
CFLAGS = "-g"

all: options com

options:
	@echo com build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h ft.h array.h config.mk

config.h:
	cp config.def.h $@

com: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f com ${OBJ} 

install: all
	mkdir -p ${BINDIR}
	cp -f com ${BINDIR}
	chmod 755 ${BINDIR}/com

uninstall:
	rm -f ${BINDIR}/com

.PHONY: all options clean install uninstall
