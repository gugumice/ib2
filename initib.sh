#!/usr/bin/env bash

raspi-config --expand-rootfs > /dev/null;
set -e;
HOME_DIR='/opt/ib';
DEF_HOSTNAME='rapi-ib11';

check_hostname() {
    #Check if default hostname
    local current_hostname; current_hostname=$(cat /proc/sys/kernel/hostname);
    if [[ "${current_hostname}" == "${DEF_HOSTNAME}" ]]; then
        printf "Setting hostname,  expand fs...\n";
        raspi-config --expand-rootfs > /dev/null;
        ${HOME_DIR}/set_hostname.sh;
        printf "Rebooting...\n";
        sleep 2
        sudo reboot;
    fi
}
main(){
    if ! "${HOME_DIR}/set_hostname"; then
        printf "Error setting hostname\n";
    fi
    if ! "${HOME_DIR}/set_ib.sh"; then
        printf "Error setting remote storage\n";
    fi;
    printf "Setting crontab enteries\n locally\n";
    if ! "${HOME_DIR}/set_cronjobs.sh"; then
        printf "Error setting crontab\n";
    fi;
    #Get media &news
    #"${HOME_DIR}/sync_media.sh";
    if ! "${HOME_DIR}/sync_news.sh"; then
        printf "Error setting syncing news\n";
    fi;
    #Set crontab enteries
    sleep 1;
    if ! "${HOME_DIR}/set_cronjobs.sh"; then
        printf "Error setting cron jobs\n";
    fi;
    systemctl enable ib.service;
    systemctl disable firstboot.service;
}
main "$@"
/sbin/shutdown -r now
