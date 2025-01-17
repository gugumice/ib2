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

# Create local directories and synchronize content
set_local (){
    local dir l_path;
    install -d -m 0755 -o "${LOCAL_USER}" -g "${LOCAL_GROUP}" "${LOCAL_PATH}"
    for dir in "${sub_dirs[@]}"; do
        l_path="${LOCAL_PATH}/${dir}";
        printf "Syncing %s -> %s\n" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}";
        if ! sshpass -e rsync -av "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}"; then
            printf "Error: Sync failed for directory %s.\n" "${dir}" >&2;
            return 1;
        fi
    done
}

# Main function to coordinate tasks
main(){
    printf "Starting setup at %s, network ID: %s, IP: %s\n" "${date_time}" "${network_id}" "${rpi_ip}";
    printf "Creating remote dirs on %s\n" "${REMOTE_PATH}/${network_id}"
    if ! set_remote; then
        printf "Remote setup failed. Exiting.\n" >&2;
        exit 1;
    fi;
    printf "Creating local dirs on %s\n" "${LOCAL_PATH}";
    if ! set_local; then
        printf "Local setup failed. Exiting.\n" >&2;
        exit 1;
    fi;

    printf "Setting permissions on local\n";
    if ! chown -R "${LOCAL_USER}:${LOCAL_GROUP}" "${LOCAL_PATH}" || ! chmod -R ug+rwX,o+X "${LOCAL_PATH}"; then
        printf "Error: Failed to set permissions on %s\n" "${LOCAL_PATH}" >&2;
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
