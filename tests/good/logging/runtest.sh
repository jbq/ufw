#!/bin/bash

#    Copyright 2009 Canonical Ltd.
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

#set -x

source "$TESTPATH/../testlib.sh"

echo "TESTING LOGLEVELS" >> $TESTTMP/result
for i in off low medium high full OFF LOW MEDIUM HIGH FULL; do
    do_cmd "0" null --dry-run logging $i
    egrep "^LOGLEVEL=" $TESTPATH/etc/ufw/ufw.conf >> $TESTTMP/result
done

echo "TESTING LOGLEVELS ('on')" >> $TESTTMP/result
for i in off on medium on; do
    do_cmd "0" null --dry-run logging $i
    egrep "^LOGLEVEL=" $TESTPATH/etc/ufw/ufw.conf >> $TESTTMP/result
done

echo "TESTING LOG RULES" >> $TESTTMP/result
for i in allow deny limit reject ; do
    for j in log log-all ; do
        do_cmd "0" null $i $j 23
        do_cmd "0" null $i $j smtp
        do_cmd "0" null $i $j tftp
        do_cmd "0" null $i $j https
        do_cmd "0" null $i $j Samba
        do_cmd "0" null $i $j Apache
        do_cmd "0" null $i $j from 192.168.0.1 port smtp to 10.0.0.1 port smtp
        do_cmd "0" null $i $j from 192.168.0.1 app Samba to 10.0.0.1 app Samba

        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result

        # now delete the rules
        do_cmd "0" null delete $i $j 23
        do_cmd "0" null delete $i $j smtp
        do_cmd "0" null delete $i $j tftp
        do_cmd "0" null delete $i $j https
        do_cmd "0" null delete $i $j Samba
        do_cmd "0" null delete $i $j Apache
        do_cmd "0" null delete $i $j from 192.168.0.1 port smtp to 10.0.0.1 port smtp
        do_cmd "0" null delete $i $j from 192.168.0.1 app Samba to 10.0.0.1 app Samba

        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result
    done
done

echo "TESTING LOG RULES (updating)" >> $TESTTMP/result
do_cmd "0" null allow log Samba
do_cmd "0" null deny log-all from 192.168.0.1 to 10.0.0.1 port 23 proto tcp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0" null limit log Samba
do_cmd "0" null reject log-all from 192.168.0.1 to 10.0.0.1 port 23 proto tcp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0" null delete limit log Samba
do_cmd "0" null delete reject log-all from 192.168.0.1 to 10.0.0.1 port 23 proto tcp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

echo "TESTING LOG RULES (interfaces)" >> $TESTTMP/result
do_cmd "0" null allow in on eth0 log
do_cmd "0" null allow in on eth0 log from 192.168.0.1 to 10.0.0.1 port 24 proto tcp
do_cmd "0" null deny in on eth0 log-all from 192.168.0.1 to 10.0.0.1 port 25 proto tcp
do_cmd "0" null allow out on eth0 log
do_cmd "0" null allow out on eth0 log from 192.168.0.1 to 10.0.0.1 port 24 proto tcp
do_cmd "0" null deny out on eth0 log-all from 192.168.0.1 to 10.0.0.1 port 25 proto tcp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result
do_cmd "0" null delete allow in on eth0 log
do_cmd "0" null delete allow in on eth0 log from 192.168.0.1 to 10.0.0.1 port 24 proto tcp
do_cmd "0" null delete deny in on eth0 log-all from 192.168.0.1 to 10.0.0.1 port 25 proto tcp
do_cmd "0" null delete allow out on eth0 log
do_cmd "0" null delete allow out on eth0 log from 192.168.0.1 to 10.0.0.1 port 24 proto tcp
do_cmd "0" null delete deny out on eth0 log-all from 192.168.0.1 to 10.0.0.1 port 25 proto tcp

echo "TESTING WRITING LOGLEVELS" >> $TESTTMP/result
for i in off low medium high full on; do
    do_cmd "0" null logging $i
    do_cmd "0" --dry-run allow 22
done

exit 0
