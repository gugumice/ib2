#!/usr/bin/env bash

export SSHPASS='avene'
REMOTE_HOST='rapi-master'
REMOTE_USER="pi"
REMODE_GROUP="ib"
REMOTE_PATH="/srv/smb/tv"
LOCAL_PATH="/srv/smb/green"
LOCAL_USER="pi"
LOCAL_GROUP="ib"
LOCAL_SCRIPT="/opt/ib/set_on_server.sh"
date_time=$(date +"%Y-%m-%d %H.%M.%S")

rpi_ip=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
if [[ -z "$rpi_ip" ]]; then
    printf "Error: Failed to retrieve network ID.\n" >&2
    exit 1
fi
network_id=$(echo $rpi_ip | cut -d. -f2)
sub_dirs=("" "right" "bottom")

# Create directories on the remote host
set_remote (){
    sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" 'bash -s' < "$LOCAL_SCRIPT" $network_id $rpi_ip
}

# Main function to coordinate tasks
main(){
    printf "Starting setup at %s, network ID: %s, IP: %s\n" "${date_time}" "${network_id}" "${rpi_ip}";
    printf "Creating remote dirs on %s\n" "${REMOTE_PATH}/${network_id}"
    if ! set_remote; then
        printf "Remote setup failed. Exiting.\n" >&2;
        exit 1;
    fi;
    printf "Seting permissions on server\n";
    if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" \
        chown -R "${REMOTE_USER}:${REMOTE_GROUP}" "${REMOTE_PATH}/${network_id}" && \
        chmod -R ug+rwX,o+X "${REMOTE_PATH}/${network_id}"; then
        printf "Error setting permissions: Remote setup commands failed on %s\n" "${REMOTE_HOST}" >&2
        exit 1;
    fi;
}

main "$@";
