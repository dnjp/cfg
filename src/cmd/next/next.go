package main

import (
	"src/flags"
	"src/pipe"

	"flag"
	"sort"
	"strings"
	"unicode"
)

func main() {
	var word *string
	var lines []string
	var m map[string]bool

	m = make(map[string]bool)
	word = flags.Word
	flag.Parse()

	if len(*word) == 0 {
		panic("word not provided")
	}

	in, err := pipe.In()
	if err != nil {
		panic(err)
	}
	lines = strings.Split(string(in), "\n")

	// evaluate each line
eline:
	for _, line := range lines {
		if !strings.Contains(line, *word) {
			continue
		}
		// evaluate each character of the line
		for i := 0; i < len(line); i++ {
			if i+len(*word) > len(line) {
				// we have not found match
				continue eline
			}
			pmatch := line[i : i+len(*word)]
			if pmatch != *word {
				continue
			}
			// get rest of the word
			var vmatch []byte
			for j := i; j < len(line) && unicode.IsLetter(rune(line[j])); j++ {
				vmatch = append(vmatch, line[j])
			}
			m[string(vmatch)] = true
		}
	}
	matches := []string{}
	for k := range m {
		matches = append(matches, k)
	}
	sort.Strings(matches)
	nmatch := strings.Replace(matches[0], *word, "", 1)
	if len(matches) > 0 {
		pipe.Out(nmatch)
	}
}
