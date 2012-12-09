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

echo "TESTING APPLICATION INTEGRATION (args)" >> $TESTTMP/result
do_cmd "0" app list
do_cmd "0" app info Apache
do_cmd "0" app info 'Apache Secure'
do_cmd "0" app info 'Apache Full'
do_cmd "0" app info Bind9
do_cmd "0" app info Samba
do_cmd "0" app info 'Custom Web App'
do_cmd "0" app info 'Custom Web App2'
do_cmd "0" app info all
do_cmd "0" app info 0verkill

echo "TESTING APPLICATION INTEGRATION (simple rules)" >> $TESTTMP/result
for target in allow deny limit ; do
    do_cmd "0" --dry-run $target Apache
    do_cmd "0" --dry-run $target 'Apache Secure'
    do_cmd "0" --dry-run $target 'Apache Full'
    do_cmd "0" --dry-run $target Bind9
    do_cmd "0" --dry-run $target Samba
    do_cmd "0" --dry-run $target OpenNTPD
    do_cmd "0" --dry-run $target 'Multi TCP'
    do_cmd "0" --dry-run $target 'Multi UDP'
    do_cmd "0" --dry-run $target 'Custom Web App2'
done

echo "TESTING APPLICATION INTEGRATION (extended rules)" >> $TESTTMP/result
for target in allow deny limit ; do
    for i in to from ; do
        for loc in 192.168.0.0/16 any ; do
            do_cmd "0" --dry-run $target $i $loc app Apache
            do_cmd "0" --dry-run $target $i $loc app 'Apache Secure'
            do_cmd "0" --dry-run $target $i $loc app 'Apache Full'
            do_cmd "0" --dry-run $target $i $loc app Bind9
            do_cmd "0" --dry-run $target $i $loc app Samba
            do_cmd "0" --dry-run $target $i $loc app OpenNTPD
            do_cmd "0" --dry-run $target $i $loc app 'Multi TCP'
            do_cmd "0" --dry-run $target $i $loc app 'Multi UDP'
        done
    done

    for i in 192.168.0 any; do
        for j in from to; do
            k="to"
            if [ "$j" = "to" ]; then
                k="from"
            fi
            m="$i.1"
            n="$i.2"
            if [ "$i" = "any" ]; then
                m="$i"
                n="$i"
            fi
            do_cmd "0" --dry-run $target $j $m app Apache $k $n port 8080
            do_cmd "0" --dry-run $target $j $m app OpenNTPD $k $n port 10123
            do_cmd "0" --dry-run $target $j $m app Samba $k $n app Bind9
            do_cmd "0" --dry-run $target $j $m app Samba $k $n port 22
            do_cmd "0" --dry-run $target $j $m app Apache $k $n app 'Apache Full'
        done
        if [ "$i" != "any" ]; then
            i="$i.1"
        fi
        do_cmd "0" --dry-run $target to $i app Samba from $i app Samba
    done
done

echo "TESTING APPLICATION INTEGRATION (case insensitive)" >> $TESTTMP/result
cat > $TESTPATH/etc/ufw/applications.d/runtest << EOM
[runtest]
title=runtest title
description=runtest description
ports=23/tcp
EOM
do_cmd "0" --dry-run allow runtest
do_cmd "0" --dry-run allow RunTest
rm -f $TESTPATH/etc/ufw/applications.d/runtest

echo "TESTING APPLICATION INTEGRATION (update)" >> $TESTTMP/result
do_cmd "0" app default allow
do_cmd "0" --dry-run app update --add-new Apache
do_cmd "0" app default deny
do_cmd "0" --dry-run app update --add-new Samba
do_cmd "0" app default skip
do_cmd "0" --dry-run app update --add-new Bind9
do_cmd "0" app default reject
do_cmd "0" --dry-run app update --add-new Samba

