package flags

import "flag"

var Filename = flag.String("f", "", "file name to operate on")
var Word = flag.String("w", "", "word to complete")
var Unindent = flag.Bool("u", false, "unindent the buffer")
