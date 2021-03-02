package main

import (
	"src/config"
	"src/flags"
	"src/pipe"

	"flag"
	"strings"
)

func indent(line string, te bool, len int) string {
	var tab string
	if te {
		for i := 0; i < len; i++ {
			tab += " "
		}
		return tab + line
	}
	return "\t" + line
}

func unindent(line string, te bool, len int) string {
	var tab string
	if te {
		for i := 0; i < len; i++ {
			tab += " "
		}
		return strings.Replace(line, tab, "", 1)
	}
	return strings.Replace(line, "\t", "", 1)
}

func main() {
	var filename *string
	var ui *bool
	var ft config.FT
	var lines []string
	var nlines []string
	var out string

	filename = flags.Filename
	ui = flags.Unindent
	flag.Parse()

	if len(*filename) == 0 {
		panic("filename not provided with -f flag")
	}
	ft = config.GetFT(*filename, config.SHELL)
	in, err := pipe.In()
	if err != nil {
		panic(err)
	}

	lines = strings.Split(string(in), "\n")
	for _, line := range lines {
		if len(line) == 0 {
			nlines = append(nlines, line)
			continue
		}
		if *ui {
			nlines = append(nlines, unindent(
				line,
				ft.Tabexpand,
				ft.Indent,
			))
		} else {
			nlines = append(nlines, indent(
				line,
				ft.Tabexpand,
				ft.Indent,
			))
		}
	}
	out = strings.Join(nlines, "\n")
	if out[len(out)-1] == '\n' {
		out = out[:len(out)-1]
	}
	pipe.Out(out)
}
