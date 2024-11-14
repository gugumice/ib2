#!/bin/bash
set -e

# Extract the current hostname and network identifier
current_hostname=$(cat /proc/sys/kernel/hostname)
ipo=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 | cut -d. -f2)

# Validate IPO and set new hostname
if [[ -z "$ipo" ]]; then
    printf "Error: Failed to retrieve network identifier for IPO.\n" >&2
    exit 1
fi
new_hostname="rapi-ib11-${ipo}"

printf "Changing hostname from %s to %s...\n" "${current_hostname}" "${new_hostname}"

# Update hostname file
if ! printf "%s\n" "${new_hostname}" | sudo tee /etc/hostname >/dev/null; then
    printf "Error: Failed to update /etc/hostname\n" >&2
    exit 1
fi

# Backup /etc/hosts and update it with the new hostname
if ! sudo cp /etc/hosts /etc/hosts.bak; then
    printf "Error: Failed to back up /etc/hosts\n" >&2
    exit 1
fi

# Update the hostname entry in /etc/hosts
if ! sudo sed -i "s/^127\.0\.1\.1\s.*/127.0.1.1\t${new_hostname}/" /etc/hosts; then
    printf "Error: Failed to update /

