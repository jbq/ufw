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

#set -x

source "$TESTPATH/../testlib.sh"

echo "TESTING INVALID CIDR" >> $TESTTMP/result
for i in 16a 33 -1; do
    do_cmd "1" null --dry-run allow to 10.0.0.1/$i
    do_cmd "1" null --dry-run allow from 10.0.0.1/$i
done

echo "TESTING INVALID DOTTED" >> $TESTTMP/result
do_cmd "1" null --dry-run allow to 192.168.0.0/256.255.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.256.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.256.256.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.255.256
do_cmd "1" null --dry-run allow to 192.168.0.0/256.256.256.256
do_cmd "1" null --dry-run allow from 192.168.0.0/256.255.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.256.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.256.256.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.255.256
do_cmd "1" null --dry-run allow from 192.168.0.0/256.256.256.256
do_cmd "1" null --dry-run allow from 192.168.0.0/33 to 192.168.0.0/256.256.256.256
do_cmd "1" null --dry-run allow to 192.168.0.0/.255.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.255.
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/s55.255.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.2s5.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.25s.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.255.s55
do_cmd "1" null --dry-run allow to 192.168.0.0/s55.s55.s55.s55
do_cmd "1" null --dry-run allow to 192.168.0.0/-1.255.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.-1.255.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.-1.255
do_cmd "1" null --dry-run allow to 192.168.0.0/255.255.255.-1
do_cmd "1" null --dry-run allow to 192.168.0.0/-1.-1.-1.-1
do_cmd "1" null --dry-run allow from 192.168.0.0/.255.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.255.
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/s55.255.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.2s5.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.25s.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.255.s55
do_cmd "1" null --dry-run allow from 192.168.0.0/s55.s55.s55.s55
do_cmd "1" null --dry-run allow from 192.168.0.0/-1.255.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.-1.255.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.-1.255
do_cmd "1" null --dry-run allow from 192.168.0.0/255.255.255.-1
do_cmd "1" null --dry-run allow from 192.168.0.0/-1.-1.-1.-1

exit 0
