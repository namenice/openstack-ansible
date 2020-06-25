#!/bin/bash
apt-get update
apt-get dist-upgrade
apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
  lsof lvm2 ntp ntpdate openssh-server sudo tcpdump vlan python
apt install linux-image-extra-$(uname -r)
echo 'bonding' >> /etc/modules
echo '8021q' >> /etc/modules
service ntp restart