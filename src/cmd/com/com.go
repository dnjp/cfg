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
	cmt  string
	scom string
	ecom string
	fch  int
	mp   bool
	ml   bool
	op   op
}

func getop(lines []string, opt opt) op {
	commented := 0
	ncommented := 0
	for _, line := range lines {
		opt.fch = firstchar(line)
		if opt.hascomment(line) {
			commented++
		} else {
			ncommented++
		}
	}
	if ncommented > commented {
		return COMMENT
	}
	return UNCOMMENT
}

func (o opt) hascomment(line string) bool {
	if o.mp {
		return hasmulticomment(line, o)
	}
	return hassinglecomment(line, o)
}

func (o opt) comment(line string) string {
	if o.mp {
		return multicomment(line, o)
	}
	return singlecomment(line, o)
}

func hasmulticomment(line string, opt opt) bool {
	hbegin := strings.Contains(line, opt.scom)
	hend := strings.Contains(line, opt.ecom)
	return hbegin && hend
}

func multicomment(line string, opt opt) string {
	switch opt.op {
	case COMMENT:
		// multi comments generally cannot handle nesting,
		// so return the line as-is if it is already commented
		if hasmulticomment(line, opt) {
			return line
		}
		return line[:opt.fch] + opt.scom + line[opt.fch:] + opt.ecom
	case UNCOMMENT:
		nline := strings.Replace(line, opt.scom, "", 1)
		nline = strings.Replace(nline, opt.ecom, "", 1)
		return nline
	default:
		return ""
	}
}

func hassinglecomment(line string, opt opt) bool {
	if len(line) < opt.fch+len(opt.cmt) {
		return false
	}
	return line[opt.fch:opt.fch+len(opt.cmt)] == opt.cmt
}

func singlecomment(line string, opt opt) string {
	switch opt.op {
	case COMMENT:
		return line[:opt.fch] + opt.cmt + line[opt.fch:]
	case UNCOMMENT:
		return strings.Replace(line, opt.cmt, "", 1)
	default:
		return ""
	}
}

func firstchar(line string) int {
	fch := 0
	for _, ch := range line {
		if ch == ' ' || ch == '\t' {
			fch++
			continue
		}
		break
	}
	return fch
}

func com(lines []string, opt opt) string {
	nlines := []string{}
	for _, line := range lines {
		opt.fch = firstchar(line)
		var nline string
		if len(line) == 0 {
			nline = line
		} else {
			nline = opt.comment(line)
		}
		nlines = append(nlines, nline)
	}
	out := strings.Join(nlines, "\n")
	if out[len(out)-1] == '\n' {
		out = out[:len(out)-1]
	}
	return out
}

func main() {
	filename := flags.Filename
	flag.Parse()
	if len(*filename) == 0 {
		panic("filename not provided with -f flag")
	}
	ft := config.GetFT(*filename, config.SHELL)
	in, err := pipe.In()
	if err != nil {
		panic(err)
	}
	lines := strings.Split(string(in), "\n")

	opt := opt{
		cmt: ft.CmtStyle,
		ml:  len(lines) > 1,
	}

	parts := strings.Split(strings.TrimSuffix(opt.cmt, " "), " ")
	opt.mp = len(parts) > 1
	if opt.mp {
		opt.scom = parts[0] + " "
		opt.ecom = " " + parts[1]
	}
	opt.op = getop(lines, opt)
	pipe.Out(com(lines, opt))
}

