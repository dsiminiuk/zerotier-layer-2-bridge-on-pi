#!/bin/bash

echo Listing Environment variables...
printf '%s\n' " Zerotier Interface: ${ZT_IF}"
printf '%s\n' "Zerotier Network ID: ${NETWORK_ID}"
printf '%s\n' "        Bridge Name: ${BR_IF}"
printf '%s\n' "      LAN Interface: ${LAN_IF}"
printf '%s\n' "     Bridge Address: ${BR_ADDR}"
printf '%s\n' "    Gateway ADdress: ${GW_ADDR}"
printf '%s\n' "        DNS Address: ${DNS_ADDR}"

read -p "Do all values appear to be correct? " yn
case $yn in
     [Yy]* ) echo Proceeding;;
      * ) exit;;
esac

sudo cat << EOF | sudo tee /etc/interfaces
iface $LAN_IF inet manual
EOF

sudo cat << EOF | sudo tee /etc/systemd/network/25-bridge-br0.network
[Match]
Name=$BR_IF
[Network]
Address=$BR_ADDR
Gateway=$GW_ADDR
DNS=$DNS_ADDR
EOF

sudo cat << EOF | sudo tee /etc/systemd/network/br0.netdev
[NetDev]
Name=$BR_IF
Kind=bridge
EOF

sudo cat << EOF | sudo tee /etc/systemd/network/25-bridge-br0-zt.network
[Match]
Name=$ZT_IF
[Network]
Bridge=$BR_IF
EOF

sudo cat << EOF | sudo tee /etc/systemd/network/25-bridge-br0-en.network
[Match]
Name=$LAN_IF
[Network]
Bridge=$BR_IF
EOF

echo Reboot and expect to be able to login via SSH at $BR_ADDR.
