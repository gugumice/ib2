#!/usr/bin/env bash

raspi-config --expand-rootfs > /dev/null
set -e
./set_ib.sh
systemctl enable ib.service
systemctl disable firstboot.service

/sbin/shutdown -r now
