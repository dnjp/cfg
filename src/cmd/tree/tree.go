package main

import (
	"flag"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"sort"
)

var N = flag.Int("n", -1, "depth of tree to generate")
var dirs = flag.Bool("d", false, "whether to only print directories")

func getpath(args []string) (string, error) {
	var base, pargs string
	var err error
	base, err = os.Getwd()
	if err != nil {
		return "", err
	}
	if len(args) == 0 {
		return base, nil
	}
	pargs = args[len(args)-1]
	if filepath.IsAbs(pargs) {
		return pargs, nil
	}
	pargs, err = filepath.Abs(
		path.Clean(fmt.Sprintf(
			"%s/%s",
			base,
			args[len(args)-1],
		)),
	)
	if err != nil {
		return "", err
	}
	return pargs, nil
}

func tree(base string, prefix string, pd bool, n int) {
	var file *os.File
	var names []string
	var err error
	if n == *N {
		return
	}
	file, err = os.Open(base)
	if err != nil {
		return
	}
	names, _ = file.Readdirnames(0)
	file.Close()
	sort.Strings(names)
	for i, name := range names {
		var pre, sub string
		sub = path.Join(base, name)
		if pd {
			file, err = os.Open(sub)
			if err != nil {
				panic(err)
			}
			info, err := file.Stat()
			if err != nil {
				panic(err)
			}
			file.Close()
			if !info.IsDir() {
				continue
			}
		}

		if i == len(names)-1 {
			fmt.Println(prefix+"└──", name)
			pre = prefix + "    "
		} else {
			fmt.Println(prefix+"├──", name)
			pre = prefix + "│   "
		}
		tree(sub, pre, pd, n+1)
	}
}

func main() {
	flag.Parse()
	p, err := getpath(flag.Args())
	if err != nil {
		panic(err)
	}
	tree(p, "", *dirs, 0)
}
