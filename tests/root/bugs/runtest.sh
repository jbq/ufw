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

# setup
do_cmd "0" nostats disable
do_cmd "0" nostats enable

echo "Bug #247352" >> $TESTTMP/result
do_cmd "0" --dry-run allow http/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result
echo "iptables -L -n:" >> $TESTTMP/result
iptables -L -n | grep -A2 "80" >> $TESTTMP/result 2>&1
do_cmd "0" delete allow http/tcp
grep -A2 "tuple" $TESTSTATE/user.rules >> $TESTTMP/result

echo "Bug #251355" >> $TESTTMP/result
echo "Setting IPV6 to no" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=no/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
echo "/lib/ufw/ufw-init flush-all:" >> $TESTTMP/result
$TESTSTATE/ufw-init flush-all >> $TESTTMP/result 2>&1
do_cmd "0" nostats enable
echo "/lib/ufw/ufw-init force-reload:" >> $TESTTMP/result
$TESTSTATE/ufw-init force-reload >> $TESTTMP/result 2>&1
echo "ip6tables -L -n:" >> $TESTTMP/result
ip6tables -L -n >> $TESTTMP/result 2>&1

echo "Bug #260881" >> $TESTTMP/result
echo "Setting IPV6 to no" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=no/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
do_cmd "0" nostats enable
do_cmd "0"  allow Apache
do_cmd "0"  delete deny Apache
echo "iptables -L -n:" >> $TESTTMP/result
iptables -L -n | grep -A2 "80" >> $TESTTMP/result 2>&1
do_cmd "0"  delete allow Apache
echo "iptables -L -n:" >> $TESTTMP/result
iptables -L -n | grep -A2 "80" >> $TESTTMP/result 2>&1

echo "Bug #263308" >> $TESTTMP/result
echo "Setting IPV6 to yes" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=yes/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
do_cmd "0" nostats enable
do_cmd "0"  allow to any from any
do_cmd "0"  allow proto tcp to any from any
do_cmd "0"  allow to 192.168.1.1
do_cmd "0"  allow proto udp from 192.168.1.1 to any
do_cmd "0"  allow from 192.168.1.1 to 192.168.1.2
do_cmd "0"  allow proto udp from 192.168.1.1 to 192.168.1.2
do_cmd "0"  status
do_cmd "0"  delete allow to any from any
do_cmd "0"  delete allow proto tcp to any from any
do_cmd "0"  delete allow to 192.168.1.1
do_cmd "0"  delete allow proto udp from 192.168.1.1 to any
do_cmd "0"  delete allow from 192.168.1.1 to 192.168.1.2
do_cmd "0"  delete allow proto udp from 192.168.1.1 to 192.168.1.2
do_cmd "0"  status

echo "Bug #273278" >> $TESTTMP/result
echo "Setting IPV6 to yes" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=yes/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
do_cmd "0" nostats enable
do_cmd "0"  status verbose
cat $TESTPATH/etc/ufw/after*.rules | egrep 'LOG .*UFW ' >> $TESTTMP/result
do_cmd "0"  default allow
do_cmd "0"  status verbose
cat $TESTPATH/etc/ufw/after*.rules | egrep 'LOG .*UFW ' >> $TESTTMP/result
do_cmd "0"  default deny
do_cmd "0"  status verbose
cat $TESTPATH/etc/ufw/after*.rules | egrep 'LOG .*UFW ' >> $TESTTMP/result

echo "Bug #251136" >> $TESTTMP/result
echo "Setting IPV6 to yes" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=yes/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
do_cmd "0" nostats enable
do_cmd "0"  status
do_cmd "0"  delete allow 22
do_cmd "0"  delete allow Apache
do_cmd "0"  delete allow to 127.0.0.1 port 22
do_cmd "0"  delete allow to 127.0.0.1 app Apache
do_cmd "0"  delete allow to ::1 port 22
do_cmd "0"  delete allow to ::1 app Apache
do_cmd "0"  status

