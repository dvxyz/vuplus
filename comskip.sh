#!/bin/bash

cd && cd comskip/comskipCutsConverter
# find /media/vuuno4k/ -iname '*.ts' -size -3G -mmin +59 -exec ln -nsf {} \;
find /media/vuuno4k/ -iname '*.ts' -size -4G -mmin +5 -exec ln -nsf {} ./cuts/ \;
pwd
for f in ./cuts/*.ts ; do
 # test -f "$f.cuts"
 if [[ ! -f "$f.cuts" ]]; then
  php build/comskipCutsConverter.phar "$f";
  # echo "$f.cuts does not exist!";
 fi  
done

scp ./cuts/*.cuts root@192.168.0.10:/mnt/usb/ 
