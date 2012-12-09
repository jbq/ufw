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
iptables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  default deny
iptables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  DEFAULT ALLOW
iptables -L -n | grep 'policy ' >> $TESTTMP/result
grep -h "DEFAULT" $TESTPATH/etc/default/ufw >> $TESTTMP/result
do_cmd "0"  DEFAULT DENY
iptables -L -n | grep 'policy ' >> $TESTTMP/result
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

echo "TESTING ARGS (allow/deny port)" >> $TESTTMP/result
do_cmd "0"  allow 25
do_cmd "0"  deny 25
do_cmd "0"  deny 1
do_cmd "0"  deny 65535
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete deny 25
do_cmd "0"  delete deny 1
do_cmd "0"  delete deny 65535
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result


echo "TESTING ARGS (allow/deny to/from)" >> $TESTTMP/result
echo "Man page" >> $TESTTMP/result
do_cmd "0"  allow 53
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow 25/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  deny to any port 80 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  deny from 10.0.0.0/8 to 192.168.0.1 port 25 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  limit 22/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  deny 53
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow 80/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow from 10.0.0.0/8
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow from 172.16.0.0/12
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow from 192.168.0.0/16
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  deny from 1.2.3.4 to any port 514 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow from 1.2.3.5 port 5469 proto udp to 1.2.3.4 port 5469
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  reject auth
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  delete allow 25/tcp
do_cmd "0"  delete deny from 10.0.0.0/8 to 192.168.0.1 port 25 proto tcp
do_cmd "0"  delete limit 22/tcp
do_cmd "0"  delete deny 53
do_cmd "0"  delete allow 80/tcp
do_cmd "0"  delete allow from 10.0.0.0/8
do_cmd "0"  delete allow from 172.16.0.0/12
do_cmd "0"  delete allow from 192.168.0.0/16
do_cmd "0"  delete deny from 1.2.3.4 to any port 514 proto udp
do_cmd "0"  delete allow from 1.2.3.5 port 5469 proto udp to 1.2.3.4 port 5469
do_cmd "0"  delete reject auth
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result


echo "SIMPLE" >> $TESTTMP/result
do_cmd "0"  allow 25
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow 25/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow 25/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow 25
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow 25/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow 25/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow 25/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow smtp/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow smtp/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow tftp/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow tftp/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow ssh/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow ssh/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow ssh/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow ssh/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result


echo "TO/FROM" >> $TESTTMP/result
from="192.168.0.1"
to="10.0.0.1"
for x in allow deny limit reject
do
        context="2"
        if [ "$x" = "limit" ]; then
                context="5"
        fi
        do_cmd "0"  $x from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

        do_cmd "0"  $x from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25 from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25 from $from
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  $x to $to port 25 from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        do_cmd "0"  delete $x to $to port 25 from $from port 80
	grep -A$context "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        for y in udp tcp
        do
                do_cmd "0"  $x from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  delete $x from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to from $from port 80 proto $y
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y from $from
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y from $from
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  $x to $to port 25 proto $y from $from port 80
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
                do_cmd "0"  delete $x to $to port 25 proto $y from $from port 80
		grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
        done
done

echo "TESTING ARGS (status)" >> $TESTTMP/result
do_cmd "0" --dry-run status 

do_cmd "0"  allow to any port smtp from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port smtp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port tftp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0"  allow to any port smtp from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port smtp from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port smtp from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port smtp proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port tftp from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port tftp from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port tftp proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port 23 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port 23 from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port 23 from any port ssh proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  allow to any port ssh from any port domain proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0"  delete allow to any port ssh from any port domain proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

echo "TESTING NETMASK" >> $TESTTMP/result
do_cmd "0" allow to 192.168.0.0/0
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 192.168.0.0/0
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow to 192.168.0.0/16
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 192.168.0.0/16
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow to 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.0/0
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.0/0
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.0/16
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.0/16
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.1/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.1/32 to 192.168.0.2/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.1/32 to 192.168.0.2/32
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.2/255.255.0.2 
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.2/255.255.0.2
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

echo "LP bug 237446" >> $TESTTMP/result
do_cmd "0" allow to 111.12.34.2/4
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 111.12.34.2/4
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 111.12.34.2/4
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 96.0.0.0/4
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

echo "TESTING MULTIPORT" >> $TESTTMP/result
do_cmd "0" allow to 192.168.0.1 port 80:83 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 192.168.0.1 port 80:83 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow to 192.168.0.1 port 80:83,22 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to 192.168.0.1 port 80:83,22 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow from 192.168.0.1 port 35:39 to 192.168.0.2 port 22 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow from 192.168.0.1 port 35:39 to 192.168.0.2 port 22 proto tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow to any port 23,21,15:19,22 from any port 24:26 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow to any port 23,21,15:19,22 from any port 24:26 proto udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow 34,35/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow 34,35/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" allow 34,35:39/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete allow 34,35:39/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" deny 35:39/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete deny 35:39/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" deny 23,21,15:19,22/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
do_cmd "0" delete deny 23,21,15:19,22/udp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

cleanup

exit 0
