#!/usr/bin/env bash
export SSHPASS='avene'
REMOTE_HOST='rapi-master'
REMOTE_USER="pi"
REMODE_GROUP="ib"
REMOTE_PATH="/srv/smb/tv"
LOCAL_PATH="/srv/smb/green"
LOCAL_USER="pi"
LOCAL_GROUP="ib"

set_local (){
    local src dst;
    src="$REMOTE_USER"@"$REMOTE_HOST":"$REMOTE_PATH"/master/*;
    dst="$LOCAL_PATH"/;
    printf "Copying from: %s to: %s\n" "$src" "$dst";
    install -d -m 0755 -o "${LOCAL_USER}" -g "${LOCAL_GROUP}" "${LOCAL_PATH}";
    if ! sshpass -e scp -o StrictHostKeyChecking=no -p -r "$src" "$dst"; then
        printf "Failed to copy files from: %s to: %s\n" "$src" "$dst" >&2;
        return 1;
    fi
    chown -R "$LOCAL_USER":"$LOCAL_GROUP" ${LOCAL_PATH%/*}/;
    
}
main(){
    printf "Creating local storage in %s\n" "${LOCAL_PATH}";
    if ! set_local; then
        printf "Local storage setup failed. Exiting.\n" >&2;
        exit 1;
    fi;
}
main "$@";