echo "Bug #344971" >> $TESTTMP/result
echo "Setting IPV6 to yes" >> $TESTTMP/result
sed -i "s/IPV6=.*/IPV6=yes/" $TESTPATH/etc/default/ufw
do_cmd "0" nostats disable
do_cmd "0" nostats enable
do_cmd "0"  allow 3
do_cmd "0"  allow 4
do_cmd "0"  insert 1 allow 1
do_cmd "0"  insert 2 allow 2
do_cmd "0"  status numbered
do_cmd "0"  delete allow 4
do_cmd "0"  delete allow 3
do_cmd "0"  delete allow 2
do_cmd "0"  delete allow 1
do_cmd "0"  status
sed -i "s/IPV6=.*/IPV6=no/" $TESTPATH/etc/default/ufw

echo "Bug #407810" >> $TESTTMP/result
cp "$TESTPATH/etc/ufw/applications.d/samba" "$TESTPATH/etc/ufw/applications.d/bug407810"
sed -i 's/Samba/bug407810/' "$TESTPATH/etc/ufw/applications.d/bug407810"
do_cmd "0" app info bug407810
do_cmd "0" null allow bug407810
grep "^-A .*user-input" $TESTSTATE/user.rules >> $TESTTMP/result
rm -f "$TESTPATH/etc/ufw/applications.d/bug407810"
do_cmd "0" null delete allow bug407810
grep "^-A .*user-input" $TESTSTATE/user.rules >> $TESTTMP/result

echo "Bug #459925" >> $TESTTMP/result
for ipv6 in yes no ; do
    echo "Setting IPV6 to $ipv6" >> $TESTTMP/result
    sed -i "s/IPV6=.*/IPV6=$ipv6/" $TESTPATH/etc/default/ufw
    for i in "" off on low medium high full ; do
        do_cmd "0" nostats disable
        if [ -n "$i" ]; then
            do_cmd "0" null logging $i
        fi
        do_cmd "0" null enable
        iptables-save | grep '^-' > $TESTTMP/ipt.enable
        ip6tables-save | grep '^-' > $TESTTMP/ip6t.enable

        do_extcmd "0" null $TESTPATH/lib/ufw/ufw-init stop
        do_extcmd "0" null $TESTPATH/lib/ufw/ufw-init start
        iptables-save | grep '^-' > $TESTTMP/ipt.start
        ip6tables-save | grep '^-' > $TESTTMP/ip6t.start

        diff $TESTTMP/ipt.enable $TESTTMP/ipt.start || {
            echo "'ufw enable' and 'ufw-init start' are different for loglevel '$i'"
            exit 1
        }

        diff $TESTTMP/ip6t.enable $TESTTMP/ip6t.start || {
            echo "'ufw enable' and 'ufw-init start' are different for loglevel '$i' (ipv6)"
            exit 1
        }

    done
done

echo "Bug #512131" >> $TESTTMP/result
for i in low on medium high full off off ; do
    do_cmd "0" null logging $i
    e="0"
    if [ "$i" = "off" ]; then
        e="1"
    fi
    iptables-save | grep -q 'UFW LIMIT BLOCK' $TESTPATH/lib/ufw/user.rules
    rc="$?"
    if [ "$rc" != "$e" ]; then
        echo "$i: got '$rc', expected '$e'"
        exit 1
    fi
done

echo "Bug #513387" >> $TESTTMP/result
do_cmd "0" nostats disable
$TESTSTATE/ufw-init flush-all >/dev/null
do_cmd "0" nostats enable
for b in INPUT OUTPUT FORWARD; do
    suffix=`echo $b | tr [A-Z] [a-z]`
    echo "$count: iptables -L $b -n | egrep -q 'ufw-after-logging-$suffix'" >> $TESTTMP/result
    iptables -L "$b" -n | egrep -q "ufw-after-logging-$suffix" || {
        echo "'iptables -L $b -n' does not contain 'ufw-after-logging-$suffix'"
        exit 1
    }
    echo "" >> $TESTTMP/result
    echo "" >> $TESTTMP/result
    let count=count+1
done

# teardown
cleanup

exit 0
