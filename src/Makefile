all: com \
	tree \
	next \
	ind

SHELL := /bin/bash
BINDIR := /home/daniel/bin/amd64

.PHONY: com
com:
	go build cmd/com/com.go

.PHONY: tree
tree:
	go build cmd/tree/tree.go

.PHONY: next
next:
	go build cmd/next/next.go

.PHONY: ind
ind:
	go build cmd/ind/ind.go

install: all
	cp com ${BINDIR}/com
	cp tree ${BINDIR}/tree
	cp next ${BINDIR}/nxt
	cp ind ${BINDIR}/ind
