package config

import (
	"strings"
)

type Settings struct {
	Ftypes map[string]FT
}

type FT struct {
	Indent    int
	Tabexpand bool
	CmtStyle  string
}

func GetExt(in string) string {
	filename := GetFilename(in)
	if !strings.Contains(filename, ".") {
		return filename
	}
	pts := strings.Split(filename, ".")
	if len(pts) == len(in) {
		return ""
	}
	return "." + pts[len(pts)-1]
}

func GetFT(in string, def FT) FT {
	ext := GetExt(in)
	if len(ext) == 0 {
		return def
	}
	v, ok := S.Ftypes[ext]
	if !ok {
		return def
	}
	return v
}

func GetFilename(in string) string {
	path := strings.Split(in, "/")
	return path[len(path)-1]
}

var C = FT{
	Indent:    8,
	Tabexpand: false,
	CmtStyle:  "/* */",
}

var SHELL = FT{
	Indent:    8,
	Tabexpand: false,
	CmtStyle:  "# ",
}

var CPP = FT{
	Indent:    4,
	Tabexpand: true,
	CmtStyle:  "// ",
}

var GO = FT{
	Indent:    8,
	Tabexpand: false,
	CmtStyle:  "// ",
}

var JAVA = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "// ",
}

var JS = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "// ",
}

var MD = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "",
}

var TF = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "# ",
}

var YAML = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "# ",
}

var HTML = FT{
	Indent:    2,
	Tabexpand: true,
	CmtStyle:  "<!-- -->",
}

var S = Settings{
	Ftypes: map[string]FT{
		".cc":      CPP,
		".hh":      CPP,
		".cxx":     CPP,
		".hxx":     CPP,
		".cpp":     CPP,
		".hpp":     CPP,
		".c":       C,
		".h":       C,
		".go":      GO,
		".js":      JS,
		".ts":      JS,
		".json":    JS,
		".java":    JAVA,
		".tf":      TF,
		".sh":      SHELL,
		".rc":      SHELL,
		"Makefile": SHELL,
		".md":      MD,
		".html":    HTML,
	},
}
