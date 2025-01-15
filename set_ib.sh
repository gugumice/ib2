#!/usr/bin/env bash

export SSHPASS='avene'
REMOTE_HOST='rapi-master'
REMOTE_USER="pi"
REMOTE_PATH="/srv/smb/tv"
LOCAL_PATH="/srv/smb/green"
LOCAL_USER="pi"
LOCAL_GROUP="ib"

date_time=$(date +"%Y-%m-%d %H.%M.%S")
network_id=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 | cut -d. -f2)
if [[ -z "$network_id" ]]; then
    printf "Error: Failed to retrieve network ID.\n" >&2
    exit 1
fi

rpi_ip=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
if [[ -z "$rpi_ip" ]]; then
    printf "Error: Failed to retrieve RPi IP address.\n" >&2
    exit 1
fi
sub_dirs=("" "right" "bottom")

# Create directories on the remote host
set_remote (){
    local dir dest_path
    for dir in "${sub_dirs[@]}"; do
        dest_path="${REMOTE_PATH}/${network_id}/${dir}/"
        if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p '${dest_path}'"; then
            printf "Failed to create directory %s on %s\n" "${dest_path}" "${REMOTE_HOST}" >&2
            return 1
        fi
    done
    
    if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" \
        "echo '${rpi_ip} ${date_time}' > '${REMOTE_PATH}/${network_id}/ip_address.txt' && \
        touch '${REMOTE_PATH}/${network_id}/playlist.local' && \
        cp '${REMOTE_PATH}/master/playlist.tmpl' '${REMOTE_PATH}/${network_id}/playlist.txt' && \
        #cp '${REMOTE_PATH}/master/right/'*.txt '${REMOTE_PATH}/${network_id}/right/' && \
        if [[ ! -f '${REMOTE_PATH}/${network_id}/right/*.txt' ]]; then cp '${REMOTE_PATH}/master/right/'*.txt '${REMOTE_PATH}/${network_id}/right/'; fi && \
        cp '${REMOTE_PATH}/master/bottom/'*.txt '${REMOTE_PATH}/${network_id}/bottom/'"; then
        printf "Error: Remote setup commands failed on %s\n" "${REMOTE_HOST}" >&2
        return 1
    fi
}

# Create local directories and synchronize content
set_local (){
    local dir l_path;
    for dir in "${sub_dirs[@]}"; do
        l_path="${LOCAL_PATH}/${dir}";
        mkdir -p "${l_path}";
        
        printf "Syncing %s -> %s\n" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}";
        if ! sshpass -e rsync -av "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}"; then
            printf "Error: Sync failed for directory %s.\n" "${dir}" >&2;
            return 1;
        fi
    done
    
    if ! chown -R "${LOCAL_USER}:${LOCAL_GROUP}" "${LOCAL_PATH}" || ! chmod -R 775 "${LOCAL_PATH}"; then
        printf "Error: Failed to set permissions on %s\n" "${LOCAL_PATH}" >&2;
        return 1;
    fi
}

# Main function to coordinate tasks
main(){
    printf "Starting setup at %s, network ID: %s, IP: %s\n" "${date_time}" "${network_id}" "${rpi_ip}";
    
    if ! set_remote; then
        printf "Remote setup failed. Exiting.\n" >&2;
        exit 1;
    fi
    
    if ! set_local; then
        printf "Local setup failed. Exiting.\n" >&2;
        exit 1;
    fi
    chmod -R a-x,u=rwX,go=rX "${LOCAL_PATH}";
}

main "$@";
