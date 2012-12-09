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

echo "TESTING VALID CIDR" >> $TESTTMP/result
for i in $(seq 0 32); do
    do_cmd "0" null --dry-run allow from 10.0.0.1/$i
done

echo "TESTING VALID DOTTED" >> $TESTTMP/result
for i in $(seq 0 16 255); do
    do_cmd "0" null --dry-run allow from 10.0.0.1/255.255.255.$i
    do_cmd "0" null --dry-run allow from 10.0.0.1/255.255.$i.255
    do_cmd "0" null --dry-run allow from 10.0.0.1/255.$i.255.255
    do_cmd "0" null --dry-run allow from 10.0.0.1/$i.255.255.255
    do_cmd "0" null --dry-run allow from 10.0.0.1/$i.$i.$i.$i
done

exit 0
