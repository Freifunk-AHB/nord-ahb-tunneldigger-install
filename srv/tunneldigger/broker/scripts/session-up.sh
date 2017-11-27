#!/bin/bash

INTERFACE="$3"
UUID="$8"

log_message() {
      message="$1"
      logger -p 6 -t "Tunneldigger" "$message"
      echo "$message" | systemd-cat -p info -t "Tunneldigger"
      echo "$1" 1>&2
}

if /bin/grep -Fq $UUID /srv/tunneldigger/broker/blacklist; then
      log_message "New client with UUID=$UUID is blacklisted, not adding to tunneldigger bridge interface"
else
      log_message "New client with UUID=$UUID connected, adding to tunneldigger bridge interface"
      ip link set dev $INTERFACE up mtu 1364
      /sbin/brctl addif tunneldigger $INTERFACE
fi

