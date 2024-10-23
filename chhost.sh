!/bin/bash
set -e

CURRENT_HOSTNAME=$(cat /proc/sys/kernel/hostname)
IPO=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1 |  cut -d. -f2);
NEW_HOSTNAME="rapi-ib11-"$IPO

echo "Changing hostname from ${CURRENT_HOSTNAME} ${NEW_HOSTNAME}..."
#Update hostname file
printf "%s\n" "${NEW_HOSTNAME}" | sudo tee /etc/hostname >/dev/null

#Update hosts
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t${NEW_HOSTNAME}/g" /etc/hosts
