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

if len(sys.argv) != 4:
    print >> sys.stderr, "Wrong number of args: %d" % (len(sys.argv))
    print >> sys.stderr, "Usage: %s no|yes <ip> <expected_ip>" % (sys.argv[0])
    sys.exit(1)

v6 = False
if sys.argv[1] == "yes":
    v6 = True

norm=""
changed = False
try:
    (norm, changed) = ufw.util.normalize_address(sys.argv[2], v6)
except:
    print >> sys.stderr, "Invalid address/netmask '%s'" % (sys.argv[2])
    sys.exit(1)

print "norm = %s, expected = %s" % (norm, sys.argv[3])
if sys.argv[3] != norm:
    sys.exit(1)
sys.exit(0)
EOM

chmod 755 $script

echo "TEST HOST NETMASK" >> $TESTTMP/result
do_cmd "0" no 192.168.0.1 192.168.0.1
do_cmd "0" no 192.168.0.1/32 192.168.0.1
do_cmd "0" no 192.168.0.1/255.255.255.255 192.168.0.1
do_cmd "0" yes ::1 ::1
do_cmd "0" yes ::1/128 ::1

echo "TEST NETMASK TO CIDR" >> $TESTTMP/result
do_cmd "0" no 192.168.0.1/255.255.255.255 192.168.0.1
do_cmd "0" no 192.168.0.0/255.255.255.254 192.168.0.0/31
do_cmd "0" no 192.168.0.0/255.255.255.252 192.168.0.0/30
do_cmd "0" no 192.168.0.0/255.255.255.248 192.168.0.0/29
do_cmd "0" no 192.168.0.0/255.255.255.240 192.168.0.0/28
do_cmd "0" no 192.168.0.0/255.255.255.224 192.168.0.0/27
do_cmd "0" no 192.168.0.0/255.255.255.192 192.168.0.0/26
do_cmd "0" no 192.168.0.0/255.255.255.128 192.168.0.0/25
do_cmd "0" no 192.168.0.0/255.255.255.0 192.168.0.0/24
do_cmd "0" no 192.168.0.0/255.255.254.0 192.168.0.0/23
do_cmd "0" no 192.168.0.0/255.255.252.0 192.168.0.0/22
do_cmd "0" no 192.168.0.0/255.255.248.0 192.168.0.0/21
do_cmd "0" no 192.168.0.0/255.255.240.0 192.168.0.0/20
do_cmd "0" no 192.168.0.0/255.255.224.0 192.168.0.0/19
do_cmd "0" no 192.168.0.0/255.255.192.0 192.168.0.0/18
do_cmd "0" no 192.168.0.0/255.255.128.0 192.168.0.0/17
do_cmd "0" no 192.168.0.0/255.255.0.0 192.168.0.0/16
do_cmd "0" no 192.168.0.0/255.254.0.0 192.168.0.0/15
do_cmd "0" no 192.168.0.0/255.252.0.0 192.168.0.0/14
do_cmd "0" no 192.168.0.0/255.248.0.0 192.168.0.0/13
do_cmd "0" no 192.168.0.0/255.240.0.0 192.160.0.0/12
do_cmd "0" no 192.168.0.0/255.224.0.0 192.160.0.0/11
do_cmd "0" no 192.168.0.0/255.192.0.0 192.128.0.0/10
do_cmd "0" no 192.168.0.0/255.128.0.0 192.128.0.0/9
do_cmd "0" no 192.168.0.0/255.0.0.0 192.0.0.0/8
do_cmd "0" no 192.168.0.0/254.0.0.0 192.0.0.0/7
do_cmd "0" no 192.168.0.0/252.0.0.0 192.0.0.0/6
do_cmd "0" no 192.168.0.0/248.0.0.0 192.0.0.0/5
do_cmd "0" no 192.168.0.0/240.0.0.0 192.0.0.0/4
do_cmd "0" no 192.168.0.0/224.0.0.0 192.0.0.0/3
do_cmd "0" no 192.168.0.0/192.0.0.0 192.0.0.0/2
do_cmd "0" no 192.168.0.0/128.0.0.0 128.0.0.0/1
do_cmd "0" no 192.168.0.0/0.0.0.0 0.0.0.0/0

