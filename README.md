# Configuration

This is the configuration I use for development on MacOS.

After installation is complete, this is the file tree that will be setup in your
home directory:

```
├── bin            // shell scripts & executables
│   ├── amd64        // x86 binaries
│   ├── arm64        // arm binaries
│   └── sh           // shell scripts
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

## plan9port

### MacOS Permissions

`/bin/bash` is the parent process that launches acme, sam, 9term, etc. In order
to view all files in the system, you must grant `/bin/bash` full disk access in
"Security & Privacy" settings.
