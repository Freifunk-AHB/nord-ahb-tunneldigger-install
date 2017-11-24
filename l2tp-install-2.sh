#!/bin/bash

#Abhängigkeiten installieren
apt install -y iproute bridge-utils libnetfilter-conntrack3 python-dev libevent-dev ebtables python-virtualenv

#Tunneldigger clonen und installieren
cd /srv
git clone git://github.com/ffrl/tunneldigger.git
virtualenv tunneldigger
cd /srv/tunneldigger
source bin/activate
pip install -r broker/requirements.txt
cd broker/

##Tunneldigger cfg anlegen
## address = IPv4 von eth0
touch l2tp_broker.cfg
cat <<-EOF>> l2tp_broker.cfg
[broker]
address=167.114.243.46
port=10060
interface=eth0
max_cookies=50
max_tunnels=50
port_base=20000
tunnel_id_base=100
tunnel_timeout=60
pmtu_discovery=false
namespace=experiments
check_modules=true

[log]
filename=tunneldigger-broker.log
verbosity=DEBUG
log_ip_addresses=false

[hooks]
session.up=/srv/tunneldigger/broker/scripts/session-up.sh
session.pre-down=/srv/tunneldigger/broker/scripts/session-pre-down.sh
EOF

##Tunneldigger User verlassen
exit
