#!/usr/bin/env bash

# Set the timezone (requires root privileges):
timedatectl set-timezone Europe/Riga

printf "Disable wifi and bluetooth\n"
sed -i '/^# Additional overlays.*/a dtoverlay=pi3-disable-wifi\ndtoverlay=pi3-disable-bt' /boot/config.txt

printf "Setting (symbolic) links to services...\n"
ln -s /opt/ib/ib.service /lib/systemd/system/ib.service 2>/dev/null
ln -s /opt/ib/firstboot.service /lib/systemd/system/firstboot.service 2>/dev/null
# ln -s /opt/secondboot.service /lib/systemd/system/secondboot.service 2>/dev/null

printf "Setting hostname...\n"
source chhost.sh

#printf "Setting media...\n"
#./set_ib.sh

printf "Enable startup service...\n"
systemctl enable firstboot.service

