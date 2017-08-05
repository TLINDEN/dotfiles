#!/bin/sh
if=$1
ask=$2

check() {
    if ifconfig $if | egrep -i "(down|no carrier)" > /dev/null 2>&1; then
	echo down
    elif ifconfig $if | grep -i up > /dev/null 2>&1; then
	echo up
    else
	echo down
    fi
}

state=`check`

if test "$state" = "up" -a "$ask" = "up"; then
    echo up
fi

if test "$state" = "down" -a "$ask" = "down"; then
    echo down
fi

