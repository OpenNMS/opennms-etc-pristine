#!/bin/bash

MYDIR=`dirname $0`
ME=`cd $MYDIR; pwd`

if [ -z "$1" ]; then
	echo "usage: $0 [debs]"
	exit 1
fi

mkdir -p $ME/work
pushd $ME/work >/dev/null 2>&1

	rm -rf $ME/work/*
	for file in "$@"; do
		ar x "$file"
		tar -xzf data.tar.gz
	done
	if [ -d "$ME/work/etc/opennms/" ]; then
		rsync -avr --delete $ME/work/etc/opennms/ $ME/etc/
	fi

popd >/dev/null 2>&1

echo "your files in $ME/etc/ are updated"
