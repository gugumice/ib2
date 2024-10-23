#!/usr/bin/env bash
export SSHPASS='avene'
REMOTE_HOST='rapi-master';
REMOTE_USER="pi";
REMOTE_PATH="/srv/smb/tv/";
LOCAL_PATH="/srv/smb/green/";
LOCAL_USER="pi";
LOCAL_GROUP="ib";

date_time=$(date +"%Y-%m-%d %H.%M.%S");
network_id=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 |  cut -d. -f2);

rpi_ip="$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)";
sub_dirs=("" "right" "bottom")

set_remote (){
    for dir in "${sub_dirs[@]}"; do
        local dest_path="${REMOTE_PATH}${network_id}/${dir}/";
        #echo $dest_path;
        if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" " mkdir -p ${dest_path}"; then
            printf "Failed to create directory %s on %s\n" "${dest_path}"  "${REMOTE_HOST}" >&2;
        fi
    done
    sshpass -e ssh -o StrictHostKeyChecking=no $REMOTE_USER"@"$REMOTE_HOST \
        "echo ${rpi_ip} ${date_time}>${REMOTE_PATH}${network_id}/ip_address.txt && \
        touch ${REMOTE_PATH}${network_id}/playlist.local && \
        cp ${REMOTE_PATH}master/playlist.tmpl ${REMOTE_PATH}${network_id}/playlist.txt && \
        cp ${REMOTE_PATH}master/right/*.txt ${REMOTE_PATH}${network_id}/right/ && \
        cp ${REMOTE_PATH}master/bottom/*.txt ${REMOTE_PATH}${network_id}/bottom/";
}
main(){
    echo "Starting... $date_time $network_id $rpi_ip";
    addgroup "${LOCAL_GROUP}"
    usermod -aG "$LOCAL_GROUP ${LOCAL_USER}"
    if [[ ! -d "$LOCAL_PATH" ]]; then
        for dir in "${sub_dirs[@]}"; do
            full_path="${LOCAL_PATH}/${dir}"|| { printf "Failed to create subdirectory: %s\n" "${full_path}" >&2; };
            echo "Creating local ${full_path}";
            if ! mkdir -p "${full_path}"; then
                printf "Failed to create directory: %s\n" "${full_path}" >&2;
            fi
        done
    fi

    for dir in "${sub_dirs[@]}"; do
        echo "Syncing ${REMOTE_USER}@${REMOTE_HOST}":"${REMOTE_PATH}master/${dir} ${LOCAL_PATH}${dir}";
        if ! rsync -avz --rsh='sshpass -e ssh -o StrictHostKeyChecking=no' "$REMOTE_USER"@"$REMOTE_HOST":"$REMOTE_PATH""master/""$dir" "$LOCAL_PATH""$dir"; then
            printf "Failed to copy files from %s to %s\n" "${REMOTE_PATH}" "${LOCAL_PATH}" >&2;
        fi
    done

    full_path="${REMOTE_HOST} ${REMOTE_PATH}${network_id}/";
    set_remote;
    chown -R "$LOCAL_USER:$LOCAL_GROUP" "$LOCAL_PATH";
}
main;
