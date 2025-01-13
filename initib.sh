#!/usr/bin/env bash

raspi-config --expand-rootfs > /dev/null
set -e
HOME_DIR='/opt/ib'
check_hostname() {
    #Check if default hostname
    if [[ "$hostname" == ${DEF_HOSTNAME} ]]; then
        printf "Setting hostname, 
        expand fs...\n"
        raspi-config --expand-rootfs > /dev/null
        ${HOME_DIR}/set_hostname.sh
        printf "Rebooting...\n"
        sudo reboot
    fi
}

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
