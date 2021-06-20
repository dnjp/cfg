all: homebrew \
	homebrewdeps \
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
	lisp \
	godeps

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
ifeq (, $(shell which cargo))
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

haskell:
ifeq (, $(shell which ghc))
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | arch -x86_64 /bin/bash
endif
ifeq (, $(shell which stack))
	curl -sSL https://get.haskellstack.org/ | sh
endif

homebrew:
ifeq (, $(shell which brew))
	bin/sh/scripts/installbrew
endif

homebrewdeps: homebrew
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
		neovim \
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
		tree \
		zoxide

	# platform specific
	arch -arm64 brew install koekeishiya/formulae/skhd
	brew services start skhd

	# from tap
	brew tap homebrew/cask-fonts

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

	brew unlink go

.PHONY: kb
kb:
	# karabiner
	mkdir -p ~/.config/karabiner/assets/complex_modifications
	bin/sh/sym $(shell pwd)/kb/capslock.json ~/.config/karabiner/assets/complex_modifications/capslock.json
	bin/sh/sym $(shell pwd)/kb/karabiner.json ~/.config/karabiner/karabiner.json

	# skhd
	mkdir -p ~/.config/skhd
	bin/sh/sym $(shell pwd)/kb/skhdrc ~/.config/skhd/skhdrc

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

###########################
#        Daemons
###########################
.PHONY: daemons
daemons:
	mkdir -p ${HOME}/.local/var/log/9lab

	cp $(shell pwd)/daemons/9lab.org.acme-lsp.plist ~/Library/LaunchAgents/9lab.org.acme-lsp.plist
	cp $(shell pwd)/daemons/9lab.org.acmefocused.plist ~/Library/LaunchAgents/9lab.org.acmefocused.plist

###########################
#        Binaries
###########################
gcloud:
ifeq (, $(shell which gcloud))
	curl https://sdk.cloud.google.com | bash
endif

terraform:
ifneq (v$(TF_VERSION), $(shell terraform version | head -n 1 | awk '{print $$2}'))
	curl -o /tmp/terraform.zip \
		https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_darwin_amd64.zip
	unzip /tmp/terraform.zip -d /tmp
	sudo mv /tmp/terraform /usr/local/bin/terraform
endif

cqlsh:
ifeq (, $(shell which cqlsh))
	sudo mkdir -p /usr/local/share/cqlsh
	sudo tar -xf sources/cqlsh.tar -C /usr/local/share/cqlsh
endif

urbit:
ifeq (, $(shell which urbit))
	mkdir -p ~/urbit
	cd ~/urbit && curl -JLO https://urbit.org/install/mac/latest
	cd ~/urbit && tar zxvf ./darwin.tgz --strip=1
	~/urbit/urbit
endif

lisp:
	# (quicklisp-quickstart:install)
	# (ql:add-to-init-file)
	# (ql:quickload "quicklisp-slime-helper")
ifeq (, $(shell ls ~ | grep quicklisp))
	curl -o /tmp/quicklisp.lisp \
		https://beta.quicklisp.org/quicklisp.lisp
	sbcl --load /tmp/quicklisp.lisp
endif

setupacme:
	GO111MODULE=on go get github.com/fhs/acme-lsp/cmd/acme-lsp@latest
	GO111MODULE=on go get github.com/fhs/acme-lsp/cmd/L@latest
	GO111MODULE=on go get github.com/fhs/acme-lsp/cmd/acmefocused@latest
	GO111MODULE=on go get golang.org/x/tools/gopls@latest
	GO111MODULE=on go get 9fans.net/go/...
	mkdir -p ${HOME}/Library/Application\ Support/acme-lsp
	cp $(shell pwd)/editors/lsp.toml ${HOME}/Library/Application\ Support/acme-lsp/config.toml

###########################
#        Sources
###########################
godeps: go
ifeq (, $(shell which gotests))
	go get -u github.com/cweill/gotests/...
endif
ifeq (, $(shell which gore))
	go get github.com/motemen/gore/cmd/gore
endif

gotools: go
ifeq (, $(shell which gopls))
	go get -u golang.org/x/tools/...
endif

prettier:
ifeq (, $(shell which prettier))
	npm install prettier -g
endif

fzf:
ifeq (, $(shell which fzf))
	cd sources/github.com/junegunn/fzf && \
		./install
endif

base16:
ifeq (, $(shell ls ~/.config | grep base16))
	git clone \
		https://github.com/chriskempson/base16-shell.git \
		~/.config/base16-shell
endif

plan9:
ifeq (, $(shell ls ~/ | grep plan9))
	git clone \
		https://github.com/9fans/plan9port.git \
		~/plan9
	~/plan9/INSTALL
endif

.PHONY: mac
mac:
	cp -r mac/9term.app /Applications/
	cp -r mac/acme.app /Applications/
