#!/usr/bin/env bash
export SSHPASS='avene';
REMOTE_HOST='rapi-master';
REMOTE_USER="pi";
REMOTE_PATH="/srv/smb/tv";
LOCAL_PATH="/srv/smb/green";
MASTER_PLAYLIST="playlist.tmpl"
LOCAL_PLAYLIST="playlist.local"

network_id=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 |  cut -d. -f2);
sources=("master" "${network_id}")
sub_dirs=("")

merge_playlist(){
    printf "Merging playlists to IB...\n";
    sshpass -e ssh -o StrictHostKeyChecking=no $REMOTE_USER"@"$REMOTE_HOST \
        cat "${REMOTE_PATH}/master/${MASTER_PLAYLIST}" "${REMOTE_PATH}/${network_id}/${LOCAL_PLAYLIST}" > "${LOCAL_PATH}/playlist.txt";
}
sync_dir(){
    printf "\nSyncing main...\n";
    local src;
    local dir;
    for src in "${sources[@]}"; do
        for dir in "${sub_dirs[@]}"; do
            local src_path="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/$src${dir}/*.*";
            local dst_path="${LOCAL_PATH}${dir}/";
            printf "Syncing %s -> %s\n" "${src_path}" "${dst_path}";
            sshpass -e rsync -av "${src_path}" "${dst_path}";
        done
    done;
}

main(){
    merge_playlist;
    sync_dir;
}

main "$@";
