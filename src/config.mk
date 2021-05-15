VERSION = 0.1

PREFIX    = /usr/local
MANPREFIX = ${PREFIX}/share/man

BINDIR    = ${HOME}/bin/amd64

CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=200809L -DVERSION=\"${VERSION}\" 
CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${CPPFLAGS}
LDFLAGS  = 

CC = clang
