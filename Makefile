all: homebrew \
	homebrew-deps \
	kb \
	git \
	hdirs \
	symlinks \
	rust \
	gotools \
	prettier \
	fzf \
	gcloud \
	terraform \
	gcloud \
	base16 \
	lisp

###########################
#      Variables
###########################
SHELL := /bin/zsh
export PATH := /bin:$(PATH):/usr/local/go/bin
###########################
#         Versions
###########################
GO_VERSION=1.16.4
TF_VERSION=0.14.10
###########################
#         Deps
###########################
go:
ifneq (go$(GO_VERSION), $(shell go version | awk '{print $$3}'))
	curl -L -o /tmp/go.tar.gz \
		https://golang.org/dl/go$(GO_VERSION).darwin-arm64.tar.gz 
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf /tmp/go.tar.gz
endif

rust:
ifeq ($(shell command -v cargo 2> /dev/null),)
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

haskell:
ifeq ($(shell command -v ghc 2> /dev/null),)
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | arch -x86_64 /bin/bash
endif
ifeq ($(shell command -v stack 2> /dev/null),)
	curl -sSL https://get.haskellstack.org/ | sh
endif

homebrew:
	bin/sh/scripts/installbrew

homebrewdeps:
	brew update
	brew upgrade

	# from default repo
	brew install \
		wget \
		cmake \
		ninja \
		meson \
		postgresql \
		ripgrep \
		tmux \
		ctags \
		clang-format \
		graphviz \
		htop \
		openjdk@11 \
		maven \
		python@3.9 \
		reattach-to-user-namespace \
		linkerd \
		helm \
		exercism \
		iterm2 \
		llvm \
		watch \
		moreutils \
		git \
		vim \
		gpg \
		pinentry-mac \
		ispell \
		sbcl \
		font-fira-sans \
		ansible \
		jq \
		ledger \
		node@16 \
		svn \
		protobuf \
		gh \
		staticcheck \
		delve \
		tree

	# from tap
	brew tap homebrew/cask-fonts
	brew tap railwaycat/emacsmacport

	# from source
	brew install --build-from-source roswell

	# from cask
	brew install --cask \
		font-source-code-pro \
		font-fira-code \
		font-fira-mono  \
		font-bitstream-vera \
		font-dejavu \
		font-ia-writer-duo \
		font-ia-writer-duospace \
		font-ia-writer-mono \
		font-ia-writer-quattro

	# emacs
	brew install emacs-mac --with-modules
	ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app

.PHONY: kb
kb:
	mkdir -p ~/.config/karabiner/assets/complex_modifications
	bin/sh/sym $(shell pwd)/kb/capslock.json ~/.config/karabiner/assets/complex_modifications/capslock.json
	bin/sh/sym $(shell pwd)/kb/karabiner.json ~/.config/karabiner/karabiner.json

###########################
#    Home Directories
###########################
hdirs: 
	bin/sh/sym $(shell pwd)/src $(HOME)/src
	bin/sh/sym $(shell pwd)/bin $(HOME)/bin
	mkdir -p $(HOME)/work
	mkdir -p $(HOME)/tmp

ifeq ($(wildcard $(HOME)/personal/.*),)
	git clone git@github.com:dnjp/personal.git $(HOME)/personal --recurse-submodules
endif

###########################
#        Symlinks
###########################
symlinks:
	# vim
	bin/sh/sym $(shell pwd)/editors/vimrc $(HOME)/.vimrc
	mkdir -p $(HOME)/.vim
	bin/sh/sym $(shell pwd)/editors/vim/templates $(HOME)/.vim/templates
	# tmux
	bin/sh/sym $(shell pwd)/term/tmux/tmux.conf $(HOME)/.tmux.conf
	# ctags
	mkdir -p $(HOME)/.config/ctags.d
	bin/sh/sym $(shell pwd)/editors/ctags $(HOME)/.config/ctags.d/default.ctags
	# git
	bin/sh/sym $(shell pwd)/git/gitconfig $(HOME)/.gitconfig
	bin/sh/sym $(shell pwd)/git/gitignore $(HOME)/.gitignore
	# zsh
	bin/sh/sym $(shell pwd)/shells/zsh/zshrc ${HOME}/.zshrc
	# emacs
	bin/sh/sym $(shell pwd)/editors/emacs/config ${HOME}/.emacs
	bin/sh/sym $(shell pwd)/editors/emacs/emacs.d ${HOME}/.emacs.d

###########################
#        Binaries
###########################
gcloud:
ifeq ($(shell command -v gcloud 2> /dev/null),)
	curl https://sdk.cloud.google.com | bash
endif

kubectl: gcloud
	source ~/.zshenv && gcloud components install kubectl

terraform:
	curl -o /tmp/terraform.zip \
		https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_darwin_amd64.zip
	unzip /tmp/terraform.zip -d /tmp
	sudo mv /tmp/terraform /usr/local/bin/terraform

cqlsh:
	sudo mkdir -p /usr/local/share/cqlsh
	sudo tar -xf sources/cqlsh.tar -C /usr/local/share/cqlsh

urbit:
	mkdir -p ~/urbit
	cd ~/urbit && curl -JLO https://urbit.org/install/mac/latest
	cd ~/urbit && tar zxvf ./darwin.tgz --strip=1
	~/urbit/urbit

lisp:
	curl -o /tmp/quicklisp.lisp \
		https://beta.quicklisp.org/quicklisp.lisp
	sbcl --load /tmp/quicklisp.lisp
	# (quicklisp-quickstart:install)
	# (ql:add-to-init-file)
	# (ql:quickload "quicklisp-slime-helper")
###########################
#        Sources
###########################
godeps: go
	go get -u github.com/cweill/gotests/...
	go get github.com/motemen/gore/cmd/gore

gotools: go
	go get -u golang.org/x/tools/...

prettier:
	npm install prettier -g

fzf:
	cd sources/github.com/junegunn/fzf && \
		./install

base16:
	git clone \
		https://github.com/chriskempson/base16-shell.git \
		~/.config/base16-shell

