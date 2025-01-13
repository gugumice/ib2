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
    check_hostname;
    ${HOME_DIR}/set_ib.sh;
    #Get media &news
    "${HOME_DIR}/sync_media.sh";
    "${HOME_DIR}/sync_news.sh";
    #Set crontab enteries
    printf "Setting crontab enteries\n locally\n";
    "${HOME_DIR}/set_cronjobs.sh";
    sleep 2;
    printf "Setting cronjobs\n";
    systemctl enable ib.service;
    systemctl disable firstboot.service;
}
main "$@"
/sbin/shutdown -r now
