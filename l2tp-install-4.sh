#!/bin/bash

## Start Scripte anlegen
touch /srv/tunneldigger/broker/scripts/session-up.sh
chmod +x /srv/tunneldigger/broker/scripts/session-up.sh
cat <<-EOF>> /srv/tunneldigger/broker/scripts/session-up.sh
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
EOF

touch /srv/tunneldigger/broker/scripts/session-pre-down.sh
chmod +x /srv/tunneldigger/broker/scripts/session-pre-down.sh
cat <<-EOF>> /srv/tunneldigger/broker/scripts/session-pre-down.sh
#!/bin/bash
INTERFACE="$3"
/sbin/brctl delif tunneldigger $INTERFACE
exit 0
EOF

## iptables Regeln anlegen
touch /etc/iptables.d/500-Allow-tunneldigger
cat <<-EOF>> /etc/iptables.d/500-Allow-tunneldigger
# Allow Service tunneldigger
ip46tables -A wan-input -p udp -m udp --dport 10060 -j ACCEPT -m comment --comment 'tunneldigger'
EOF
build-firewall

# Tunneldigger interface anlegen
touch /etc/network/interfaces.d/tunneldigger
cat <<-EOF>> /etc/network/interfaces.d/tunneldigger
# Tunneldigger VPN Interface
auto tunneldigger
iface tunneldigger inet manual
  ## Bring up interface
  pre-up brctl addbr $IFACE
  pre-up ip link set dev $IFACE mtu 1364
  pre-up ip link set $IFACE promisc on
  up ip link set dev $IFACE up
  post-up ebtables -A FORWARD --logical-in $IFACE -j DROP
  post-up modprobe batman_adv
  post-up /usr/sbin/batctl -m bat-ffnord if add $IFACE
  # Shutdown interface
  pre-down /usr/sbin/batctl -m bat-ffnord if del $IFACE
  pre-down ebtables -D FORWARD --logical-in $IFACE -j DROP
  down ip link set dev $IFACE down
  post-down brctl delbr $IFACE
EOF

## Tunneldiger Start Script
cd /srv/tunneldigger
wget https://github.com/Freifunk-AHB/nord-ahb-tunneldigger-install/raw/master/srv/tunneldigger/start-broker.sh
chmod +x start-broker.sh

touch /etc/systemd/system/tunneldigger.service
cat <<-EOF>> /etc/systemd/system/tunneldigger.service
[Unit]
Description = Start tunneldigger L2TPv3 broker
After = network.target

[Service]
ExecStart = /srv/tunneldigger/start-broker.sh

[Install]
WantedBy = multi-user.target
EOF

##Logfiles
mkdir /var/log/tunneldigger
touch /var/log/tunneldigger/tunneldigger-broker.log
cat <<-EOF>> /etc/logrotate.d/tunneldigger
/var/log/tunneldigger/*.log
{
 rotate 1
 daily
 missingok
 sharedscripts
 compress
 postrotate
   invoke-rc.d rsyslog rotate > /dev/null
 endscript
}
EOF

## Tunneldigger systemd Dienst anlegen und aktivieren
systemctl enable tunneldigger
systemctl start tunneldigger
systemctl status tunneldigger

echo check-services um Tunneldigger erweitern