echo "TESTING APPLICATION INTEGRATION (exact vs multi)" >> $TESTTMP/result
cat > $TESTPATH/etc/ufw/applications.d/Runtest2 << EOM
[Runtest2]
title=runtest title
description=runtest description
ports=23/tcp
EOM
cat > $TESTPATH/etc/ufw/applications.d/RunTest2 << EOM
[RunTest2]
title=runtest title
description=runtest description
ports=24/tcp
EOM
do_cmd "0" null --dry-run allow RunTest2
rm -f $TESTPATH/etc/ufw/applications.d/Runtest2 $TESTPATH/etc/ufw/applications.d/RunTest2

echo "TESTING INSERT" >> $TESTTMP/result
do_cmd "0" null allow Apache
do_cmd "0" null allow Bind9
do_cmd "0" null insert 1 allow Samba
do_cmd "0" null insert 2 reject 'Dovecot POP3'
cat $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" null delete allow Apache
do_cmd "0" null delete allow Bind9
do_cmd "0" null delete allow Samba
do_cmd "0" null delete reject 'Dovecot POP3'
cat $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" null allow Samba
do_cmd "0" null allow 22
do_cmd "0" null insert 2 allow log-all from any to any app Samba
do_cmd "0" null insert 2 allow from 192.168.0.1 to 10.0.0.1 app Samba
do_cmd "0" null insert 2 allow from 192.168.0.1 to any app Samba
do_cmd "0" null insert 2 allow from 192.168.0.1 app Samba to 10.0.0.1
do_cmd "0" null insert 2 allow from any app Samba to 10.0.0.1
cat $TESTSTATE/user.rules >> $TESTTMP/result

do_cmd "0" null delete allow Samba
do_cmd "0" null delete allow 22
do_cmd "0" null delete allow log-all from any to any app Samba
do_cmd "0" null delete allow from 192.168.0.1 to 10.0.0.1 app Samba
do_cmd "0" null delete allow from 192.168.0.1 to any app Samba
do_cmd "0" null delete allow from 192.168.0.1 app Samba to 10.0.0.1
do_cmd "0" null delete allow from any app Samba to 10.0.0.1
cat $TESTSTATE/user.rules >> $TESTTMP/result

echo "TESTING APPLICATION INTEGRATION (interfaces)" >> $TESTTMP/result
for i in "in" "out" ; do
    for j in allow deny limit reject ; do
        do_cmd "0" null $j $i on eth0 to 192.168.0.1 app Samba
        do_cmd "0" null $j $i on eth0 from 10.0.0.1 app Samba
        do_cmd "0" null $j $i on eth0 from 10.0.0.1 to any app Samba
        cat $TESTSTATE/user.rules >> $TESTTMP/result

        do_cmd "0" null delete $j $i on eth0 to 192.168.0.1 app Samba
        do_cmd "0" null delete $j $i on eth0 from 10.0.0.1 app Samba
        do_cmd "0" null delete $j $i on eth0 from 10.0.0.1 to any app Samba
        cat $TESTSTATE/user.rules >> $TESTTMP/result
    done
    do_cmd "0" null allow $i on eth0 to any app Samba
    do_cmd "0" null allow $i on eth1 to any port 22
    do_cmd "0" null insert 2 allow $i on eth2 to any app Samba
    cat $TESTSTATE/user.rules >> $TESTTMP/result

    do_cmd "0" null delete allow $i on eth0 to any app Samba
    do_cmd "0" null delete allow $i on eth1 to any port 22
    do_cmd "0" null delete allow $i on eth2 to any app Samba
    cat $TESTSTATE/user.rules >> $TESTTMP/result
done

echo "TESTING SHIPPED APPLICATION PROFILES" >> $TESTTMP/result
grep '^\[' $TESTPATH/etc/ufw/applications.d/ufw-* | cut -f 2 -d ':' | sed -e 's/\[//' -e 's/\]//' | \
while read line ; do
    do_cmd "0" null app info "$line"
    do_cmd "0" null allow "$line"
done

exit 0
