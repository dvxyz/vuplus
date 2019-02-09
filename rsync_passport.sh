#!/bin/bash

rsync -av --no-links --progress --remove-source-files /media/usb/*.{mp4,mkv,ts,ap,cuts,meta,sc,eit} /media/passport/vuuuno4k/

cd /mnt/symlinks
find . -type l -exec rm {} \;
for f in /media/passport/vuuuno4k/*.{mp4,mkv,ts,ap,cuts,meta,sc,eit} ; do ln -nsf "$f" ; done
