#!/bin/sh

MYDIR=`dirname $0`
ME=`cd $MYDIR; pwd`

if [ -z "$1" ]; then
	echo "usage: $0 [rpms]"
	exit 1
fi

mkdir -p $ME/work
pushd $ME/work >/dev/null 2>&1

	rm -rf $ME/work/*
	for file in "$@"; do
		rpm2cpio "$file" | cpio -id
	done
	if [ -d "$ME/work/opt/opennms/etc/" ]; then
		rsync -avr --delete $ME/work/opt/opennms/etc/ $ME/etc/
	fi
	if [ -d "$ME/work/opt/OpenNMS/etc/" ]; then
		rsync -avr --delete $ME/work/opt/OpenNMS/etc/ $ME/etc/
	fi

popd >/dev/null 2>&1

echo "your files in $ME/etc/ are updated"
