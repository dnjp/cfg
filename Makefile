all: plan9port \
      go \
      rust \
      bash \
      meslo \
      vim \
      alacritty \
      ripgrep \
      edwood \
      nyne \
      editinacme \
      acmelsp \
      aerc \
      terraform \
      gcloud \
      tmux \
      ctags \
      linkerd \
      kubectl \
      golint \
      staticcheck

###########################
#      Variables
###########################

SHELL := /bin/bash
PROFILE := "~/.yashrc"

# pkgsrc
BOOTSTRAP_TAR := bootstrap-el7-trunk-x86_64-20200724.tar.gz
BOOTSTRAP_SHA := 478d2e30f150712a851f8f4bcff7f60026f65c9e
PKGS := $(shell cat ./PKGS)

# set path for plan9 and go
export PATH := $(PATH):/usr/local/plan9/bin:/usr/local/go/bin:/usr/pkg/bin/:/usr/pkg/gcc10/bin

user=daniel
nbin=/home/daniel/bin
goversion=1.14.7


###########################
#         Deps
###########################

git:
	ssh-keygen -t ed25519 -C "danieljamespost@posteo.net"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa
	ln -s $(shell pwd)/git/gitconfig $(HOME)/.gitconfig
	echo
	echo
	cat ~/.ssh/id_rsa.pub
	echo
	echo "copy the above and add it to git providers"

pkgsrc:
ifeq ($(wildcard /usr/pkg/.*),)
	echo "installing pkgsrc..." 
	curl -o /tmp/${BOOTSTRAP_TAR} https://pkgsrc.joyent.com/packages/Linux/el7/bootstrap/${BOOTSTRAP_TAR} 
	sudo tar -zxpf /tmp/${BOOTSTRAP_TAR} -C / 
endif
		sudo /usr/pkg/bin/pkgin -y update && \
		sudo /usr/pkg/bin/pkgin -y upgrade && \
		sudo /usr/pkg/bin/pkgin -y install ${PKGS}

go:
ifeq ($(wildcard /usr/local/go/.*),)
	cd /tmp && \
		curl -OL https://golang.org/dl/go$(goversion).linux-amd64.tar.gz && \
		sudo tar -C /usr/local -xzf go*.tar.gz
endif

plan9port:
ifeq ($(wildcard /usr/local/go/.*),)
	cd sources/git.sr.ht/danieljamespost/plan9port && \
		./PREINSTALL 
	ifeq ($(wildcard $(HOME)/lib/.*),)
		ln -s $(shell pwd)/p9p/lib $(HOME)/lib 
	endif
	ifeq ($(wildcard $(HOME)/bin/.*),)
		ln -s $(shell pwd)/p9p/bin $(HOME)/bin 
	endif
	ifeq ($(wildcard $(HOME)/mail/.*),)
		ln -s $(shell pwd)/p9p/mail $(HOME)/mail 
	endif
	ifeq ($(wildcard $(HOME)/.msmtprc/),)
		ln -s $(shell pwd)/p9p/mail/msmtprc $(HOME)/.msmtprc
	endif
endif

rust:
ifeq ($(shell command -v cargo 2> /dev/null),)
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

gcloud: bash
ifeq ($(shell command -v gcloud 2> /dev/null),)
	curl https://sdk.cloud.google.com | bash
endif

###########################
#        adhoc
###########################

kubectl:
	curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
	chmod +x /tmp/kubectl
	sudo mv /tmp/kubectl /usr/local/bin/kubectl

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
	ln -s $(shell pwd)/p9p/nyne $(HOME)/.config/nyne
	cd sources/git.sr.ht/danieljamespost/nyne && \
		mk && \
		installdir=$(nbin) mk install 

rc: 
	cd sources/git.sr.ht/danieljamespost/rc && \
		./boostrap &&
		./configure --with-edit=readline && \
		make && \
		sudo make install

noice:
	cd sources/git.sr.ht/danieljamespost/noice && \
		make && \
		sudo make install

# emersion
mrsh:
	cd sources/git.sr.ht/emersion/mrsh && \
		./configure && \
		make && \
		sudo make install

# sircmpwn
scdoc:
	cd sources/git.sr.ht/sircmpwn/scdoc && \
		make && \
		sudo make install

