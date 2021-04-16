all: debian-deps \
	git \
	hdirs \
	symlinks \
	go \
	rust \
	progfonts \
	golint \
	gotools \
	staticcheck \
	delve \
	nvm \
	prettier \
	walk \
	fzf
###########################
#      Variables
###########################
USER=daniel
HBIN=/home/daniel/bin
SHELL := /bin/bash
export PATH := /bin:$(PATH):/usr/local/go/bin
export APPDATA := /mnt/c/Users/dnjp/AppData/Roaming
###########################
#         Versions
###########################
GO_VERSION=1.15.6
###########################
#         Deps
###########################
.PHONY: git
git:
	bin/sh/sym $(shell pwd)/git/gitconfig $(HOME)/.gitconfig
	sudo cp git/ssh-agent.service \
		/etc/systemd/system/ssh-agent.service
	sudo systemctl enable ssh-agent
go:
ifeq ($(wildcard /usr/local/go/.*),)
	cd /tmp && \
		curl -OL https://golang.org/dl/go$(GO_VERSION).linux-amd64.tar.gz && \
		sudo rm -rf /usr/local/go && \
		sudo tar -C /usr/local -xzf go$(GO_VERSION).linux-amd64.tar.gz
endif
rust:
ifeq ($(shell command -v cargo 2> /dev/null),)
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif
debian-deps:
	sudo apt update
	sudo apt upgrade
	sudo apt install -y \
		build-essential \
		automake \
		libxft-dev \
		libfontconfig1-dev \
		libx11-dev \
		libxext-dev \
		libxt-dev \
		vim \
		apt-transport-https \
		ca-certificates \
		wget \
		dirmngr \
		gnupg \
		software-properties-common \
		xclip \
		cmake \
		ninja-build \
		meson \
		postgresql \
		ripgrep \
		tmux \
		universal-ctags \
		clang \
		clang-format
	# java 
	wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
	sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
	sudo apt update
	sudo apt install -y \
		adoptopenjdk-8-hotspot \
		openjdk-11-jdk \
		adoptopenjdk-13-hotspot \
		maven 
###########################
#         bin/src
###########################
hdirs: go 
	bin/sh/sym $(shell pwd)/src $(HOME)/src
	bin/sh/sym $(shell pwd)/bin $(HOME)/bin
	cd $(HOME)/src && \
		make && \
		make install
ifeq ($(wildcard $(HOME)/personal/.*),)
	git clone git@github.com:dnjp/personal.git $(HOME)/personal --recurse-submodules
endif
	mkdir -p $(HOME)/work
	mkdir -p $(HOME)/tmp
ifeq ($(wildcard $(HOME)/work/wdeps/.*),)
	cd $(HOME)/work && \
		git clone git@github.com:dnjp/wdeps.git \
		--recurse-submodules
	cd $(HOME)/work/wdeps && make
else
	cd $(HOME)/work/wdeps && \
		git clean -fdx && \
		git reset --hard && \
		git pull && \
		make
endif
###########################
#         Fonts
###########################
.PHONY: progfonts
progfonts:
	sudo mkdir -p /usr/share/fonts/meslo
	sudo cp \
		fonts/meslo/meslo_lg_1.2.1/*.ttf \
		/usr/share/fonts/meslo
	sudo cp \
		fonts/meslo/meslo_lg_dz_1.2.1/*.ttf \
		/usr/share/fonts/meslo
	sudo mkdir -p /usr/share/fonts/go
	sudo cp fonts/go/*.ttf /usr/share/fonts/go
	sudo mkdir -p /usr/share/fonts/lucida
	sudo cp fonts/lucida/*.ttf /usr/share/fonts/lucida
###########################
#        Symlinks
###########################
symlinks: 
	# vim
	bin/sh/sym $(shell pwd)/editors/vimrc $(HOME)/.vimrc
	# tmux
	bin/sh/sym $(shell pwd)/term/tmux/tmux.conf $(HOME)/.tmux.conf
	# ctags
	mkdir -p $(HOME)/.config/ctags.d
	bin/sh/sym $(shell pwd)/editors/ctags $(HOME)/.config/ctags.d/default.ctags
	# bash
	bin/sh/sym $(shell pwd)/shells/bash/bashrc ${HOME}/.bashrc
	bin/sh/sym $(shell pwd)/shells/bash/bash_profile ${HOME}/.bash_profile
	bin/sh/sym $(shell pwd)/shells/profile ${HOME}/.profile
###########################
#        Github
###########################
golint:
	cd sources/github.com/golang/lint/golint && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		go build -o golint && \
		sudo mv ./golint /usr/local/bin/golint
gotools:
	cd sources/github.com/golang/tools && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		mkdir -p bin && \
		go build -o ./bin/gocover cmd/cover/... && \
		go build -o ./bin/godigraph cmd/digraph/digraph.go && \
		go build -o ./bin/gostress cmd/stress/stress.go && \
		sudo mv ./bin/* /usr/local/bin/
staticcheck:
	cd sources/github.com/dominikh/go-tools && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		go install cmd/staticcheck/staticcheck.go
delve:
	cd sources/github.com/go-delve/delve && \
		go install ./...
nvm: 
	cd sources/github.com/nvm-sh/nvm && \
		./install.sh && \
		source ~/.bashrc && \
		nvm install --lts
prettier:
	npm install prettier -g
walk:
	cd sources/github.com/google/walk && \
		make && \
		sudo cp walk /usr/local/bin/walk && \
		sudo cp sor /usr/local/bin/sor
fzf:
	cd sources/github.com/junegunn/fzf && \
		./install
