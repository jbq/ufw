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

source "$TESTPATH/../testlib.sh"
sed -i 's/IPV6=no/IPV6=yes/' $TESTPATH/etc/default/ufw

echo "Man page" >> $TESTTMP/result
do_cmd "0" --dry-run deny proto tcp from 2001:db8::/32 to any port 25

echo "TO/FROM" >> $TESTTMP/result
from="2001:db8::/32"
to="2001:db8:3:4:5:6:7:8"
for x in allow deny limit
do
	do_cmd "0" --dry-run $x from $from
	do_cmd "0" --dry-run delete $x from $from
	do_cmd "0" --dry-run $x to $to
	do_cmd "0" --dry-run delete $x to $to
	do_cmd "0" --dry-run $x to $to from $from
	do_cmd "0" --dry-run delete $x to $to from $from

	do_cmd "0" --dry-run $x from $from port 80
	do_cmd "0" --dry-run delete $x from $from port 80
	do_cmd "0" --dry-run $x to $to port 25
	do_cmd "0" --dry-run delete $x to $to port 25
	do_cmd "0" --dry-run $x to $to from $from port 80
	do_cmd "0" --dry-run delete $x to $to from $from port 80
	do_cmd "0" --dry-run $x to $to port 25 from $from
	do_cmd "0" --dry-run delete $x to $to port 25 from $from
	do_cmd "0" --dry-run $x to $to port 25 from $from port 80
	do_cmd "0" --dry-run delete $x to $to port 25 from $from port 80
	for y in udp tcp
	do
		do_cmd "0" --dry-run $x from $from port 80 proto $y
		do_cmd "0" --dry-run delete $x from $from port 80 proto $y
		do_cmd "0" --dry-run $x to $to port 25 proto $y
		do_cmd "0" --dry-run delete $x to $to port 25 proto $y
		do_cmd "0" --dry-run $x to $to from $from port 80 proto $y 
		do_cmd "0" --dry-run delete $x to $to from $from port 80 proto $y 
		do_cmd "0" --dry-run $x to $to port 25 proto $y from $from
		do_cmd "0" --dry-run delete $x to $to port 25 proto $y from $from
		do_cmd "0" --dry-run $x to $to port 25 proto $y from $from port 80
		do_cmd "0" --dry-run delete $x to $to port 25 proto $y from $from port 80
	done

	do_cmd "0" --dry-run $x to $to port smtp from $from port ssh
	do_cmd "0" --dry-run delete $x to $to port smtp from $from port ssh
	do_cmd "0" --dry-run $x to $to port tftp from $from port ssh
	do_cmd "0" --dry-run delete $x to $to port tftp from $from port ssh
	do_cmd "0" --dry-run $x to $to port ssh from $from port domain
	do_cmd "0" --dry-run delete $x to $to port ssh from $from port domain
done

echo "Netmasks" >> $TESTTMP/result
do_cmd "0" --dry-run allow to ::1/0
do_cmd "0" --dry-run allow to ::1/32
do_cmd "0" --dry-run allow to ::1/128
do_cmd "0" --dry-run allow from ::1/0
do_cmd "0" --dry-run allow from ::1/32
do_cmd "0" --dry-run allow from ::1/128
do_cmd "0" --dry-run allow from ::1/32 to ::1/128


echo "Multiports:" >> $TESTTMP/result
for i in 2001:db8:85a3:8d3:1319:8a2e:370:734 any; do
    for j in from to; do
        k="to"
        if [ "$j" = "to" ]; then
            k="from"
        fi
        m="${i}1"
        n="${i}2"
        if [ "$i" = "any" ]; then
            m="$i"
            n="$i"
        fi
        do_cmd "0" --dry-run allow $j $m port 34,35 proto tcp
        do_cmd "0" --dry-run allow $j $m port 34,35:39 proto udp
        do_cmd "0" --dry-run allow $j $m port 35:39 proto tcp
        do_cmd "0" --dry-run allow $j $m port 210,23,21,15:19,22 proto udp
        do_cmd "0" --dry-run allow $j $m port 34,35 $k $n port 24 proto tcp
        do_cmd "0" --dry-run allow $j $m port 34,35:39 $k $n port 24 proto udp
        do_cmd "0" --dry-run allow $j $m port 35:39 $k $n port 24 proto tcp
        do_cmd "0" --dry-run allow $j $m port 23,21,15:19,22 $k $n port 24 proto udp
        do_cmd "0" --dry-run allow $j $m port 34,35 $k $n port 24:26 proto tcp
        do_cmd "0" --dry-run allow $j $m port 34,35:39 $k $n port 24:26 proto udp
        do_cmd "0" --dry-run allow $j $m port 35:39 $k $n port 24:26 proto tcp
        do_cmd "0" --dry-run allow $j $m port 23,21,15:19,22 $k $n port 24:26 proto udp
    done
done

echo "Interfaces" >> $TESTTMP/result
for i in "in" "out" ; do
    for j in allow deny reject ; do
        do_cmd "0" null --dry-run $j $i on eth0 to 2001:db8:85a3:8d3:1319:8a2e:370:734
        do_cmd "0" null --dry-run $j $i on eth0 from 2001:db8:85a3:8d3:1319:8a2e:370:734 port 22 proto tcp
    done
done

echo "IPSec" >> $TESTTMP/result
do_cmd "0" --dry-run allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto esp
do_cmd "0" --dry-run allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto esp
do_cmd "0" --dry-run allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto ah
do_cmd "0" --dry-run allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto ah

exit 0
