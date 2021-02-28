package main

import (
	"flag"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"sort"
)

var depth = flag.Int("d", -1, "depth of tree to generate")

func getpath(args []string) (string, error) {
	base, err := os.Getwd()
	if err != nil {
		return "", err
	}

	if len(args) == 0 {
		return base, nil
	}

	pargs := args[len(args)-1]
	if filepath.IsAbs(pargs) {
		return pargs, nil
	}

	p, err := filepath.Abs(
		path.Clean(fmt.Sprintf(
			"%s/%s",
			base,
			args[len(args)-1],
		)),
	)
	if err != nil {
		return "", err
	}
	return p, nil
}

func tree(base string, prefix string, d int) {
	if d == *depth {
		return
	}
	file, err := os.Open(base)
	if err != nil {
		return
	}
	names, _ := file.Readdirnames(0)
	file.Close()
	sort.Strings(names)
	for i, name := range names {
		sub := path.Join(base, name)
		var pre string
		if i == len(names)-1 {
			fmt.Println(prefix+"└──", name)
			pre = prefix + "    "
		} else {
			fmt.Println(prefix+"├──", name)
			pre = prefix + "│   "
		}
		tree(sub, pre, d+1)
	}
}

func main() {
	flag.Parse()
	p, err := getpath(flag.Args())
	if err != nil {
		panic(err)
	}
	tree(p, "", 0)
}
