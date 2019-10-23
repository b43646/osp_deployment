#!/bin/sh
ip link add link virbr2 name virbr2.501 type vlan id 501
ifconfig virbr2.501 10.0.0.1/24 up

cat >/etc/sysconfig/network-scripts/ifcfg-virbr2.501 <<EOF
DEVICE=virbr2.501
ONBOOT=yes
NM_CONTROLLED="no"
IPADDR=10.0.0.1
PREFIX=24
VLAN=yes
ZONE=external
EOF
ifup virbr2.501

firewall-cmd --zone=external --add-interface=virbr2.501 --permanent
firewall-cmd --zone=dmz --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --reload
