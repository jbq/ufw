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
sed -i 's/IPV6=no/IPV6=yes/' $TESTPATH/etc/default/ufw

echo "TESTING LOG RULES" >> $TESTTMP/result
from="2001:db8::/32"
to="2001:db8:3:4:5:6:7:8"
for i in allow deny limit reject ; do
    for j in log log-all ; do
        do_cmd "0" null $i $j 23
        do_cmd "0" null $i $j Samba
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result

        do_cmd "0" null delete $i $j 23
        do_cmd "0" null delete $i $j Samba
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result

        do_cmd "0" null $i $j from $from to $to port smtp
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result

        do_cmd "0" null delete $i $j from $from to $to port smtp
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result
    done
done

echo "TESTING LOG RULES (updating)" >> $TESTTMP/result
do_cmd "0" null allow log Samba
do_cmd "0" null deny log-all from $from to $to port smtp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0" null deny log Samba
do_cmd "0" null reject log-all from $from to $to port smtp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

do_cmd "0" null delete deny log Samba
do_cmd "0" null delete reject log-all from $from to $to port smtp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

echo "TESTING LOG RULES (interfaces)" >> $TESTTMP/result
do_cmd "0" null allow in on eth0 log
do_cmd "0" null allow in on eth0 log from $from to $to port 24 proto tcp
do_cmd "0" null deny  in on eth0 log-all from $from to $to port 25 proto tcp
do_cmd "0" null allow out on eth0 log
do_cmd "0" null allow out on eth0 log from $from to $to port 24 proto tcp
do_cmd "0" null deny  out on eth0 log-all from $from to $to port 25 proto tcp
echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result


exit 0
