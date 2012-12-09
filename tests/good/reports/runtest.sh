#!/bin/bash

#    Copyright 2010 Canonical Ltd.
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

ipt_version=`iptables -V | awk '{print $2}' | sed 's/^v//'`
ipt_major=`echo $ipt_version | cut -d '.' -f 1`
ipt_minor=`echo $ipt_version | cut -d '.' -f 2`
if [ "$ipt_major" = "1" ] && [ "$ipt_minor" -lt "4" ]; then
    echo "Skipping: iptables $ipt_version is less than 1.4"
    exit 0
fi

# The show listening test is a regression test that has:
# eth0 = 10.0.2.9   2001::0211:aaaa:bbbb:d54c/112
# eth1 = 10.0.2.101 2001::0212:cccc:dddd:e243/112
#
# With the following open ports (port 68 is listed twice due to eth0 and eth1):
#tcp        0      0 0.0.0.0:22
#tcp        0      0 127.0.0.1:631
#tcp6       0      0 :::22
#tcp6       0      0 ::1:631
#udp        0      0 0.0.0.0:68
#udp        0      0 0.0.0.0:68
#udp        0      0 0.0.0.0:33257
#udp        0      0 0.0.0.0:5353
#udp        0      0 10.0.2.101:123
#udp        0      0 10.0.2.9:123
#udp        0      0 127.0.0.1:123
#udp        0      0 0.0.0.0:123
#udp6       0      0 2001::212:cccc:dddd:e243:123
#udp6       0      0 2001::211:aaaa:bbbb:d54c:123
#udp6       0      0 ::1:123
#udp6       0      0 :::123
#
# So this test will modify util.py to:
# - look at ./netstat.enlp instead of calling 'netstat -enlp' directly
# - to use a fake /proc/net/if_inet6 and /proc/net/dev
# - to hard code the addressed for eth0 and eth1
#
# The rules that are created should create the following 'status numbered'
# output:
#      To                         Action      From
#      --                         ------      ----
# [ 1] 123                        ALLOW IN    Anywhere
# [ 2] OpenNTPD                   ALLOW IN    Anywhere
# [ 3] 123/tcp                    ALLOW IN    Anywhere
# [ 4] Anywhere                   ALLOW IN    Anywhere
# [ 5] Anywhere/udp               ALLOW IN    Anywhere/udp
# [ 6] Anywhere/tcp               ALLOW IN    Anywhere/tcp
# [ 7] 10.0.2.101                 ALLOW IN    Anywhere
# [ 8] 10.0.2.9                   ALLOW IN    Anywhere
# [ 9] 10.0.0.0/16                ALLOW IN    Anywhere
# [10] 10.0.2.0/24                ALLOW IN    Anywhere
# [11] 10.0.3.0/24                ALLOW IN    Anywhere
# [12] 10.0.2.101 123             ALLOW IN    Anywhere
# [13] 10.0.0.0/16 123            ALLOW IN    Anywhere
# [14] 10.0.2.0/24 123            ALLOW IN    Anywhere
# [15] 10.0.3.0/24 123            ALLOW IN    Anywhere
# [16] 10.0.2.101 123/udp         ALLOW IN    Anywhere
# [17] 10.0.0.0/16 OpenNTPD       ALLOW IN    Anywhere
# [18] 10.0.2.0/24 123/udp        ALLOW IN    Anywhere
# [19] 10.0.3.0/24 123/udp        ALLOW IN    Anywhere
# [20] 10.0.2.101 123/tcp         ALLOW IN    Anywhere
# [21] 10.0.0.0/16 123/tcp        ALLOW IN    Anywhere
# [22] 10.0.2.0/24 123/tcp        ALLOW IN    Anywhere
# [23] 10.0.3.0/24 123/tcp        ALLOW IN    Anywhere
# [24] 123                        ALLOW OUT   Anywhere (out)
# [25] 123/udp                    ALLOW OUT   Anywhere (out)
# [26] 123/tcp                    ALLOW OUT   Anywhere (out)
# [27] Anywhere on eth0           ALLOW IN    Anywhere
# [28] Anywhere/udp on eth0       ALLOW IN    Anywhere/udp
# [29] Anywhere/tcp on eth0       ALLOW IN    Anywhere/tcp
# [30] 10.0.2.101 on eth0         ALLOW IN    Anywhere
# [31] 10.0.2.9 on eth0           ALLOW IN    Anywhere
# [32] 10.0.0.0/16 on eth0        ALLOW IN    Anywhere
# [33] 10.0.2.0/24 on eth0        ALLOW IN    Anywhere
# [34] 10.0.3.0/24 on eth0        ALLOW IN    Anywhere
# [35] 10.0.2.101 123 on eth0     ALLOW IN    Anywhere
# [36] 10.0.0.0/16 123 on eth0    ALLOW IN    Anywhere
# [37] 10.0.2.0/24 123 on eth0    ALLOW IN    Anywhere
# [38] 10.0.3.0/24 123 on eth0    ALLOW IN    Anywhere
# [39] 10.0.2.101 123/udp on eth0 ALLOW IN    Anywhere
# [40] 10.0.0.0/16 OpenNTPD on eth0 ALLOW IN    Anywhere
# [41] 10.0.2.0/24 123/udp on eth0 ALLOW IN    Anywhere
# [42] 10.0.3.0/24 123/udp on eth0 ALLOW IN    Anywhere
# [43] 10.0.2.101 123/tcp on eth0 ALLOW IN    Anywhere
# [44] 10.0.0.0/16 123/tcp on eth0 ALLOW IN    Anywhere
# [45] 10.0.2.0/24 123/tcp on eth0 ALLOW IN    Anywhere
# [46] 10.0.3.0/24 123/tcp on eth0 ALLOW IN    Anywhere
# [47] 123                        ALLOW IN    Anywhere (v6)
# [48] OpenNTPD (v6)              ALLOW IN    Anywhere (v6)
# [49] 123/tcp                    ALLOW IN    Anywhere (v6)
# [50] Anywhere (v6)              ALLOW IN    Anywhere (v6)
# [51] Anywhere/udp (v6)          ALLOW IN    Anywhere/udp (v6)
# [52] Anywhere/tcp (v6)          ALLOW IN    Anywhere/tcp (v6)
# [53] 2001::211:aaaa:bbbb:d54c   ALLOW IN    Anywhere (v6)
# [54] 2001::211:aaaa:bbbb:d54c/112 ALLOW IN    Anywhere (v6)
# [55] 2001::211:aaaa:bbbb:d54c 123 ALLOW IN    Anywhere (v6)
# [56] 2001::211:aaaa:bbbb:d54c/112 123 ALLOW IN    Anywhere (v6)
# [57] 2001::211:aaaa:bbbb:d54c 123/udp ALLOW IN    Anywhere (v6)
# [58] 2001::211:aaaa:bbbb:d54c/112 123/udp ALLOW IN    Anywhere (v6)
# [59] 2001::211:aaaa:bbbb:d54c 123/tcp ALLOW IN    Anywhere (v6)
# [60] 2001::211:aaaa:bbbb:d54c/112 123/tcp ALLOW IN    Anywhere (v6)
# [61] 123                        ALLOW OUT   Anywhere (v6) (out)
# [62] 123/udp                    ALLOW OUT   Anywhere (v6) (out)
# [63] 123/tcp                    ALLOW OUT   Anywhere (v6) (out)
# [64] Anywhere (v6) on eth0      ALLOW IN    Anywhere (v6)
# [65] Anywhere/udp (v6) on eth0  ALLOW IN    Anywhere/udp (v6)
# [66] Anywhere/tcp (v6) on eth0  ALLOW IN    Anywhere/tcp (v6)
# [67] 2001::211:aaaa:bbbb:d54c on eth0 ALLOW IN    Anywhere (v6)
# [68] 2001::211:aaaa:bbbb:d54c/112 on eth0 ALLOW IN    Anywhere (v6)
# [69] 2001::211:aaaa:bbbb:d54c 123 on eth0 ALLOW IN    Anywhere (v6)
# [70] 2001::211:aaaa:bbbb:d54c/112 123 on eth0 ALLOW IN    Anywhere (v6)
# [71] 2001::211:aaaa:bbbb:d54c 123/udp on eth0 ALLOW IN    Anywhere (v6)
# [72] 2001::211:aaaa:bbbb:d54c/112 123/udp on eth0 ALLOW IN    Anywhere (v6)
# [73] 2001::211:aaaa:bbbb:d54c 123/tcp on eth0 ALLOW IN    Anywhere (v6)
# [74] 2001::211:aaaa:bbbb:d54c/112 123/tcp on eth0 ALLOW IN    Anywhere (v6)

