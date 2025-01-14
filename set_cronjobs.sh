#!/usr/bin/env bash

TARGET='crontab.update'
# Save current crontab configuraton
#crontab -l | tee "$TARGET"
#Add snteries
echo '@reboot sleep 15 && /opt/ib/sync_media.sh > /home/pi/st_media.log 2>&1 && /opt/ib/sync_news.sh > /home/pi/st_news.log 2>&1 && systemctl restart ib.service' > "$TARGET"
echo '*/10 * * * * /opt/ib/sync_news.sh > /home/pi/st_news.log 2>&1' >> "$TARGET"
echo '00 05 * * * reboot' >> "$TARGET"
echo '*/01 * * * * echo Test: $(date) > /home/pi/test.txt' >> "$TARGET"
crontab "$TARGET"                                                                                                                                                                                                                                                                                                      "$TARGET"
#Cleanup
rm "$TARGET"
crontab -l
