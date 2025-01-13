#!/usr/bin/env bash

raspi-config --expand-rootfs > /dev/null
set -e
HOME_DIR='/opt/ib'
${HOME_DIR}/set_ib.sh
#Get media &news
"${HOME_DIR}/sync_media.sh"
"${HOME_DIR}/sync_news.sh"
#Set crontab enteries
printf "Setting crontab enteries\n locally\n"
"${HOME_DIR}/set_cronjobs.sh"
 printf "Setting hostname...\n"
${HOME_DIR}/set_hostname.sh"
sleep 2

systemctl enable ib.service
systemctl disable firstboot.service

/sbin/shutdown -r now
