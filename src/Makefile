all: com

SHELL := /bin/bash
BINDIR := /home/daniel/bin/amd64

.PHONY: com
com:
	go build cmd/com/com.go

install: all
	cp com ${BINDIR}/com
