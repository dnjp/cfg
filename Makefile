
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

goinstalled := $(shell command -v go 2> /dev/null)
go:
ifndef goinstalled
	cd /tmp && \
		curl -OL https://golang.org/dl/go$(goversion).linux-amd64.tar.gz && \
		sudo tar -C /usr/local -xzf go*.tar.gz
endif

p9pinstalled := $(shell command -v 9 2> /dev/null)
plan9port:
ifndef p9pinstalled
	cd sources/git.sr.ht/danieljamespost/plan9port && \
		./PREINSTALL 
	ln -s $(shell pwd)/p9p/lib $(HOME)/lib 
	ln -s $(shell pwd)/p9p/bin $(HOME)/bin 
	ln -s $(shell pwd)/p9p/mail $(HOME)/mail 
	ln -s $(shell pwd)/p9p/mail/msmtprc $(HOME)/.msmtprc
endif

# symlinks:

libs:
# arch
ifeq (LIBSINST, done)

else ifeq ($(shell test -e /etc/arch-release  && echo -n yes),yes)
	sudo pacman -S \
		xorg \
		xorg-xinit \
		libx11 \
		readline \
		libedit
	LIBSINST=done
# debian
else ifeq ($(shell test -e /etc/debian_version && echo -n yes),yes)
	sudo apt update && \
	sudo apt upgrade && \
	sudo apt install -y \
		xorg \
		xinit \
		libx11-dev \
		libreadline-dev \
		libedit-dev
	LIBSINST=done
else
	cat /etc/arch-release
	$(error OS could not be determined)
endif


###########################
#        Sourcehut
###########################

# danieljamespost
dmenu: libs
	cd sources/git.sr.ht/danieljamespost/dmenu && \
		make
dmenuinstall: dmenu
	cd sources/git.sr.ht/danieljamespost/dmenu && \
		sudo make install
dwm: libs
	cd sources/git.sr.ht/danieljamespost/dwm && \
		make
dwminstall: dwm
	cd sources/git.sr.ht/danieljamespost/dwm && \
		sudo make install
st: libs
	cd sources/git.sr.ht/danieljamespost/st && \
		make
stinstall: st
	cd sources/git.sr.ht/danieljamespost/st && \
		sudo make install
slstatus: libs
	cd sources/git.sr.ht/danieljamespost/slstatus && \
		make
slstatusinstall: slstatus
	cd sources/git.sr.ht/danieljamespost/slstatus && \
		sudo make install
edwood: go
	cd sources/git.sr.ht/danieljamespost/edwood && \
		go build
edwoodinstall: edwood
	cd sources/git.sr.ht/danieljamespost/edwood && \
		go install
nyne: go plan9port
	cd sources/git.sr.ht/danieljamespost/nyne && \
		mk
nyneinstall: nyne
	cd sources/git.sr.ht/danieljamespost/nyne && \
		installdir=$(nbin) mk install
	ln -s $(shell pwd)/p9p/nyne $(HOME)/.config/nyne

rc: libs
	cd sources/git.sr.ht/danieljamespost/rc && \
		./boostrap &&
		./configure --with-edit=readline && \
		make
rcinstall: rc
	cd sources/git.sr.ht/danieljamespost/rc && \
		sudo make install

# emersion
mrsh:
	cd sources/git.sr.ht/emersion/mrsh && \
		./configure && \
		make
mrshinstall: mrsh
	cd sources/git.sr.ht/emersion/mrsh && \
		sudo make install

# sircmpwn
aerc: go
	cd sources/git.sr.ht/sircmpwn/aerc && \
		make
aercinstall: aerc
	cd sources/git.sr.ht/sircmpwn/aerc && \
		sudo make install

###########################
#        Github
###########################

# fhs
acmelsp: go
	cd sources/github.com/fhs/acme-lsp && \
		go build ./cmd/acme-lsp && \
		go build ./cmd/L
acmelspinstall: acmelsp
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
		&& go build
terraforminstall: terraform
	cd sources/github.com/hashicorp/terraform \
		&& go install

# magicant
yash: libs
	cd sources/github.com/magicant/yash && \
		./configure && \
		make
yashinstall: yash
	cd sources/github.com/magicant/yash && \
		sudo make install && \
		sudo sh -c "echo '/usr/local/bin/yash' >> /etc/shells" && \
		chsh -s /usr/local/bin/yash $(user)

# vim
vim: libs
	cd sources/github.com/vim/vim && \
		./configure --enable-fontset --with-x --with-features=normal && \
		make
viminstall: vim
	cd sources/github.com/vim/vim && \
		sudo make install
	ln -s $(shell pwd)/editors/vimrc $(HOME)/.vimrc 

wmaker:
	cd sources/github.com/window-maker/wmaker && \
		./autogen.sh && \
		./configure && make && sudo make install

alacritty:
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
		

###########################
#      repo.or.cz
###########################

nvi:
	cd sources/repo.or.cz/nvi/dist && \
		./distrib
	cd sources/repo.or.cz/nvi/build.unix && \
		../dist/configure --enable-widechar && \
		make
nviinstall:
	cd sources/repo.or.cz/nvi/build.unix && \
		sudo make install && \
		sudo ln -sfn /usr/local/bin/vi /bin/vi
	ln -s $(shell pwd)/editors/exrc $(HOME)/.exrc 

