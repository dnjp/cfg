SHELL := /bin/bash
PROFILE := "~/.yashrc"

# pkgsrc
BOOTSTRAP_TAR := bootstrap-el7-trunk-x86_64-20200724.tar.gz
BOOTSTRAP_SHA := 478d2e30f150712a851f8f4bcff7f60026f65c9e
PKGS := $(shell cat ./pkgs.txt)

# set path for plan9 and go
export PATH := $(PATH):/usr/local/plan9/bin:/usr/local/go/bin

###########################
#      Variables
###########################
user=daniel
nbin=/home/daniel/bin
goversion=1.14.7

###########################
#         Deps
###########################

pkgsrc:
ifeq ($(wildcard /usr/pkg/.*),)
	echo "installing pkgsrc..." 
	curl -o /tmp/${BOOTSTRAP_TAR} https://pkgsrc.joyent.com/packages/Linux/el7/bootstrap/${BOOTSTRAP_TAR} 
	sudo tar -zxpf /tmp/${BOOTSTRAP_TAR} -C / 
endif
	export PATH=/usr/pkg/bin:$$PATH && \
		sudo pkgin -y update && \
		sudo pkgin -y upgrade && \
		sudo pkgin -y install ${PKGS}

go:
ifeq ($(wildcard /usr/local/go/.*),)
	cd /tmp && \
		curl -OL https://golang.org/dl/go$(goversion).linux-amd64.tar.gz && \
		sudo tar -C /usr/local -xzf go*.tar.gz
endif

plan9port:
ifeq ($(wildcard /usr/local/plan9/.*),)
	cd sources/git.sr.ht/danieljamespost/plan9port && \
		./PREINSTALL 
	ln -s $(shell pwd)/p9p/lib $(HOME)/lib 
	ln -s $(shell pwd)/p9p/bin $(HOME)/bin 
	ln -s $(shell pwd)/p9p/mail $(HOME)/mail 
	ln -s $(shell pwd)/p9p/mail/msmtprc $(HOME)/.msmtprc
endif

rustinstalled := $(shell command -v cargo 2> /dev/null)
rust:
ifndef rustinstalled
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

homebrew:
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brews:
	brew install ${BREWS}
	# echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/go@1.14/bin:$PATH"' >> ${PROFILE}
	# echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/node@12/bin:$PATH"' >> ${PROFILE}
  	# LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/llvm/lib -Wl,-rpath,/home/linuxbrew/.linuxbrew/opt/llvm/lib"

###########################
#        Sourcehut
###########################

# danieljamespost
dmenu: 
	cd sources/git.sr.ht/danieljamespost/dmenu && \
		make && \
		sudo make install

dwm: 
	cd sources/git.sr.ht/danieljamespost/dwm && \
		make && \
		sudo make install

st: 
	cd sources/git.sr.ht/danieljamespost/st && \
		make && \
		sudo make install

slstatus: 
	cd sources/git.sr.ht/danieljamespost/slstatus && \
		make && \
		sudo make install

edwood: go
	cd sources/git.sr.ht/danieljamespost/edwood && \
		go install

nyne: go plan9port
	cd sources/git.sr.ht/danieljamespost/nyne && \
		mk && \
		installdir=$(nbin) mk install 
	ln -s $(shell pwd)/p9p/nyne $(HOME)/.config/nyne

rc: 
	cd sources/git.sr.ht/danieljamespost/rc && \
		./boostrap &&
		./configure --with-edit=readline && \
		make && \
		sudo make install

# emersion
mrsh:
	cd sources/git.sr.ht/emersion/mrsh && \
		./configure && \
		make && \
		sudo make install

# sircmpwn
aerc: go
	cd sources/git.sr.ht/sircmpwn/aerc && \
		make && \
		sudo make install
	ln -s $(shell pwd)/email/aerc/aerc.conf $(HOME).config/aerc/aerc.conf
	ln -s $(shell pwd)/email/aerc/binds.conf $(HOME).config/aerc/binds.conf

