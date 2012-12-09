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

echo "TESTING ARGS (logging)" >> $TESTTMP/result
do_cmd "0" --dry-run logging on
do_cmd "0" --dry-run logging off
do_cmd "0" --dry-run LOGGING ON
do_cmd "0" --dry-run LOGGING OFF

echo "TESTING ARGS (default)" >> $TESTTMP/result
do_cmd "0" --dry-run default allow
do_cmd "0" --dry-run default deny
do_cmd "0" --dry-run default reject
do_cmd "0" --dry-run DEFAULT ALLOW
do_cmd "0" --dry-run DEFAULT DENY
do_cmd "0" --dry-run DEFAULT REJECT

echo "TESTING ARGS (enable/disable)" >> $TESTTMP/result || exit 1
do_cmd "0" --dry-run enable
do_cmd "0" --dry-run disable
do_cmd "0" --dry-run ENABLE
do_cmd "0" --dry-run DISABLE

echo "TESTING ARGS (status)" >> $TESTTMP/result || exit 1
do_cmd "0" --dry-run status

exit 0
