#!/bin/bash

#    Copyright 2008 Canonical Ltd.
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

let count=0
do_cmd() {
        if [ "$1" = "0" ] || [ "$1" = "1" ]; then
                expected="$1"
                shift
        fi

        cmd_results_file="$TESTTMP/result"
        if [ "$1" = "null" ]; then
                cmd_results_file="/dev/null"
                shift
        fi

        echo "$count: $@" >> $TESTTMP/result
        $script $@ >> $cmd_results_file 2>&1
        rc="$?"
        if [ "$rc" != "$expected" ]; then
                echo "Command '$@' exited with '$rc', but expected '$expected'"
                exit 1
        fi
        let count=count+1
        echo "" >> $TESTTMP/result
        echo "" >> $TESTTMP/result

        individual=$(cat $statsdir/individual)
        let individual=individual+1
        echo $individual > $statsdir/individual
}

# if running manually, do:
# cd tests/testarea
# PYTHONPATH="`pwd`/lib/python" python ./test_util.py ...
script="tests/testarea/test_normalization.py"
cat > $script << EOM
#! /usr/bin/env $interpreter

import sys
import ufw.util

if len(sys.argv) != 3:
    print >> sys.stderr, "Wrong number of args: %d" % (len(sys.argv))
    sys.exit(1)

v6 = False
if sys.argv[1] == "yes":
    v6 = True

orig = sys.argv[2]
dotted = ufw.util._cidr_to_dotted_netmask(orig, v6)
reverse = ufw.util._dotted_netmask_to_cidr(dotted, v6)

print "orig = '%s', dotted = '%s', reverse = '%s'" % (orig, dotted, reverse)
if orig != reverse:
    sys.exit(1)

sys.exit(0)
EOM
chmod 755 $script

echo "TEST REVERSE NETMASK CONVERSIONS" >> $TESTTMP/result
echo "TEST IPv6 CIDR" >> $TESTTMP/result
for i in $(seq 0 32); do
    do_cmd "0" no $i
done

exit 0
