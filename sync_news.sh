#!/usr/bin/env bash
export SSHPASS='avene'
REMOTE_HOST='rapi-master'
REMOTE_USER="pi"
REMOTE_PATH="/srv/smb/tv/"
LOCAL_PATH="/srv/smb/green/"
NETWORK_ID=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 | cut -d. -f2)

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &>/dev/null; then
        printf "Error: Command '%s' not found.\n" "$1" >&2
        return 1
    fi
}

# Function to copy files from remote server
copy_from_server() {
    local src="$1"
    local dst="$2"
    printf "Copying from: %s to: %s\n" "$src" "$dst"
    if ! sshpass -e scp -o StrictHostKeyChecking=no "$src" "$dst"; then
        printf "Failed to copy files from: %s to: %s\n" "$src" "$dst" >&2
        return 1
    fi
}

# Main function
main() {
    # Validate required commands
    for cmd in sshpass ssh scp; do
        if ! check_command "$cmd"; then
            return 1
        fi
    done

    # Define source and destination paths
    local src dst

    # Working hours in the right panel
    src="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}${NETWORK_ID}/right/*.txt"
    dst="${LOCAL_PATH}right/"
    copy_from_server "$src" "$dst"

    # Second scrolling news line
    src="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}${NETWORK_ID}/bottom/news_2.txt"
    dst="${LOCAL_PATH}bottom/"
    copy_from_server "$src" "$dst"

    # First scrolling news line
    src="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}news_1.txt"
    dst="${LOCAL_PATH}bottom/"
    copy_from_server "$src" "$dst"

    # Sync master and local playlists
    printf "Syncing master and local playlists\n"
    if ! sshpass -e ssh -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" \
        "cat ${REMOTE_PATH}${NETWORK_ID}/playlist.local > ${REMOTE_PATH}${NETWORK_ID}/playlist.txt && \
         cat ${REMOTE_PATH}master/playlist.tmpl >> ${REMOTE_PATH}${NETWORK_ID}/playlist.txt"; then
        printf "Failed to sync playlists.\n" >&2
        return 1
    fi

    # Handle file descriptors safely
    local file1="/srv/smb/green/bottom/node.lua"
    local file2="/srv/smb/green/right/node.lua"

    if [[ -f $file1 ]]; then
        exec 3<"$file1"
        exec 3>&-
    else
        printf "File not found: %s\n" "$file1" >&2
    fi

    if [[ -f $file2 ]]; then
        exec 3<"$file2"
        exec 3>&-
    else
        printf "File not found: %s\n" "$file2" >&2
    fi
}

main "$@"
