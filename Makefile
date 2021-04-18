all: homebrew \
	homebrew-deps \
	kb \
	git \
	hdirs \
	symlinks \
	rust \
	golint \
	gotools \
	staticcheck \
	delve \
	nvm \
	prettier \
	walk \
	fzf \
	gcloud \
	terraform \
	gcloud \
	base16 \
	ohmyzsh

###########################
#      Variables
###########################
SHELL := /bin/zsh
export PATH := /bin:$(PATH):/usr/local/go/bin
###########################
#         Versions
###########################
GO_VERSION=1.15.6
TF_VERSION=0.14.6
###########################
#         Deps
###########################
rust:
ifeq ($(shell command -v cargo 2> /dev/null),)
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

homebrew:
	bin/sh/scripts/installbrew

homebrewdeps:
	brew update
	brew upgrade
	brew tap homebrew/cask-fonts
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
		vim

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
 
.PHONY: kb
kb:
	mkdir -p ~/.config/karabiner/assets/complex_modifications
	bin/sh/sym $(shell pwd)/kb/capslock.json ~/.config/karabiner/assets/complex_modifications/capslock.json
	bin/sh/sym $(shell pwd)/kb/karabiner.json ~/.config/karabiner/karabiner.json

###########################
#    Home Directories
###########################
hdirs: go 
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

###########################
#        Sources
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
		source ~/.zshrc && \
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

base16:
	git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell


