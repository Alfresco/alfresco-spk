#!/bin/bash
STATIC_IP=192.168.1.223
GW_IP=192.168.1.1
NETMASK=255.255.255.0

echo 'auto eth1' >> /etc/network/interfaces
echo 'iface eth1 inet static' >> /etc/network/interfaces
echo 'address '$STATIC_IP >> /etc/network/interfaces
echo 'netmask '$NETMASK >> /etc/network/interfaces
echo 'gateway '$GW_IP >> /etc/network/interfaces
