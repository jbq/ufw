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

do_cmd "0" nostats disable
do_cmd "0" nostats enable

echo "TESTING LOG RULES" >> $TESTTMP/result
from="2001:db8::/32"
to="2001:db8:3:4:5:6:7:8"
for i in allow deny limit reject ; do
    for j in log log-all ; do
        do_cmd "0" nostats $i $j 23
        do_cmd "0" nostats $i $j Samba
        do_cmd "0" nostats $i $j from $from to $to port smtp
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result

        iptables-save | egrep -v '^(#|:)' > $TESTTMP/save.1
        ip6tables-save | egrep -v '^(#|:)' >> $TESTTMP/save.1
        do_cmd "0" nostats disable
        do_cmd "0" nostats enable
        iptables-save | egrep -v '^(#|:)' > $TESTTMP/save.2
        ip6tables-save | egrep -v '^(#|:)' >> $TESTTMP/save.2
        diff $TESTTMP/save.1 $TESTTMP/save.2 || {
            echo "ip(6)tables-restore different for '$i'"
            exit 1
        }

        do_cmd "0" nostats delete $i $j 23
        do_cmd "0" nostats delete $i $j Samba
        do_cmd "0" nostats delete $i $j from $from to $to port smtp
        echo "contents of user*.rules:" >> $TESTTMP/result
        cat $TESTSTATE/user.rules >> $TESTTMP/result
        cat $TESTSTATE/user6.rules >> $TESTTMP/result
    done
done

echo "contents of user*.rules:" >> $TESTTMP/result
cat $TESTSTATE/user.rules >> $TESTTMP/result
cat $TESTSTATE/user6.rules >> $TESTTMP/result

echo "Verify iptables-restore headers" >> $TESTTMP/result
for ipv6 in yes no ; do
    echo "Setting IPV6 to $ipv6" >> $TESTTMP/result
    sed -i "s/IPV6=.*/IPV6=$ipv6/" $TESTPATH/etc/default/ufw
    do_cmd "0" nostats disable
    do_cmd "0" nostats enable
    for i in "" off on low medium high full ; do
        if [ -n "$i" ]; then
            do_cmd "0" nostats logging $i
        fi
        do_extcmd "0" nostats $TESTPATH/lib/ufw/ufw-init flush-all
        do_extcmd "0" null $TESTPATH/lib/ufw/ufw-init start
        do_extcmd "0" null $TESTPATH/lib/ufw/ufw-init stop
        do_extcmd "0" null $TESTPATH/lib/ufw/ufw-init start
    done
done

cleanup
exit 0
