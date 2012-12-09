#!/bin/sh -e

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
#
#    WARNING: this script is not for production use. It's intended use is
#    for debugging.

user_and_host="$1"

count=0
while /bin/true ; do
    sleep 10
    out=`ssh -t $user_and_host 'sudo ufw status && sudo reboot' 2>&1` || {
        echo "Ssh command exited non-zero, trying again"
        continue
    }
    if echo "$out" | grep -q 'inactive'; then
        echo "FAILED after $count attempts: $out"
        exit 1
    fi
    echo "Success: $count: $out"
    count=$((count+1))
done

