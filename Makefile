all: yay \
	pacman-deps \
	yay-deps \
	git \
	hdirs \
	bash \
	go \
	rust \
	progfonts \
	alacritty \
	tmux \
	ctags \
	vi \
	vis \
	aerc \
	golint \
	gotools \
	staticcheck \
	delve \
	redshift \
	ripgrep \
	nvm \
	prettier \
	mail \
	caps2esc \
	x330brightness \
	suckless \
	9fans

###########################
#      Variables
###########################

SHELL := /bin/bash
export PATH := /bin:$(PATH):/usr/local/go/bin

USER=daniel
HBIN=/home/daniel/bin

POSTEOPASS ?= $(shell stty -echo; read -p "Posteo Password: " pwd; stty echo; echo $$pwd)
MARTINPASS ?= $(shell stty -echo; read -p "Martin Password: " pwd; stty echo; echo $$pwd)
GMAILPASS ?= $(shell stty -echo; read -p "Gmail Password: " pwd; stty echo; echo $$pwd)

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

pacman-deps:
	sudo pacman -S \
		xapian-core \
		gmime3 \
		talloc \
		zlib \
		python3 \
		pip \
		nextcoud-client \
		cmake \
		boost \
		yaml-cpp \
		gnome-keyring \
		seahorse \
		pulseaudio \
		pulseaudio-bluetooth \
		pavucontrol \
		docker \
		okular \
		unzip \
		htop \
		dunst \
		acpi \
		alot \
		w3m \
		scdoc \
		libtermkey \
		lua \
		lua-lpeg \
		gdb \
		valgrind \
		scrot \
		postgresql \
		jre8-openjdk \
		jdk8-openjdk \
		maven \
		docker-compose \
		chromium \
		pgadmin4 \
		libbsd \
		curl \
		meson \
		net-tools \
		inetutils \
		dash

yay-deps:
	yay -S \
		brave-bin \
		slack-desktop \
		xlayoutdisplay \
		spotify \
		cqlsh \
		dashbinsh

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
#         Mail
###########################
.PHONY: mail
mail:
	# dependencies
# ifeq (, $(shell which afew))
#	pip install afew
# # endif
# ifeq (, $(shell which notmuch))
#	$(error "notmuch not in $$PATH: apt install notmuch")
# endif
# ifeq (, $(shell which mbsync))
#	$(error "mbsync not in $$PATH: apt install mbsync")
# endif
# ifeq (, $(shell which msmtp))
#	$(error "msmtp not in $$PATH: apt install msmtp")
# endif
	# notmuch
	bin/sh/sym $(shell pwd)/mail/config/notmuch-config $(HOME)/.notmuch-config
	# mbsync
	bin/sh/sym $(shell pwd)/mail/config/mbsyncrc $(HOME)/.mbsyncrc
	# msmtp
	cp $(shell pwd)/mail/config/msmtprc $(HOME)/.msmtprc
	chmod 600 $(HOME)/.msmtprc
	mkdir -p ~/.msmtpqueue

	# afew
	mkdir -p ~/.config/afew
	bin/sh/sym $(shell pwd)/mail/config/afew-config $(HOME)/.config/afew/config

	mkdir -p ~/.config/systemd/user
	bin/sh/sym \
		$(shell pwd)/mail/services/checkmail.service \
		$(HOME)/.config/systemd/user/checkmail.service
	bin/sh/sym \
		$(shell pwd)/mail/services/checkmail.timer \
		$(HOME)/.config/systemd/user/checkmail.timer
	bin/sh/sym \
		$(shell pwd)/mail/services/nm-backup.service \
		$(HOME)/.config/systemd/user/nm-backup.service
	bin/sh/sym \
		$(shell pwd)/mail/services/nm-backup.timer \
		$(HOME)/.config/systemd/user/nm-backup.timer

	bin/sh/sym $(shell pwd)/mail $(HOME)/.mail

	systemctl --user enable checkmail.timer
	systemctl --user start checkmail.timer
	systemctl --user enable nm-backup.timer
	systemctl --user start nm-backup.timer

gpgimport:
	gpg --import ~/Nextcloud/secrets/privkey.asc