echo "TEST VALID NETMASK TO NON-CIDR" >> $TESTTMP/result
for i in $(seq 1 253); do
    if [ "$i" = "252" ] || [ "$i" = "248" ] || [ "$i" = "240" ] || [ "$i" = "224" ] || [ "$i" = "192" ] || [ "$i" = "128" ]; then
        continue
    fi
    do_cmd "0" no 192.168.0.0/255.255.255.$i 192.168.0.0/255.255.255.$i
    do_cmd "0" no 192.168.0.0/255.255.$i.0 192.168.0.0/255.255.$i.0

    if [ $i -lt 8 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.0.0.0/255.$i.0.0
    elif [ $i -lt 16 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.8.0.0/255.$i.0.0
    elif [ $i -lt 24 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.0.0.0/255.$i.0.0
    elif [ $i -lt 32 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.8.0.0/255.$i.0.0
    elif [ $i -lt 40 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.32.0.0/255.$i.0.0
    elif [ $i -lt 48 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.40.0.0/255.$i.0.0
    elif [ $i -lt 56 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.32.0.0/255.$i.0.0
    elif [ $i -lt 64 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.40.0.0/255.$i.0.0
    elif [ $i -lt 72 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.0.0.0/255.$i.0.0
    elif [ $i -lt 80 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.8.0.0/255.$i.0.0
    elif [ $i -lt 88 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.0.0.0/255.$i.0.0
    elif [ $i -lt 96 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.8.0.0/255.$i.0.0
    elif [ $i -lt 104 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.32.0.0/255.$i.0.0
    elif [ $i -lt 112 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.40.0.0/255.$i.0.0
    elif [ $i -lt 120 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.32.0.0/255.$i.0.0
    elif [ $i -lt 128 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.40.0.0/255.$i.0.0
    elif [ $i -lt 136 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.128.0.0/255.$i.0.0
    elif [ $i -lt 144 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.136.0.0/255.$i.0.0
    elif [ $i -lt 152 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.128.0.0/255.$i.0.0
    elif [ $i -lt 160 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.136.0.0/255.$i.0.0
    elif [ $i -lt 168 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.160.0.0/255.$i.0.0
    elif [ $i -lt 176 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.168.0.0/255.$i.0.0
    elif [ $i -lt 184 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.160.0.0/255.$i.0.0
    elif [ $i -lt 192 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.168.0.0/255.$i.0.0
    elif [ $i -lt 200 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.128.0.0/255.$i.0.0
    elif [ $i -lt 208 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.136.0.0/255.$i.0.0
    elif [ $i -lt 216 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.128.0.0/255.$i.0.0
    elif [ $i -lt 224 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.136.0.0/255.$i.0.0
    elif [ $i -lt 232 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.160.0.0/255.$i.0.0
    elif [ $i -lt 240 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.168.0.0/255.$i.0.0
    elif [ $i -lt 248 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.160.0.0/255.$i.0.0
    elif [ $i -lt 256 ]; then
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.168.0.0/255.$i.0.0
    else
        do_cmd "0" no 192.168.0.0/255.$i.0.0 192.168.0.0/255.$i.0.0
    fi

    if [ $i -lt 64 ]; then
        do_cmd "0" no 192.168.0.0/$i.0.0.0 0.0.0.0/$i.0.0.0
    elif [ $i -lt 128 ]; then
        do_cmd "0" no 192.168.0.0/$i.0.0.0 64.0.0.0/$i.0.0.0
    elif [ $i -lt 192 ]; then
        do_cmd "0" no 192.168.0.0/$i.0.0.0 128.0.0.0/$i.0.0.0
    else
        do_cmd "0" no 192.168.0.0/$i.0.0.0 192.0.0.0/$i.0.0.0
    fi
done

echo "TEST IPv6 short notation" >> $TESTTMP/result
do_cmd "0" yes fe80:0000:0000:0000:0211:aaaa:bbbb:d54c fe80::211:aaaa:bbbb:d54c
do_cmd "0" yes 2001:0db8:85a3:08d3:1319:8a2e:0370:734 2001:db8:85a3:8d3:1319:8a2e:370:734

echo "TEST IPv6 CIDR" >> $TESTTMP/result
for i in $(seq 0 127); do
    do_cmd "0" yes ::1/$i ::1/$i
done

echo "TEST INVALID NETMASK" >> $TESTTMP/result
do_cmd "1" yes ::1/-1 ::1/-1
do_cmd "1" yes ::1/129 ::1/129
do_cmd "1" yes ::1/3e ::1/3e
do_cmd "1" no 192.168.0.1/-1 192.168.0.1/-1
do_cmd "1" no 192.168.0.1/33 192.168.0.1/33
do_cmd "1" no 192.168.0.1/e1 192.168.0.1/e1

echo "TEST HUMAN SORTING" >> $TESTTMP/result
cat > $script << EOM
#! /usr/bin/env $interpreter

import sys
import ufw.util

if len(sys.argv) != 3:
    print >> sys.stderr, "Wrong number of args: %d" % (len(sys.argv))
    print >> sys.stderr, "Usage: %s <port str> <expected port str>" % (sys.argv[0])
    sys.exit(1)

tmp = sys.argv[1].split(',')
try:
    ufw.util.human_sort(tmp)
    ports = ','.join(tmp)
except:
    print >> sys.stderr, "Error processing '%s'" % (sys.argv[1])
    sys.exit(1)

print "norm = %s, expected = %s" % (str(ports), str(sys.argv[2]))
if sys.argv[2] != ports:
    sys.exit(1)
sys.exit(0)
EOM

chmod 755 $script
do_cmd "0" '80,a222,a32,a2,b1,443,telnet,3,ZZZ,http' '3,80,443,a2,a32,a222,b1,http,telnet,ZZZ'

exit 0
