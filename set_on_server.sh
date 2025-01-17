#!/usr/bin/env bash
SERVER_USER="pi"
SERVER_GROUP="ib"
SERVER_PATH="/srv/smb/tv"
SERVER_HOSTNAME="rapi-master"
SERVER_USR="pi"
SERVER_GROUP="ib"
net_id=$1; ip_address=$2

main(){
    
    printf "Server ip:%i, subnet id:%s\n" $net_id $ip_address
    set_server_dirs
}
set_server_dirs(){
    local server_dir="$SERVER_PATH"/"$net_id"/;
    local sub_dirs=("" "right" "bottom");
    #If directory exists set permissions
    if [ -d "$server_dir" ]; then
        printf "%s does exist, settng permissions and ownership...\n" "$server_dir";
        chown -R "$SERVER_USER:$SERVER_GROUP" "$server_dir";
        chmod -R -x+X $server_dir;
        exit 0;
    fi;
    #Create directories on server
    for dir in "${sub_dirs[@]}"; do
        printf "Creating directory %s on %s\n" "$SERVER_PATH/$net_id/$dir" "$SERVER_HOSTNAME";
        if ! install -d -m 775 -o "$SERVER_USER" -g "$SERVER_GROUP" "$SERVER_PATH/$net_id/$dir"; then
            printf "Failed to create directory %s on %s\n" "$SERVER_PATH/$net_id/$dir" "$SERVER_HOSTNAME" >&2;
            return 1;
        fi;
    done;
    printf "%s, IP address: %s\n" "$(date +"%Y-%m-%d %H.%M.%S")" "$ip_address" > "$SERVER_PATH/$net_id/ip_address.txt"
    printf "Creating files\n"
    touch "$SERVER_PATH/$net_id/playlist.local"
    cp "$SERVER_PATH/master/playlist.tmpl" "${SERVER_PATH}/${network_id}/playlist.txt"
    cp "$SERVER_PATH/master/right/work_hours.txt" "${SERVER_PATH}/${net_id}/right/work_hours.txt"
    cp "$SERVER_PATH/master/bottom/news_2.txt" "${SERVER_PATH}/${net_id}/bottom/news_2.txt"

    }
main "$@";