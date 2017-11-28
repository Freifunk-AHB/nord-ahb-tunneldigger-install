#!/bin/bash

## Start Scripte anlegen
cd /srv/tunneldigger/broker/scripts/
rm session-up.sh
rm session-pre-down.sh
wget https://raw.githubusercontent.com/Freifunk-Nord/nord-tunneldigger-install/master/srv/tunneldigger/broker/scripts/session-up.sh
wget https://raw.githubusercontent.com/Freifunk-AHB/nord-tunneldigger-install/master/srv/tunneldigger/broker/scripts/session-pre-down.sh
chmod +x /srv/tunneldigger/broker/scripts/session-up.sh
chmod +x /srv/tunneldigger/broker/scripts/session-pre-down.sh

## iptables Regeln anlegen
touch /etc/iptables.d/500-Allow-tunneldigger
cat <<-EOF>> /etc/iptables.d/500-Allow-tunneldigger
# Allow Service tunneldigger
ip46tables -A wan-input -p udp -m udp --dport 10060 -j ACCEPT -m comment --comment 'tunneldigger'
EOF
build-firewall

# Tunneldigger interface anlegen
cd /etc/network/interfaces.d/
wget https://raw.githubusercontent.com/Freifunk-Nord/nord-tunneldigger-install/master/etc/network/interfaces.d/tunneldigger

## Tunneldiger Start Script
cd /srv/tunneldigger
wget https://github.com/Freifunk-Nord/nord-tunneldigger-install/raw/master/srv/tunneldigger/start-broker.sh
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
