#!/bin/bash
set -e

echo "Cleaning VM before OVA export..."

# Remove vagrant user and home
deluser vagrant || true
rm -rf /home/vagrant

# Remove SSH keys
rm -f /root/.ssh/authorized_keys /etc/ssh/ssh_host_*

# Remove vagrant entries in passwd/shadow/group
sed -i '/^vagrant/d' /etc/passwd- /etc/shadow- /etc/group- || true

# Remove logs and caches
rm -rf /var/log/* /tmp/* /var/tmp/* /var/cache/apk/*

# Zero out free space
dd if=/dev/zero of=/zerofile bs=1M || true
rm -f /zerofile

# Remove shell history
rm -f /root/.ash_history

# Shutdown VM cleanly
poweroff

