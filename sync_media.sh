#!/usr/bin/env bash
export SSHPASS='avene';
REMOTE_HOST='rapi-master';
REMOTE_USER='pi';
REMOTE_PATH='/srv/smb/tv';
LOCAL_PATH='/srv/smb/green';
MASTER_PLAYLIST='playlist.tmpl';
LOCAL_PLAYLIST='playlist.local';

# Extract network_id
network_id=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 | cut -d. -f2);
if [[ -z "$network_id" ]]; then
    printf "Error: Failed to retrieve network ID.\n" >&2;
    exit 1;
fi
sources=("master" "${network_id}");
sub_dirs=("")  # Specify additional subdirectories if needed;
# Function to merge playlists
merge_playlist(){
    printf "Merging playlists to IB...\n";
    if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" \
        "cat '${REMOTE_PATH}/master/${MASTER_PLAYLIST}' '${REMOTE_PATH}/${network_id}/${LOCAL_PLAYLIST}'" \
        > "${LOCAL_PATH}/playlist.txt"; then
        printf "Error: Failed to merge playlists.\n" >&2;
        return 1
    fi
}
# Function to sync directories
sync_dir(){
    printf "\nSyncing main...\n";
    local src dir src_path dst_path;
    for src in "${sources[@]}"; do
        for dir in "${sub_dirs[@]}"; do
            src_path="${REMOTE_USER}@${REMOTpT}:${REMOTE_PATH}/${src}${dir}/*.*";
            dst_path="${LOCAL_PATH}${dir}/";
            printf "Syncing %s -> %s\n" "${src_path}" "${dst_path}";
            if ! sshpass -e rsync -av "${src_path}" "${dst_path}"; then
                printf "Error: Sync failed for %s.\n" "${src_path}" >&2;
                return 1;
            fi
        done
    done
}
# Main function to coordinate tasks
main(){
    if ! merge_playlist; then
        printf "Error during playlist merging. Exiting.\n" >&2;
        exit 1;
    fi
    if ! sync_dir; then
        printf "Error during directory sync. Exiting.\n" >&2;
        exit 1;
    fi
}

main "$@";
