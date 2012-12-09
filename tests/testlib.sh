#!/bin/bash

#    Copyright 2008-2009 Canonical Ltd.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3,
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

sed -i 's/do_checks = True/do_checks = False/' $TESTPATH/lib/python/ufw/backend.py
cp tests/defaults/profiles/* $TESTPATH/etc/ufw/applications.d

let count=0
do_cmd() {
	if [ "$1" = "0" ] || [ "$1" = "1" ]; then
		expected="$1"
		shift
	fi

	do_stats="yes"
	cmd_results_file="$TESTTMP/result"
	if [ "$1" = "null" ]; then
		cmd_results_file="/dev/null"
		shift
	elif [ "$1" = "nostats" ]; then
		do_stats="no"
		cmd_results_file="/dev/null"
		shift
	fi

	# Some systems now have http/udp as valid, but not www/udp instead of
	# the other way around (eg Debian netbase 4.47). Try to account for
	# that.
	modified_args=
	if [ "$1" = "http-or-www" ]; then
		shift
		if egrep -q '^http\s+80/udp' /etc/services ; then
			modified_args=`echo $@ | sed 's/ http *$/ www/'`
		fi
	fi

	echo "$count: $@" >> $TESTTMP/result

	# Some tests require the quoting behavior that the shell gives us
	# with "$@", so only use $modified_args if we have to.
	if [ -z "$modified_args" ]; then
		$TESTPATH/usr/sbin/ufw "$@" >> $cmd_results_file 2>&1
	else
		$TESTPATH/usr/sbin/ufw $modified_args >> $cmd_results_file 2>&1
	fi
	rc="$?"
	if [ "$rc" != "$expected" ]; then
		echo "Command '$@' exited with '$rc', but expected '$expected'"
		exit 1
	fi
        let count=count+1
        echo "" >> $TESTTMP/result
        echo "" >> $TESTTMP/result

	if [ "$do_stats" = "yes" ]; then
        	individual=$(cat $statsdir/individual)
        	let individual=individual+1
        	echo $individual > $statsdir/individual
	fi
}

do_extcmd() {
	if [ "$1" = "0" ] || [ "$1" = "1" ]; then
		expected="$1"
		shift
	fi

	do_stats="yes"
	cmd_results_file="$TESTTMP/result"
	if [ "$1" = "null" ]; then
		cmd_results_file="/dev/null"
		shift
	elif [ "$1" = "nostats" ]; then
		do_stats="no"
		cmd_results_file="/dev/null"
		shift
	fi

       	echo "$count: $@" >> $TESTTMP/result
        $@ >> $cmd_results_file 2>&1
	rc="$?"
	if [ "$rc" != "$expected" ]; then
		echo "Command '$@' exited with '$rc', but expected '$expected'"
		exit 1
	fi
        let count=count+1
        echo "" >> $TESTTMP/result
        echo "" >> $TESTTMP/result

	if [ "$do_stats" = "yes" ]; then
        	individual=$(cat $statsdir/individual)
        	let individual=individual+1
        	echo $individual > $statsdir/individual
	fi
}

cleanup() {
    do_cmd "0" nostats disable
    $TESTSTATE/ufw-init flush-all
}

