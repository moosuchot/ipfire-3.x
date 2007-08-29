#!/bin/sh
###############################################################################
#                                                                             #
# IPFire.org - A linux based firewall                                         #
# Copyright (C) 2007  Michael Tremer & Christian Schmidt                      #
#                                                                             #
# This program is free software: you can redistribute it and/or modify        #
# it under the terms of the GNU General Public License as published by        #
# the Free Software Foundation, either version 3 of the License, or           #
# (at your option) any later version.                                         #
#                                                                             #
# This program is distributed in the hope that it will be useful,             #
# but WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
# GNU General Public License for more details.                                #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.       #
#                                                                             #
###############################################################################

echo "Scanning for possible destination drives"

# scan IDE devices
echo "--> IDE"
for DEVICE in $(kudzu -qps -t 30 -c HD -b IDE | grep device: | cut -d ' ' -f 2 | sort | uniq); do
		mount /dev/${DEVICE}1 /harddisk 2> /dev/null
		if [ -n "$(ls /harddisk/ipfire-*.tbz2 2>/dev/null)" ]; then
			umount /harddisk 2> /dev/null
			echo "${DEVICE} is source drive - SKIP"
			continue
		else
			umount /harddisk 2> /dev/null
			echo -n "$DEVICE" > /tmp/dest_device
			echo "${DEVICE} - yes, it is our destination"
			exit 0
		fi
done

# scan USB/SCSI devices
echo "--> USB/SCSI"
for DEVICE in $(kudzu -qps -t 30 -c HD -b SCSI | grep device: | cut -d ' ' -f 2 | sort | uniq); do
		mount /dev/${DEVICE}1 /harddisk 2> /dev/null
		if [ -n "$(ls /harddisk/ipfire-*.tbz2 2>/dev/null)" ]; then
			umount /harddisk 2> /dev/null
			echo "${DEVICE} is source drive - SKIP"
			continue
		else
			umount /harddisk 2> /dev/null
			echo -n "$DEVICE" > /tmp/dest_device
			echo "${DEVICE} - yes, it is our destination"
			exit 1
		fi
done

# scan RAID devices
echo "--> RAID"
for DEVICE in $(kudzu -qps -t 30 -c HD -b RAID | grep device: | cut -d ' ' -f 2 | sort | uniq); do
		mount /dev/${DEVICE}p1 /harddisk 2> /dev/null
		if [ -n "$(ls /harddisk/ipfire-*.tbz2 2>/dev/null)" ]; then
			umount /harddisk 2> /dev/null
			echo "${DEVICE} is source drive - SKIP"
			continue
		else
			umount /harddisk 2> /dev/null
			echo -n "$DEVICE" > /tmp/dest_device
			echo "${DEVICE} - yes, it is our destination"
			exit 2
		fi
done

exit 10 # Nothing found