echo "show listening" >> $TESTTMP/result
echo "(update util.py to use our cached output)" >> $TESTTMP/result
cp -f $TESTPATH/lib/python/ufw/util.py $TESTPATH/lib/python/ufw/util.py.bak
sed -i "s#netstat_output = get_netstat_output.*#rc, netstat_output = cmd(['cat', '$TESTPATH/../good/reports/netstat.enlp'])#" $TESTPATH/lib/python/ufw/util.py
sed -i "s#proc = '/proc/net/if_inet6'#proc = '$TESTPATH/../good/reports/proc_net_if_inet6'#" $TESTPATH/lib/python/ufw/util.py
sed -i "s#proc = '/proc/net/dev'#proc = '$TESTPATH/../good/reports/proc_net_dev'#" $TESTPATH/lib/python/ufw/util.py
sed -i "s#\(.*\)\(addr = .* 0x8915,.*\)#\\1if ifname == 'eth0':\n\\1\\1addr = '10.0.2.9'\n\\1elif ifname == 'eth1':\n\\1\\1addr = '10.0.2.101'\n\\1else:\n\\1\\1raise IOError\n\\1return normalize_address(addr, v6)[0]\n\\1\\2#" $TESTPATH/lib/python/ufw/util.py

sed -i "s/IPV6=.*/IPV6=yes/" $TESTPATH/etc/default/ufw

