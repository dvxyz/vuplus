#!/bin/bash

echo "gerade beendet: " "$1" >> /var/log/onrecend.log

/home/root/ffmpeg_mkv.sh "$1"
