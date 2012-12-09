#!/bin/bash

#    Copyright 2008-2011 Canonical Ltd.
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

echo "Bug #237446" >> $TESTTMP/result
do_cmd "0" --dry-run allow to 111.12.34.2/4

# IPv6 Bugs
sed -i 's/IPV6=no/IPV6=yes/' $TESTPATH/etc/default/ufw

echo "proto ipv6 when IPV6=yes" >> $TESTTMP/result
do_cmd "0" --dry-run allow to any proto ipv6

sed -i 's/IPV6=yes/IPV6=no/' $TESTPATH/etc/default/ufw

# End IPv6 Bugs

exit 0
