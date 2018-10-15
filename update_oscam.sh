#!/bin/bash

function restart_oscam()
{
 killall oscam-unstable
 /usr/bin/oscam-unstable -b -r 1 -c /etc/tuxbox/config
}

function update_oscam()
{	
 oscam_file=$1
 oscam_srvr=$2
 oscam_port=$3
 oscam_user=$4
 oscam_pass=$5

 sed -i "s/\(label *= *\).*/\1$oscam_srvr/" $oscam_file;
 sed -i "s/\(device *= *\).*/\1$oscam_srvr,$oscam_port/" $oscam_file;
 sed -i "s/\(user *= *\).*/\1$oscam_user/" $oscam_file;
 sed -i "s/\(password *= *\).*/\1$oscam_pass/" $oscam_file;
}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$(basename $0)] $@" >> /tmp/update_oscam.log

if [[ "$1" == "restart" ]] ; then
 restart_oscam
else 
 if [[ $# -eq 4 ]]; then
  oscam_file="/etc/tuxbox/config/oscam.01_spdns_eu.server"
  update_oscam "$oscam_file" "$1" "$2" "$3" "$4"
 fi

 oscam_file="/etc/tuxbox/config/oscam.02_boss_cccam.server"
 
 # IFS=', ' read -r -a array <<< $(wget http://boss-cccam.com/Test.php -O - | egrep -m 1 "strong" | sed -E 's/         <p class="text-center">Your Free Test line : <strong>c: //' | sed -E 's/<\/strong><\/p>//')
 # read -r -a array <<< $(wget https://www.velezschrod.xyz/Test.php -O - | egrep -i -m1 "C: " | sed -E 's/         <p class="text-center">Your Free Test line : <strong>c: //' | sed -E 's/<\/strong><\/p>//')
 read -r -a array <<< $(wget http://boss-cccam.com/Test.php -O - | egrep -i -m1 "C: " | sed -E 's/         <p class="text-center">Your Free Test line : <strong>c: //' | sed -E 's/<\/strong><\/p>//')
 
 oscam_srvr="${array[0]}"
 oscam_port="${array[1]}"
 oscam_user="${array[2]}"
 oscam_pass="${array[3]}"

 update_oscam "$oscam_file" "$oscam_srvr" "$oscam_port" "$oscam_user" "$oscam_pass"

 cat /etc/tuxbox/config/oscam.*.server > /etc/tuxbox/config/oscam.server
 restart_oscam

fi 
