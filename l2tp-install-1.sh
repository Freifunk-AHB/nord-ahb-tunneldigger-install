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

#reboot
reboot
