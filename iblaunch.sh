#!/usr/bin/env bash
export DISPLAY=:0
export INFOBEAMER_ADDR=0
export INFOBEAMER_LOG_LEVEL=1
export INFOBEAMER_AUDIO_TARGET=hdmi
export INFOBEAMER_SWAP_INTERVAL=3
export INFOBEAMER_THREAD_POOL=12
export INFOBEAMER_WATCHDOG=30
exec /opt/ib/info-beamer-pi/info-beamer /srv/smb/green/
#exec /opt/ib/info-beamer-pi/info-beamer /opt/ib/info-beamer-pi/samples/green/