echo "show listening with no rules" >> $TESTTMP/result
do_cmd "0" show listening

echo "Add rules for test" >> $TESTTMP/result
for i in "" "in on eth0" ; do
    if [ -z "$i" ]; then
        do_cmd "0" null allow in 123
        do_cmd "0" null allow in OpenNTPD
        do_cmd "0" null allow in 123/tcp
    else
        do_cmd "0" null allow out 123
        do_cmd "0" null allow out 123/udp
        do_cmd "0" null allow out 123/tcp
    fi

    do_cmd "0" null allow $i to any
    do_cmd "0" null allow $i to any proto udp
    do_cmd "0" null allow $i to any proto tcp

    do_cmd "0" null allow $i to 10.0.2.101
    do_cmd "0" null allow $i to 10.0.2.9
    do_cmd "0" null allow $i to 10.0.0.0/16
    do_cmd "0" null allow $i to 10.0.2.0/24
    do_cmd "0" null allow $i to 10.0.3.0/24
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c/112

    do_cmd "0" null allow $i to 10.0.2.101 port 123
    do_cmd "0" null allow $i to 10.0.0.0/16 port 123
    do_cmd "0" null allow $i to 10.0.2.0/24 port 123
    do_cmd "0" null allow $i to 10.0.3.0/24 port 123
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c port 123
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123

    do_cmd "0" null allow $i to 10.0.2.101 port 123 proto udp
    do_cmd "0" null allow $i to 10.0.0.0/16 app OpenNTPD
    do_cmd "0" null allow $i to 10.0.2.0/24 port 123 proto udp
    do_cmd "0" null allow $i to 10.0.3.0/24 port 123 proto udp
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c port 123 proto udp
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123 proto udp

    do_cmd "0" null allow $i to 10.0.2.101 port 123 proto tcp
    do_cmd "0" null allow $i to 10.0.0.0/16 port 123 proto tcp
    do_cmd "0" null allow $i to 10.0.2.0/24 port 123 proto tcp
    do_cmd "0" null allow $i to 10.0.3.0/24 port 123 proto tcp
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c port 123 proto tcp
    do_cmd "0" null allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123 proto tcp
done

echo "show listening with rules" >> $TESTTMP/result
do_cmd "0" show listening

# Cleanup the above rules
for i in "" "in on eth0" ; do
    if [ -z "$i" ]; then
        do_cmd "0" null delete allow in 123
        do_cmd "0" null delete allow in OpenNTPD
        do_cmd "0" null delete allow in 123/tcp
    else
        do_cmd "0" null delete allow out 123
        do_cmd "0" null delete allow out 123/udp
        do_cmd "0" null delete allow out 123/tcp
    fi

    do_cmd "0" null delete allow $i to any
    do_cmd "0" null delete allow $i to any proto udp
    do_cmd "0" null delete allow $i to any proto tcp

    do_cmd "0" null delete allow $i to 10.0.2.101
    do_cmd "0" null delete allow $i to 10.0.2.9
    do_cmd "0" null delete allow $i to 10.0.0.0/16
    do_cmd "0" null delete allow $i to 10.0.2.0/24
    do_cmd "0" null delete allow $i to 10.0.3.0/24
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c/112

    do_cmd "0" null delete allow $i to 10.0.2.101 port 123
    do_cmd "0" null delete allow $i to 10.0.0.0/16 port 123
    do_cmd "0" null delete allow $i to 10.0.2.0/24 port 123
    do_cmd "0" null delete allow $i to 10.0.3.0/24 port 123
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c port 123
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123

    do_cmd "0" null delete allow $i to 10.0.2.101 port 123 proto udp
    do_cmd "0" null delete allow $i to 10.0.0.0/16 app OpenNTPD
    do_cmd "0" null delete allow $i to 10.0.2.0/24 port 123 proto udp
    do_cmd "0" null delete allow $i to 10.0.3.0/24 port 123 proto udp
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c port 123 proto udp
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123 proto udp

    do_cmd "0" null delete allow $i to 10.0.2.101 port 123 proto tcp
    do_cmd "0" null delete allow $i to 10.0.0.0/16 port 123 proto tcp
    do_cmd "0" null delete allow $i to 10.0.2.0/24 port 123 proto tcp
    do_cmd "0" null delete allow $i to 10.0.3.0/24 port 123 proto tcp
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c port 123 proto tcp
    do_cmd "0" null delete allow $i to 2001::211:aaaa:bbbb:d54c/112 port 123 proto tcp
done

echo "show listening (live) with rules" >> $TESTTMP/result
cp -f $TESTPATH/lib/python/ufw/util.py.bak $TESTPATH/lib/python/ufw/util.py
do_cmd "0" null allow 22/tcp
do_cmd "0" null allow 123/udp
do_cmd "0" null show listening
do_cmd "0" null delete allow 22/tcp
do_cmd "0" null delete allow 123/udp

exit 0
