#!/usr/bin/env bash

# Set the timezone (requires root privileges):
# Create local directories and synchronize content

timedatectl set-timezone Europe/Riga;
printf "Disable wifi and bluetooth\n";
sed -i '/^# Additional overlays.*/a dtoverlay=pi3-disable-wifi\ndtoverlay=pi3-disable-bt' /boot/config.txt;

printf "Setting (symbolic) links to services...\n";
ln -s /opt/ib/ib.service /lib/systemd/system/ib.service 2>/dev/null;
ln -s /opt/ib/firstboot.service /lib/systemd/system/firstboot.service 2>/dev/null;

printf "Installing sshpass...\n";
apt-get update;
apt-get install sshpass -y;

printf "Enable startup service...\n";
systemctl enable firstboot.service;

printf "Creating local directories...\n";
./opt/ib/set_local.sh;


