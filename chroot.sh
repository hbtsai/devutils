#!/bin/sh

TARGET=$1

quit()
{
	echo $1
	exit 1
}

sanity_check()
{
	[ -z $TARGET ] && quit "usage: $0 directory"
	[ -d $TARGET ] || quit "cannot found directory!"
	[ -f $TARGET/bin/bash ] || quit "cannot find /bin/bash in target directory!"
}

mount_sysfs()
{
MOUNTS=`grep $TARGET/proc /proc/mounts`
echo $MOUNTS
if [ -z "$MOUNTS" ] ; then
	if [ -z "`grep $TARGET /proc/mounts | grep proc`"	] ; then
	#	`grep $TARGET /proc/mounts | grep proc | awk '{print $2}' | xargs sudo umount`
		sudo mount -t proc proc $TARGET/proc
	fi
	if [ -z	"`grep $TARGET /proc/mounts | grep sysfs`" ] ; then
	#	`grep $TARGET /proc/mounts | grep sysfs | awk '{print $2}' | xargs sudo umount`
		sudo mount -t sysfs sysfs $TARGET/sys
	fi
fi
}

sanity_check
mount_sysfs

COUNT=0
HOME=/root sudo chroot $TARGET /bin/bash

for i in `ps aux | grep "$TARGET" | grep -v grep ` ; do
	if [ "$i" = "$TARGET" ] ; then
		COUNT=`expr $COUNT + 1`
	fi
done

MOUNTS=`grep $TARGET /proc/mounts`
if [ $COUNT -eq 2 ] && [ -n "$MOUNTS" ] ; then
	if [ -n "`grep $TARGET /proc/mounts | grep proc`"	] ; then
		`grep $TARGET /proc/mounts | grep proc | awk '{print $2}' | xargs sudo umount`
	fi
	if [ -n	"`grep $TARGET /proc/mounts | grep sysfs`" ] ; then
		`grep $TARGET /proc/mounts | grep sysfs | awk '{print $2}' | xargs sudo umount`
	fi
	if [ -n	"`grep $TARGET /proc/mounts | grep nfs`" ] ; then
		`grep $TARGET /proc/mounts | grep nfs | awk '{print $2}' | xargs sudo umount`
	fi
	if [ -n	"`grep $TARGET /proc/mounts | grep cifs`" ] ; then
		`grep $TARGET /proc/mounts | grep cifs | awk '{print $2}' | xargs sudo umount`
	fi
fi

if [ $COUNT -gt 2 ] ; then
	echo '\033[41m \033[37m'"**** WARNING: there are filesystem still mounted ****"'\033[0m'
else
	echo '\033[32m'"**** SUCCESS: now your are safely exited ****"'\033[0m'
fi
