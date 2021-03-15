#########################################
#
# dependencies:
# - python3-dev
# - python2-dev
#########################################

all: git \
	bash \
	go \
	rust \
	progfonts \
	alacritty \
	tmux \
	ctags \
	golint \
	gotools \
	staticcheck \
	redshift \
	ripgrep \
	exercism \
	nvm \
	prettier \
	hdirs \
	fzf \
	xcape \
	vim \
	vi

###########################
#      Variables
###########################

SHELL := /bin/bash
export PATH := /bin:$(PATH):/usr/local/go/bin

USER=daniel
HBIN=/home/daniel/bin

###########################
#         Versions
###########################
GO_VERSION=1.15.6
# GO_VERSION=1.16

###########################
#         Deps
###########################

.PHONY: git
git:
	bin/sh/sym $(shell pwd)/git/gitconfig $(HOME)/.gitconfig

# go: curl
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

###########################
#         bin/src
###########################

hdirs: go bash
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
#        Github
###########################

vim:
	cd sources/github.com/vim/vim && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		./configure \
			--enable-fail-if-missing \
			--enable-fontset \
			--disable-gpm \
			--enable-multibyte \
			--enable-pythoninterp=yes \
			--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
			--enable-python3interp=yes \
			--with-python-config-dir=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu \
			--with-x \
			--with-features=big && \
		make && \
		sudo make install
	bin/sh/sym $(shell pwd)/editors/vimrc $(HOME)/.vimrc

vi:
	cd sources/github.com/dnjp/nvi/dist && \
		./distrib
	cd sources/github.com/dnjp/nvi/build.unix && \
		../dist/configure \
			--enable-widechar && \
		make && \
		sudo make install
	bin/sh/sym $(shell pwd)/editors/exrc $(HOME)/.exrc

alacritty: rust
	cd sources/github.com/alacritty/alacritty && \
		cargo build --release && \
		sudo tic -xe alacritty,alacritty-direct extra/alacritty.info && \
		sudo cp target/release/alacritty /usr/local/bin && \
		sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg && \
		sudo desktop-file-install extra/linux/Alacritty.desktop && \
		sudo update-desktop-database
	mkdir -p $(HOME)/.config/alacritty
	bin/sh/sym $(shell pwd)/term/alacritty/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

redshift:
	cd sources/github.com/jonls/redshift && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		./bootstrap && \
		./configure && \
		make && \
		sudo make install
ripgrep:
	cd sources/github.com/BurntSushi/ripgrep && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		cargo build --release && \
		sudo cp ./target/release/rg /usr/local/bin/

tmux:
	cd sources/github.com/tmux/tmux && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		sh ./autogen.sh && \
		./configure && \
		make && \
		sudo make install
	bin/sh/sym $(shell pwd)/term/tmux/tmux.conf $(HOME)/.tmux.conf

ctags:
	cd sources/github.com/universal-ctags/ctags && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		sh ./autogen.sh && \
		./configure && \
		make && \
		sudo make install
	mkdir -p $(HOME)/.config/ctags
	bin/sh/sym $(shell pwd)/editors/ctags $(HOME)/.config/ctags/ctags

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

exercism:
	cd sources/github.com/exercism/cli && \
		git clean -fdx && \
		git reset --hard && \
		git checkout main && \
		git pull && \
		go build -o exercism.bin exercism/main.go && \
		sudo cp ./exercism.bin /usr/local/bin/exercism

nvm: bash
	cd sources/github.com/nvm-sh/nvm && \
		./install.sh && \
		source ~/.bashrc && \	
		nvm install --lts

prettier: 
	npm install prettier -g

curl:
ifeq ($(wildcard /usr/local/bin/curl),)
	cd sources/github.com/curl/curl/ && \
		mkdir -p build && \
		cd build && \
		cmake .. && \
		make && \
		sudo make install
endif

fzf:
	cd sources/github.com/junegunn/fzf && \
		./install

xcape:
	cd sources/github.com/alols/xcape && \
		make && \
		sudo make install

###########################
#  git.savannah.gnu.org
###########################
bash:
ifneq ($(shell command -v bash 2> /dev/null), /usr/bin/bash)
	cd sources/git.savannah.gnu.org/bash && \
		git clean -fdx && \
		git reset --hard && \
		git checkout master && \
		git pull && \
		./configure --prefix=/usr \
			--without-bash-malloc \
			--enable-readline && \
		make && \
		sudo make install

	sudo sh -c "echo '/usr/bin/bash' >> /etc/shells" && \
	sudo cp ./shells/bash/system.bashrc /etc/bash.bashrc
	sudo cp ./shells/bash/system.bash_logout /etc/bash.bash_logout
	chsh -s /usr/bin/bash $(USER)

	bin/sh/sym $(shell pwd)/shells/bash/bashrc ${HOME}/.bashrc
	bin/sh/sym $(shell pwd)/shells/bash/bash_profile ${HOME}/.bash_profile
	bin/sh/sym $(shell pwd)/shells/profile ${HOME}/.profile
endif



