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

source "$TESTPATH/../testlib.sh"

do_cmd "0" nostats enable
echo "TESTING EQUIVALENT PORTS" >> $TESTTMP/result
do_cmd "0" http-or-www allow http
do_cmd "0" delete allow 80/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow 80/tcp
do_cmd "0" http-or-www delete allow http
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" http-or-www allow http
do_cmd "0" delete allow to any port 80 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow to any port 80 proto tcp
do_cmd "0" http-or-www delete allow http
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow 80/tcp
do_cmd "0" delete allow to any port 80 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow to any port 80 proto tcp
do_cmd "0" delete allow 80/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result


echo "TESTING EQUIVALENT NETMASKS (HOST)" >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.1/255.255.255.255
do_cmd "0" delete allow from 192.168.0.1
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow from 192.168.0.1/255.255.255.255
do_cmd "0" delete allow from 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow from 192.168.0.1
do_cmd "0" delete allow from 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow from 192.168.0.1
do_cmd "0" delete allow from 192.168.0.1/255.255.255.255
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow from 192.168.0.1/32
do_cmd "0" delete allow from 192.168.0.1
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" allow from 192.168.0.1/32
do_cmd "0" delete allow from 192.168.0.1/255.255.255.255
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result


echo "TESTING EQUIVALENT NETMASKS (NETWORK)" >> $TESTTMP/result
cidr=32
for i in 255 254 252 248 240 224 192 128 255 254 252 248 240 224 192 128 255 254 252 248 240 224 192 128 255 254 252 248 240 224 192 128; do
    mask=""
    if [ $cidr -le 8 ]; then
        mask="$i.0.0.0"
    elif [ $cidr -le 16 ]; then
        mask="255.$i.0.0"
    elif [ $cidr -le 24 ]; then
        mask="255.255.$i.0"
    else
        mask="255.255.255.$i"
    fi

    do_cmd "0" allow from 192.168.0.0/$mask
    do_cmd "0" delete allow from 192.168.0.0/$cidr
    grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

    do_cmd "0" allow from 192.168.0.0/$cidr
    do_cmd "0" delete allow from 192.168.0.0/$mask
    grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

    cidr=$((cidr-1))
done

cleanup

exit 0
