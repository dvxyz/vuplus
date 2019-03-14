#!/bin/bash

cd && cd comskip/comskipCutsConverter
find /media/vuuno4k/ts/ -iname '*.ts' -size -4G -mmin +5 -exec ln -nsf {} ./cuts/ \;
pwd
for f in ./cuts/*.ts ; do
 if [[ ! -f "$f.cuts" ]]; then
  php build/comskipCutsConverter.phar "$f";
 fi  
done

scp ./cuts/*.cuts root@192.168.0.10:/mnt/usb/ 
