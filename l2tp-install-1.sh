#!/bin/bash

#Kernel Module laden
modprobe ip_conntrack l2tp_core l2tp_eth l2tp_netlink ebtables nf_conntrack_netlink nf_conntrack nfnetlink

##Module rebootfest machen
cat <<-EOF>> /etc/modules
l2tp_core
l2tp_eth
l2tp_netlink
ebtables
nf_conntrack_netlink
nf_conntrack
nfnetlink
nf_conntrack_netlink
nf_conntrack
l2tp_core
l2tp_eth
l2tp_netlink
ebtables
EOF

# Abhängigkeiten installieren
apt install -y iproute bridge-utils libnetfilter-conntrack3 python-dev libevent-dev ebtables python-virtualenv

#reboot
reboot