aerc: go scdoc
	cd sources/git.sr.ht/sircmpwn/aerc && \
		make && \
		sudo make install
	mkdir -p $(HOME)/.config/aerc
	ln -s $(shell pwd)/email/aerc/aerc.conf $(HOME)/.config/aerc/aerc.conf
	ln -s $(shell pwd)/email/aerc/binds.conf $(HOME)/.config/aerc/binds.conf

###########################
#        Github
###########################

acmelsp: go
	cd sources/github.com/fhs/acme-lsp && \
		go install ./cmd/acme-lsp && \
		go install ./cmd/L 
	ln -s $(shell pwd)/p9p/lsp $(HOME)/.config/acme-lsp 

terraform: go
	cd sources/github.com/hashicorp/terraform \
		&& git clean -f -d \
		&& git reset --hard \
		&& git checkout master \
		&& git pull \
		&& git checkout v0.13.1 \
		&& go mod vendor \
		&& go install

yash: 
	cd sources/github.com/magicant/yash && \
		./configure && \
		make && \
		sudo make install 
	sudo sh -c "echo '/usr/local/bin/yash' >> /etc/shells" && \
	chsh -s /usr/local/bin/yash $(user)

vim: 
	cd sources/github.com/vim/vim && \
		./configure \
			--enable-fontset \
			--disable-gpm \
			--enable-multibyte \
			--with-x \
			--with-features=normal && \
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
	cd sources/github.com/jonls/redshift && \
		./bootstrap.sh && \
		./configure && \
		make && \
		sudo make install
ripgrep:
	cd sources/github.com/BurntSushi/ripgrep && \
		cargo build --release && \
		sudo cp ./target/release/rg /usr/local/bin/ 

libetpan:
	cd sources/github.com/dinhvh/libetpan && \
		./autogen.sh && \
		make && \
		sudo make install
editinacme:
	cd sources/github.com/9fans/go && \
		go install acme/editinacme/main.go

tmux:
	cd sources/github.com/tmux/tmux && \
		sh ./autogen.sh && \
		./configure && \
		make && \
		sudo make install
	ln -s $(shell pwd)/term/tmux/tmux.conf $(HOME)/.tmux.conf

ctags:
	cd sources/github.com/universal-ctags/ctags && \
		sh ./autogen.sh && \
		./configure && \
		make && \
		sudo make install
	mkdir -p $(HOME)/.config/ctags
	ln -s $(shell pwd)/editors/ctags $(HOME)/.config/ctags/ctags

linkerd:
	cd sources/github.com/linkerd/linkerd2 && \
		git clean -f -d && \
		git reset --hard && \
		git checkout main && \
		git pull && \
		git checkout stable-2.8.1 && \
		go build -o linkerd cli/main.go && \
		sudo cp ./linkerd /usr/local/bin/linkerd

golint:
	cd sources/github.com/golang/lint/golint && \
		go install

staticcheck:
	cd sources/github.com/dominikh/go-tools && \
		go install cmd/staticcheck/staticcheck.go

exercism:
	cd sources/github.com/exercism/cli&& \
		go build -o exercism.bin exercism/main.go && \
		sudo cp ./exercism.bin /usr/local/bin/exercism


###########################
#      repo.or.cz
###########################

nvi:
	cd sources/repo.or.cz/nvi/dist && \
		./distrib
	cd sources/repo.or.cz/nvi/build.unix && \
		../dist/configure \
			--program-prefix=n \
			--enable-widechar && \
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


###########################
#  git.savannah.gnu.org
###########################
bash: 
# ifneq ($(shell command -v bash 2> /dev/null), /usr/bin/bash)
	cd sources/git.savannah.gnu.org/bash && \
		./configure --prefix=/usr \
			--without-bash-malloc \
			--enable-readline && \
		make && \
		sudo make install 

	sudo sh -c "echo '/usr/bin/bash' >> /etc/shells" && \
	chsh -s /usr/bin/bash $(user)
	sudo cp ./shells/bash/system.bashrc /etc/bash.bashrc
	sudo cp ./shells/bash/system.bash_logout /etc/bash.bash_logout

	ln -s $(shell pwd)/shells/bash/bashrc ${HOME}/.bashrc
	ln -s $(shell pwd)/shells/profile ${HOME}/.profile
# endif

###########################
#  go.googlesource.com
###########################

gofonts:
	sudo mkdir -p /usr/share/fonts/go
	sudo cp sources/go.googlesource.com/image/font/gofont/ttfs/* /usr/share/fonts/go/

