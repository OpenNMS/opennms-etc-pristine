#!/bin/bash

MYDIR=`dirname $0`
ME=`cd $MYDIR; pwd`
MAJOR="${VERSION%%.*}"

if [ -z "$1" ]; then
	echo "usage: $0 [debs]"
	exit 1
fi

set -e

mkdir -p $ME/work
pushd $ME/work >/dev/null 2>&1 || exit 1

	rm -rf $ME/work/*
	for file in "$@"; do
		ar x "$file"
		if [ -e data.tar.gz ]; then
			tar -xzf data.tar.gz
		elif [ -e data.tar.xz ]; then
			tar -xJf data.tar.xz
                elif [ -e data.tar.zst ]; then
                        tar --use-compress-program=unzstd -xvf data.tar.zst
                fi
	done
	if [ -d "$ME/work/etc/opennms/" ]; then
		rsync -avr --delete $ME/work/etc/opennms/ $ME/etc/
	elif [ -d "$ME/work/opt/opennms/etc/" ]; then
		if [ "$MAJOR" -ge 35 ]; then
			rsync -avr --delete $ME/work/opt/opennms/etc/ $ME/etc/
		fi
	fi

popd >/dev/null 2>&1

echo "your files in $ME/etc/ are updated"
