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
sed -i 's/IPV6=no/IPV6=yes/' $TESTPATH/etc/default/ufw

echo "TESTING ARGS (logging)" >> $TESTTMP/result
do_cmd "1" null --dry-run logging
do_cmd "1" null --dry-run logging foo
do_cmd "1" null --dry-run loggin on

echo "TESTING ARGS (default)" >> $TESTTMP/result
do_cmd "1" null --dry-run default
do_cmd "1" null --dry-run default foo
do_cmd "1" null --dry-run default accept
do_cmd "1" null --dry-run defaul allow
do_cmd "1" null --dry-run default limit

echo "TESTING ARGS (enable/disable)" >> $TESTTMP/result
# bad
do_cmd "1" null --dry-run enabled
do_cmd "1" null --dry-run disabled

echo "TESTING ARGS (allow/deny/limit)" >> $TESTTMP/result
do_cmd "1" null --dry-run allow
do_cmd "1" null --dry-run deny
do_cmd "1" null --dry-run limit

echo "TESTING ARGS (allow/deny/limit bad port)" >> $TESTTMP/result
do_cmd "1" null --dry-run alow 25
do_cmd "1" null --dry-run dny 25
do_cmd "1" null --dry-run limt 25
do_cmd "1" null --dry-run allow 25a
do_cmd "1" null --dry-run deny 25a
do_cmd "1" null --dry-run limit 25a
do_cmd "1" null --dry-run allow 65536
do_cmd "1" null --dry-run deny 65536
do_cmd "1" null --dry-run limit 65536
do_cmd "1" null --dry-run allow 0
do_cmd "1" null --dry-run deny 0
do_cmd "1" null --dry-run limit 0
do_cmd "1" null --dry-run deny XXX
do_cmd "1" null --dry-run deny foobar

echo "TESTING ARGS (allow/deny/limit bad to/from)" >> $TESTTMP/result
ip="2001:db8:3:4:5:6:7:8"
for action in allow deny limit
do
        do_cmd "1" null --dry-run $action prot tcp from any
        do_cmd "1" null --dry-run $action proto tcp fro any
        do_cmd "1" null --dry-run $action proto tcp top any
        do_cmd "1" null --dry-run $action proto tcp to any por 25

	do_cmd "1" null --dry-run $action port 25
	do_cmd "1" null --dry-run $action to anu
	do_cmd "1" null --dry-run $action proto tcq to any port 25
	do_cmd "1" null --dry-run $action proto tcp proto udp to any port 25

	do_cmd "1" null --dry-run $action to
	do_cmd "1" null --dry-run $action to port 25

	do_cmd "1" null --dry-run $action from
	do_cmd "1" null --dry-run $action from port 25

	do_cmd "1" null --dry-run $action to any port
	do_cmd "1" null --dry-run $action to port 25

	do_cmd "1" null --dry-run $action from $ip to
	do_cmd "1" null --dry-run $action from $ip from
	do_cmd "1" null --dry-run $action from $ip port 25 to
	do_cmd "1" null --dry-run $action from $ip port 25 from

	do_cmd "1" null --dry-run $action to $ip from
	do_cmd "1" null --dry-run $action to $ip to
	do_cmd "1" null --dry-run $action to $ip port smtp from
	do_cmd "1" null --dry-run $action to $ip port smtp to

	do_cmd "1" null --dry-run $action to from $ip
	do_cmd "1" null --dry-run $action from to $ip
	do_cmd "1" null --dry-run $action to from $ip port 25
	do_cmd "1" null --dry-run $action from to $ip port 25

	do_cmd "1" null --dry-run $action from from $ip
	do_cmd "1" null --dry-run $action to to $ip
	do_cmd "1" null --dry-run $action from from $ip port smtp
	do_cmd "1" null --dry-run $action to to $ip port smtp
done

echo "TESTING ARGS (bad ip)" >> $TESTTMP/result
do_cmd "1" null --dry-run allow to 2001:db8:::/32
do_cmd "1" null --dry-run allow to 2001:db8::/129
do_cmd "1" null --dry-run allow to 2001:gb8::/32
do_cmd "1" null --dry-run allow to 2001:db8:3:4:5:6:7:8:9
do_cmd "1" null --dry-run allow to foo
do_cmd "1" null --dry-run allow to xxx:xxx:xxx:xx:xxx:xxx:xxx:xxx
do_cmd "1" null --dry-run allow to g001:db8:3:4:5:6:7:8
do_cmd "1" null --dry-run allow to 2001:gb8:3:4:5:6:7:8
do_cmd "1" null --dry-run allow to 2001:db8:g:4:5:6:7:8
do_cmd "1" null --dry-run allow to 2001:db8:3:g:5:6:7:8
do_cmd "1" null --dry-run allow to 2001:db8:3:4:g:6:7:8
do_cmd "1" null --dry-run allow to 2001:db8:3:4:5:g:7:8
do_cmd "1" null --dry-run allow to 2001:db8:3:4:5:6:g:8
do_cmd "1" null --dry-run allow to 2001:db8:3:4:5:6:7:g
do_cmd "1" null --dry-run allow to 2001:0db8:0000:0000:0000:0000:0000:0000/129
do_cmd "1" null --dry-run allow to 2001:0db8:0000:0000:0000:0000:0000:00000/128
do_cmd "1" null --dry-run allow to 2001:0db8:0000:0000:0000:0000:0000:00000/12a

