#!/bin/sh

#    Copyright 2010 Canonical Ltd.
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
#
#    WARNING: this script is not for production use. It's intended use is
#    for debugging.

set -e

read_stdin=""
if [ -n "$1" ] && [ "$1" = "--read-stdin" ]; then
    read_stdin="yes"
    shift
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <cmd> <args>" >&2
    exit 1
fi

echo "Wrapped command: $*" >&2
echo "" >&2

if [ "$read_stdin" = "yes" ]; then
    input=`cat`
    echo "Command input:" >&2
    echo "$input" >&2
    echo "" >&2
fi

ret="0"
out=""
echo "Command output:" >&2
if [ "$read_stdin" = "yes" ]; then
    out=`echo "$input" | $* 2>&1` || ret="$?"
else
    out=`$* 2>&1` || ret="$?"
fi

echo "$out"

echo "" >&2
if [ "$ret" != "0" ]; then
    echo "Exited non-zero: $ret" >&2
else
    echo "Exited with zero (success)" >&2
fi

exit $ret

