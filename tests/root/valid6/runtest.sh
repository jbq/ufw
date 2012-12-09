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
do_cmd "0"  logging on
grep -h "LOG" $TESTPATH/etc/ufw/*.rules >> $TESTTMP/result
do_cmd "0"  logging off
grep -h "LOG" $TESTPATH/etc/ufw/*.rules >> $TESTTMP/result
do_cmd "0"  LOGGING ON
grep -h "LOG" $TESTPATH/etc/ufw/*.rules >> $TESTTMP/result
do_cmd "0"  LOGGING OFF
grep -h "LOG" $TESTPATH/etc/ufw/*.rules >> $TESTTMP/result

echo "TESTING ARGS (default)" >> $TESTTMP/result
do_cmd "0"  enable
do_cmd "0"  default allow
echo "ipv4:" >> $TESTTMP/result
iptables -L -n | grep 'policy ' >> $TESTTMP/result
echo "ipv6:" >> $TESTTMP/result
ip6tables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  default deny
echo "ipv4:" >> $TESTTMP/result
iptables -L -n | grep 'policy ' >> $TESTTMP/result
echo "ipv6:" >> $TESTTMP/result
ip6tables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  DEFAULT ALLOW
echo "ipv4:" >> $TESTTMP/result
iptables -L -n | grep 'policy ' >> $TESTTMP/result
echo "ipv6:" >> $TESTTMP/result
ip6tables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  DEFAULT DENY
echo "ipv4:" >> $TESTTMP/result
iptables -L -n | grep 'policy ' >> $TESTTMP/result
echo "ipv6:" >> $TESTTMP/result
ip6tables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result

do_cmd "0"  default deny
do_cmd "0"  disable

echo "TESTING ARGS (enable/disable)" >> $TESTTMP/result
do_cmd "0"  enable
cat $TESTPATH/etc/ufw/ufw.conf | egrep '^ENABLED' >> $TESTTMP/result
do_cmd "0"  disable
cat $TESTPATH/etc/ufw/ufw.conf | egrep '^ENABLED' >> $TESTTMP/result
do_cmd "0"  ENABLE
cat $TESTPATH/etc/ufw/ufw.conf | egrep '^ENABLED' >> $TESTTMP/result
do_cmd "0"  DISABLE
cat $TESTPATH/etc/ufw/ufw.conf | egrep '^ENABLED' >> $TESTTMP/result

echo "TESTING ARGS (allow/deny to/from)" >> $TESTTMP/result
echo "Man page" >> $TESTTMP/result
do_cmd "0" deny proto tcp from 2001:db8::/32 to any port 25
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0"  delete deny proto tcp from 2001:db8::/32 to any port 25
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result


echo "TO/FROM" >> $TESTTMP/result
from="2001:db8::/32"
to="2001:db8:3:4:5:6:7:8"
for x in allow deny limit reject
do
        context="2"
        if [ "$x" = "limit" ]; then
                context="5"
        fi
        do_cmd "0"  $x from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

        do_cmd "0"  $x from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25 from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25 from $from
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25 from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25 from $from port 80
	grep -A$context "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        for y in udp tcp
        do
                do_cmd "0"  $x from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  delete $x from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y from $from
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y from $from
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y from $from port 80
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y from $from port 80
		grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
        done
done

do_cmd "0" null --dry-run allow to 2001:db8:0000:0000:0000:0000:0000:0001/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result


do_cmd "0"  allow to any port smtp from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port smtp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port tftp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0"  allow to any port smtp from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain proto udp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

echo "TESTING NETMASK" >> $TESTTMP/result
do_cmd "0" allow to ::1/0
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to ::1/0
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to ::1/32
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to ::1/32
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow from ::1/0
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow from ::1/0
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow from ::1/32
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow from ::1/32
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow from ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow from ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow from ::1/32 to ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow from ::1/32 to ::1/128
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

echo "TESTING MULTIPORT" >> $TESTTMP/result
do_cmd "0" allow to 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 80:83 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 80:83 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 80:83,22 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 80:83,22 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow from 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 35:39 to 2001:db8:85a3:8d3:1319:8a2e:370:7342 port 22 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow from 2001:db8:85a3:8d3:1319:8a2e:370:7341 port 35:39 to 2001:db8:85a3:8d3:1319:8a2e:370:7342 port 22 proto tcp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to any port 23,21,15:19,22 from any port 24:26 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to any port 23,21,15:19,22 from any port 24:26 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow 23,21,15:19,22/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow 23,21,15:19,22/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

echo "TESTING IPSec" >> $TESTTMP/result
do_cmd "0" allow to 10.0.0.1 proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 10.0.0.1 proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" deny to 10.0.0.1 from 10.4.0.0/16 proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete deny to 10.0.0.1 from 10.4.0.0/16 proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" limit to 10.0.0.1 proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete limit to 10.0.0.1 proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" reject to 10.0.0.1 from 10.4.0.0/16 proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete reject to 10.0.0.1 from 10.4.0.0/16 proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" reject to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto esp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete reject to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto esp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto esp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto esp
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" deny to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto ah
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete deny to 2001:db8:85a3:8d3:1319:8a2e:370:734 proto ah
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto ah
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to 2001:db8:85a3:8d3:1319:8a2e:370:734 from 2001:db8::/32 proto ah
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0" allow to any proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete allow to any proto esp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" deny to any proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" delete deny to any proto ah
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
grep -A2 "tuple" $TESTSTATE/user6.rules >> $TESTTMP/result

cleanup
exit 0
