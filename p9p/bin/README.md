# Acme Scripts

These scripts are designed for use with the Plan 9 environment ported to Unix called [plan9port](https://9fans.github.io/plan9port/). This repo includes text manipulation, searching, and other utility functions primarily used within Acme.

# Dependencies

- acme-lsp

```
GO111MODULE=on go get github.com/fhs/acme-lsp/cmd/acme-lsp@latest
GO111MODULE=on go get github.com/fhs/acme-lsp/cmd/L@latest
```

- gopls

```
GO111MODULE=on go get golang.org/x/tools/gopls@latest
```

- typescript lsp

```
npm install -g typescript typescript-language-server
```

# Installation

Clone this repo to \$HOME/bin and add it to your path. Then run `make` to build.
