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

#set -x

source "$TESTPATH/../testlib.sh"

# example usage for successful run
#do_cmd "0" --dry-run allow 53

# example usage for successful run, without putting the output into the
# results file
#do_cmd "0" null --dry-run allow 53

# example usage for failed run
#do_cmd "1" --dry-run allow 53a

# example usage for failed run, without putting the failure output into the
# results file
#do_cmd "1" null --dry-run allow 53a

# remove this when implementing real test
touch $TESTTMP/result || exit 1

# live tests should do this
# cleanup

exit 0