###########################
#        Github
###########################

# fhs
acmelsp: go
	cd sources/github.com/fhs/acme-lsp && \
		go install ./cmd/acme-lsp && \
		go install ./cmd/L 
	ln -s $(shell pwd)/p9p/lsp $(HOME)/.config/acme-lsp 

# hashicorp
terraform: go
	cd sources/github.com/hashicorp/terraform \
		&& git clean -f -d \
		&& git reset --hard \
		&& git checkout master \
		&& git pull \
		&& git checkout v0.13.1 \
		&& go mod vendor \
		&& go build \
		&& go install

# magicant
yash: 
	cd sources/github.com/magicant/yash && \
		./configure && \
		make && \
		sudo make install 
	sudo sh -c "echo '/usr/local/bin/yash' >> /etc/shells" && \
	chsh -s /usr/local/bin/yash $(user)

# vim
vim: 
	cd sources/github.com/vim/vim && \
		./configure --enable-fontset --with-x --with-features=normal && \
		make && \
		sudo make install
	ln -s $(shell pwd)/editors/vimrc $(HOME)/.vimrc 

wmaker:
	cd sources/github.com/window-maker/wmaker && \
		./autogen.sh && \
		./configure && make && sudo make install
	ln -s $(shell pwd)/wm/wmaker/WMGLOBAL $(HOME)/GNUstep/Defaults/WMGLOBAL 
	ln -s $(shell pwd)/wm/wmaker/WMRootMenu $(HOME)/GNUstep/Defaults/WMRootMenu 
	ln -s $(shell pwd)/wm/wmaker/WMWindowAttributes $(HOME)/GNUstep/Defaults/WMWindowAttributes 
	ln -s $(shell pwd)/wm/wmaker/WPrefs $(HOME)/GNUstep/Defaults/WPrefs 
	ln -s $(shell pwd)/wm/wmaker/WindowMaker $(HOME)/GNUstep/Defaults/WindowMaker 

alacritty: rust
	# TODO: do this somewhere else
	sudo pacman -S cmake freetype2 fontconfig pkg-config make libxcb
	cd sources/github.com/alacritty/alacritty && \
		cargo build --release && \
		sudo tic -xe alacritty,alacritty-direct extra/alacritty.info && \
		sudo cp target/release/alacritty /usr/local/bin && \
		sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg && \
		sudo desktop-file-install extra/linux/Alacritty.desktop && \
		sudo update-desktop-database
	mkdir -p $(HOME)/.config/alacritty
	ln -s $(shell pwd)/term/alacritty/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

meslo:
	sudo mkdir -p /usr/share/fonts/meslo
	cd sources/github.com/andreberg/Meslo-Font/dist/v1.2.1 && \
		sudo unzip 'Meslo LG v1.2.1.zip' -d /usr/share/fonts/meslo
		
redshift:
	cd sources/github/jonls/redshift && \
		./bootstrap.sh && \
		./configure && \
		make && \
		sudo make install
ripgrep:
	cd sources/github/BurntSushi/ripgrep && \
		./cargo build --release && \
		sudo cp ./target/release/rg /usr/local/bin/ 

libetpan:
	cd sources/github.com/dinhvh/libetpan && \
		./autogen.sh && \
		make && \
		sudo make install


###########################
#      repo.or.cz
###########################

nvi:
	cd sources/repo.or.cz/nvi/dist && \
		./distrib
	cd sources/repo.or.cz/nvi/build.unix && \
		../dist/configure --enable-widechar && \
		make && \
		sudo make install 
	ln -s $(shell pwd)/editors/exrc $(HOME)/.exrc 


###########################
#  git.claws-mail.org
###########################

claws: libetpan
	cd sources/git.claws-mail.org/claws && \
		./autogen.sh && \
		make && \
		sudo make install


