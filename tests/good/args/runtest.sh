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

echo "TESTING ARGS (logging)" >> $TESTTMP/result
do_cmd "0" --dry-run logging on
do_cmd "0" --dry-run logging off
do_cmd "0" --dry-run LOGGING ON
do_cmd "0" --dry-run LOGGING OFF

echo "TESTING ARGS (enable/disable)" >> $TESTTMP/result || exit 1
do_cmd "0" --dry-run enable
do_cmd "0" --dry-run disable
do_cmd "0" --dry-run ENABLE
do_cmd "0" --dry-run DISABLE

echo "TESTING ARGS (status)" >> $TESTTMP/result || exit 1
do_cmd "0" --dry-run status
do_cmd "0" --dry-run status verbose
do_cmd "0" --dry-run status numbered

echo "Testing parser" >> $TESTTMP/result || exit 1
echo "Basic" >> $TESTTMP/result || exit 1
cmds="enable disable help --help version --version reload"
for i in $cmds; do
    do_cmd "0" null --dry-run $i
done

echo "Application" >> $TESTTMP/result || exit 1
cmds="list info default update"
do_cmd "0" null --dry-run app list
do_cmd "0" null --dry-run app info Apache
do_cmd "0" null --dry-run app update Apache
do_cmd "0" null --dry-run app update --add-new Apache
do_cmd "0" null --dry-run app default skip

echo "Logging" >> $TESTTMP/result || exit 1
cmds="on off low medium high full"
for i in $cmds; do
    do_cmd "0" null --dry-run logging $i
done

echo "Default" >> $TESTTMP/result || exit 1
cmds="allow deny reject"
for i in $cmds; do
    do_cmd "0" null --dry-run default $i
    do_cmd "0" null --dry-run default $i incoming
    do_cmd "0" null --dry-run default $i outgoing
done

echo "Status" >> $TESTTMP/result || exit 1
for i in "" verbose numbered; do
    do_cmd "0" null --dry-run status $i
done

echo "Show" >> $TESTTMP/result || exit 1
cmds="raw builtins before-rules user-rules after-rules logging-rules"
for i in $cmds; do
    do_cmd "0" null --dry-run show $i
done

echo "Rules" >> $TESTTMP/result || exit 1
do_cmd "0" null allow 80
do_cmd "0" null --dry-run insert 1 allow 53
do_cmd "0" null delete allow 80
do_cmd "0" null --dry-run allow in 53
do_cmd "0" null --dry-run allow log 53
do_cmd "0" null --dry-run allow in log 53

do_cmd "0" null deny to any port 80 from any proto tcp
do_cmd "0" null --dry-run insert 1 deny to any port 53 from any proto udp
do_cmd "0" null delete deny to any port 80 from any proto tcp
do_cmd "0" null --dry-run deny out to any port 53 from any proto udp
do_cmd "0" null --dry-run deny log-all to any port 53 from any proto udp
do_cmd "0" null --dry-run deny out log-all to any port 53 from any proto udp

echo "TESTING ARGS (--force enable)" >> $TESTTMP/result || exit 1
do_cmd "0" --dry-run --force enable
do_cmd "0" --dry-run -f enable
do_cmd "0" --dry-run --force ENABLE
do_cmd "0" --dry-run -f ENABLE

exit 0