mailsecrets:
ifeq (failed, $(shell bin/sh/check 'gpg --list-keys dnjp@posteo.org'))
	gpg --full-generate-key
endif
	# create secrets
	echo $(POSTEOPASS) > mail/secrets/posteo
	$(info '')
	echo $(GMAILPASS)  > mail/secrets/gmail
	$(info '')
	echo $(MARTINPASS) > mail/secrets/martin
	gpg -r dnjp@posteo.org -e mail/secrets/posteo
	gpg -r dnjp@posteo.org -e mail/secrets/gmail
	gpg -r dnjp@posteo.org -e mail/secrets/martin

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

suckless:
	cd sources/github.com/dnjp/dwm && \
		make && \
		sudo make install
	cd sources/github.com/dnjp/dmenu && \
		make && \
		sudo make install
	cd sources/github.com/dnjp/slstatus && \
		make && \
		sudo make install

plan9port:
ifeq ($(wildcard /usr/local/plan9/.*),)
	cd sources/github.com/dnjp/plan9port && \
		./PREINSTALL 
endif

vi:
	cd sources/github.com/dnjp/nvi/dist && \
		./distrib
	cd sources/github.com/dnjp/nvi/build.unix && \
		../dist/configure \
			--enable-widechar && \
		make && \
		sudo make install
	bin/sh/sym $(shell pwd)/editors/exrc $(HOME)/.exrc

vis:
	bin/sh/sym $(shell pwd)/editors/vis ~/.config/vis
	cd sources/github.com/dnjp/vis && \
		./configure && \
		make && \
		sudo make install

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
	mkdir -p $(HOME)/.config/ctags.d
	bin/sh/sym $(shell pwd)/editors/ctags $(HOME)/.config/ctags.d/default.ctags
	sudo ln -s /usr/local/bin/ctags /usr/bin/ctags

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
nvm: bash
	cd sources/github.com/nvm-sh/nvm && \
		./install.sh && \
		source ~/.bashrc && \
		nvm install --lts

prettier:
	npm install prettier -g

yay:
	cd sources/github.com/Jguer/yay && \
		make && \
		sudo make install

###########################
#  git.savannah.gnu.org
###########################
bash:
# ifneq ($(shell command -v bash 2> /dev/null), /usr/bin/bash)
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
# endif

###########################
#  gitlab.com
###########################
interception:
	cd sources/gitlab.com/interception/linux/tools && \
		mkdir -p build && \
		cmake -B build -DCMAKE_BUILD_TYPE=Release && \
		cmake --build build && \
		cd build && \
		sudo make install
	sudo cp sources/gitlab.com/interception/linux/tools/udevmon.service \
		/etc/systemd/system/
	sudo ln -s /usr/local/bin/udevmon /usr/bin/udevmon
	sudo systemctl enable udevmon

caps2esc: interception
	cd sources/gitlab.com/interception/linux/plugins/caps2esc && \
		mkdir -p build && \
		cmake -B build -DCMAKE_BUILD_TYPE=Release && \
		cmake --build build && \
		cd build && \
		sudo make install

	sudo mkdir -p /etc/interception/udevmon.d
	sudo cp x330/caps2esc.udev.yaml /etc/interception/udevmon.d/udev.yaml

9fans:
	cd sources/github.com/9fans/go/acme/editinacme && \
		go install

###########################
#  git.sr.ht
###########################

aerc:
	cd sources/git.sr.ht/sircmpwn/aerc && \
		git clean -fdx && \
		git checkout master && \
		git pull && \
		GOFLAGS=-tags=notmuch make && \
		sudo make install

	bin/sh/sym $(shell pwd)/mail/config/aerc $(HOME)/.config/aerc

	sudo cp $(shell pwd)/mail/config/aerc/aerc.desktop \
		/usr/share/applications/
	xdg-mime default aerc.desktop 'x-scheme-handler/mailto'

###########################
#  Other
###########################

x330brightness:
	cd x330/brightness && \
		make && \
		sudo mv script /usr/local/bin/backlight
	sudo cp x330/50-display.rules /etc/udev/rules.d/

