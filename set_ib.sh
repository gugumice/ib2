#!/usr/bin/env bash
export SSHPASS='avene'
REMOTE_HOST='rapi-master';
REMOTE_USER="pi";
REMOTE_PATH="/srv/smb/tv";
LOCAL_PATH="/srv/smb/green";
LOCAL_USER="pi";
LOCAL_GROUP="ib";

date_time=$(date +"%Y-%m-%d %H.%M.%S");
network_id=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 |  cut -d. -f2);
rpi_ip="$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)";
sub_dirs=("" "right" "bottom")

set_remote (){
    local dir
    for dir in "${sub_dirs[@]}"; do
        local dest_path="${REMOTE_PATH}${network_id}/${dir}/";
        if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" " mkdir -p ${dest_path}"; then
            printf "Failed to create directory %s on %s\n" "${dest_path}"  "${REMOTE_HOST}" >&2;
        fi
    done
    sshpass -e ssh -o StrictHostKeyChecking=no $REMOTE_USER"@"$REMOTE_HOST \
        "echo ${rpi_ip} ${date_time}>${REMOTE_PATH}${network_id}/ip_address.txt && \
        touch ${REMOTE_PATH}/${network_id}/playlist.local && \
        cp ${REMOTE_PATH}/master/playlist.tmpl ${REMOTE_PATH}${network_id}/playlist.txt && \
        cp ${REMOTE_PATH}/master/right/*.txt ${REMOTE_PATH}${network_id}/right/ && \
        cp ${REMOTE_PATH}/master/bottom/*.txt ${REMOTE_PATH}${network_id}/bottom/";
}
set_local (){
    local dir;
    local l_path;
    for dir in "${sub_dirs[@]}"; do
        l_path="${LOCAL_PATH}/${dir}";
        printf "%s\n" "${l_path}";
        mkdir -p "${l_path}";
        printf "Sync %s -> %s\n" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}";
        sshpass -e rsync -av "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/master/${dir}/*.*" "${l_path}";
    done
    chown -R ${LOCAL_USER}:${LOCAL_GROUP} ${LOCAL_PATH};
    chmod -R 775 ${LOCAL_PATH};
}

main(){   
    printf "Starting setup %s, net id:%s, IP:%s" "${date_time}" "${network_id}" "${rpi_ip}";
    set_remote;
    set_local;
}

main "$@";
