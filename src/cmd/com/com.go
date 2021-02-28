package main

import (
	"flag"
	"src/config"
	"src/flags"
	"src/pipe"
	"strings"
)

type op int

const (
	COMMENT op = iota
	UNCOMMENT
)

type opt struct {
	ft   config.FT
	scom string
	ecom string
	fch  int
	mp   bool
	op   op
}

func (o opt) setop(lines []string) {
	var commented, ncommented int
	for _, line := range lines {
		o.fch = firstchar(line)
		if o.hascomment(line) {
			commented++
		} else {
			ncommented++
		}
	}
	if ncommented > commented {
		o.op = COMMENT
		return
	}
	o.op = UNCOMMENT
}

func (o opt) hascomment(line string) bool {
	if o.mp {
		hbegin := strings.Contains(line, o.scom)
		hend := strings.Contains(line, o.ecom)
		return hbegin && hend
	}
	if len(line) < o.fch+len(o.ft.Comment) {
		return false
	}
	return line[o.fch:o.fch+len(o.ft.Comment)] == o.ft.Comment
}

func (o opt) comment(line string) string {
	if o.mp {
		return o.multicomment(line)
	}
	return o.singlecomment(line)
}

func (o opt) multicomment(line string) string {
	switch o.op {
	case COMMENT:
		// multi comments generally cannot handle nesting,
		// so return the line as-is if it is already commented
		if o.hascomment(line) {
			return line
		}
		return line[:o.fch] + o.scom + line[o.fch:] + o.ecom
	case UNCOMMENT:
		nline := strings.Replace(line, o.scom, "", 1)
		nline = strings.Replace(nline, o.ecom, "", 1)
		return nline
	default:
		return ""
	}
}

func (o opt) singlecomment(line string) string {
	switch o.op {
	case COMMENT:
		return line[:o.fch] + o.ft.Comment + line[o.fch:]
	case UNCOMMENT:
		return strings.Replace(line, o.ft.Comment, "", 1)
	default:
		return ""
	}
}

func (o opt) com(lines []string) string {
	var nlines []string
	var nline, out string
	o.setop(lines)
	for _, line := range lines {
		o.fch = firstchar(line)
		if len(line) == 0 {
			nline = line
		} else {
			nline = o.comment(line)
		}
		nlines = append(nlines, nline)
	}
	out = strings.Join(nlines, "\n")
	if out[len(out)-1] == '\n' {
		out = out[:len(out)-1]
	}
	return out
}

func firstchar(line string) int {
	var fch int
	for _, ch := range line {
		if ch == ' ' || ch == '\t' {
			fch++
			continue
		}
		break
	}
	return fch
}

func main() {
	var opt opt
	var filename *string
	var lines, parts []string
	filename = flags.Filename
	flag.Parse()
	if len(*filename) == 0 {
		panic("filename not provided with -f flag")
	}
	opt.ft = config.GetFT(*filename, config.SHELL)
	in, err := pipe.In()
	if err != nil {
		panic(err)
	}
	lines = strings.Split(string(in), "\n")
	parts = strings.Split(strings.TrimSuffix(opt.ft.Comment, " "), " ")
	opt.mp = len(parts) > 1
	if opt.mp {
		opt.scom = parts[0] + " "
		opt.ecom = " " + parts[1]
	}
	pipe.Out(opt.com(lines))
}
