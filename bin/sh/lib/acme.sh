#!/bin/sh

newwin() {
	winctl=$(9p read acme/new/ctl)
	winid=$($winctl | awk '{print $1}')
}

winctl() {	
	echo $* | 9p write acme/$winid/ctl
}

winread() {
	9p read acme/$winid/$1
}

winwrite() {
	9p write acme/$winid/$1
}

# windump: TODO

winname() {
	winctl name $1
}

winwriteevent() {
	echo $1$2$3 $4 | winwrite event
}

# windel: TODO

# wineventloop: TODO

setsel() {
	echo addr=dot | 9p write acme/$winid/ctl
}

readsel() {
	9p read acme/$winid/xdata
}