echo "TESTING ARGS (delete)" >> $TESTTMP/result
do_cmd "1" null --dry-run delete

echo "TESTING ARGS (allow/deny/limit mixed ipv4/ipv6)" >> $TESTTMP/result
do_cmd "1" null --dry-run allow to 10.0.0.1 from 2001:db8::/32
do_cmd "1" null --dry-run deny to 10.0.0.1 port 25 from 2001:db8::/32 proto tcp
do_cmd "1" null --dry-run limit to 10.0.0.1 port 25 from 2001:db8::/32 proto tcp
do_cmd "1" null --dry-run allow to 2001:db8::/32 port 25 from 10.0.0.1 proto udp
do_cmd "1" null --dry-run deny to 2001:db8::/32 from 10.0.0.1
do_cmd "1" null --dry-run limit to 2001:db8::/32 from 10.0.0.1

echo "TESTING BAD SERVICES" >> $TESTTMP/result
do_cmd "1" null --dry-run allow smtp/udp
do_cmd "1" null --dry-run allow tftp/tcp
do_cmd "1" null --dry-run allow to any port smtp from any port tftp
do_cmd "1" null --dry-run allow to any port tftp from any port smtp
do_cmd "1" null --dry-run allow to any port smtp from any port 23 proto udp
do_cmd "1" null --dry-run allow to any port 23 from any port smtp proto udp
do_cmd "1" null --dry-run allow to any port tftp from any port 23 proto tcp
do_cmd "1" null --dry-run allow to any port 23 from any port tftp proto tcp
do_cmd "1" null --dry-run allow to any port smtp from any port ssh proto udp
do_cmd "1" null --dry-run allow to any port tftp from any port ssh proto tcp

echo "TESTING BAD MULTIPORTS" >> $TESTTMP/result
for i in allow deny limit; do
    for j in from to; do
        do_cmd "1" null --dry-run $i $j any port 20,21
        do_cmd "1" null --dry-run $i $j any port 20,2L proto udp
        do_cmd "1" null --dry-run $i $j any port 2o,21 proto tcp
        do_cmd "1" null --dry-run $i $j any port 20, proto udp
        do_cmd "1" null --dry-run $i $j any port ,20 proto tcp
        do_cmd "1" null --dry-run $i $j any port ,20, proto udp
        do_cmd "1" null --dry-run $i $j any port 20: proto tcp
        do_cmd "1" null --dry-run $i $j any port :20 proto udp
        do_cmd "1" null --dry-run $i $j any port :20: proto tcp
        do_cmd "1" null --dry-run $i $j any port 20:65536 proto udp
        do_cmd "1" null --dry-run $i $j any port 0:65 proto tcp
        do_cmd "1" null --dry-run $i $j any port ,20:24 proto udp
        do_cmd "1" null --dry-run $i $j any port 20:24, proto tcp
        do_cmd "1" null --dry-run $i $j any port ,20:24, proto udp
        do_cmd "1" null --dry-run $i $j any port 24:20 proto tcp
        do_cmd "1" null --dry-run $i $j any port 2A:20 proto tcp
        do_cmd "1" null --dry-run $i $j any port 24:2o proto tcp
        do_cmd "1" null --dry-run $i $j any port http,smtp proto tcp
        do_cmd "1" null --dry-run $i $j any port 80,smtp proto tcp
        do_cmd "1" null --dry-run $i $j any port http,25 proto tcp
    done

    do_cmd "1" null --dry-run $i to any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 from any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 proto tcp
    do_cmd "1" null --dry-run $i to any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 from any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 proto udp
    do_cmd "1" null --dry-run $i from any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34:39 to any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34:39 proto tcp
    do_cmd "1" null --dry-run $i from any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34:39 to any port 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34:39 proto udp
done

echo "TESTING BAD INTERFACES" >> $TESTTMP/result
for i in "in" "out"; do
    for j in allow deny limit reject; do
        do_cmd "1" null --dry-run $j $i on e%th0 to 2001:db8:3:4:5:6:7:8
        do_cmd "1" null --dry-run $j $i eth0 to 2001:db8:3:4:5:6:7:8
        do_cmd "1" null --dry-run $j ina eth0 to 2001:db8:3:4:5:6:7:8
        do_cmd "1" null --dry-run $j on eth0 to 2001:db8:3:4:5:6:7:8
        do_cmd "1" null --dry-run $j log $i on eth0 to 2001:db8:3:4:5:6:7:8
    done
done

exit 0
