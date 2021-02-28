# Configuration

This is the configuration I use on all of my machines which will install the
following programs:

- [go](https://github.com/golang/go)
  - [gotools](https://github.com/golang/tools)
  - [golint](https://github.com/golang/lint/golint)
  - [staticcheck](https://github.com/dominikh/go-tools)
  - [fonts](https://blog.golang.org/go-fonts)
- [rust](https://github.com/rust-lang/rust)
- [curl](https://github.com/curl/curl)
- [bash](https://git.savannah.gnu.org/bash)
- [meslo fonts](https://github.com/andreberg/Meslo-Font)
- [alacritty](https://github.com/alacritty/alacritty)
- [vim](https://github.com/vim/vim)
- [tmux](https://github.com/tmux/tmux)
- [redshift](https://github.com/jonls/redshift)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [ctags](https://github.com/universal-ctags/ctags)
- [exercism](https://github.com/exercism/cli)
- [nvm](https://github.com/nvm-sh/nvm)
- [prettier](https://github.com/prettier/prettier)
- [fzf](https://github.com/junegunn/fzf)

The following dependencies are required:

- [intltool](https://freedesktop.org/wiki/Software/intltool/)
- [autotools](https://www.gnu.org/software/automake/faq/autotools-faq.html#How-do-I-install-the-Autotools-_0028as-user_0029_003f)
- [cmake](https://cmake.org/)
- [libx11](https://packages.debian.org/search?keywords=libx11-dev)
- [libxtst](https://packages.debian.org/sid/libxtst-dev)
- [libxi](https://packages.debian.org/search?keywords=libxi-dev)

After installation is complete, this is the file tree that will be setup in your
home directory:

```
├── bin            // shell scripts & executables
│   ├── amd64
│   └── sh
├── cfg            // this repository
├── go             // GOPATH
├── personal       // directory for personal projects
├── src            // code for utilities that end up in bin
├── tmp            // directory for temporary files
└── work           // directory for work related projects
```

## Installation

First, clone the repo:

```
$ git clone https://github.com/dnjp/cfg.git --recurse-submodules
```

Then, simply run `make` to install everything

## Other Applications

### PDF Readers

- [Okular](https://okular.kde.org/)
