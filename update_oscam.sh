#!/bin/bash

function test()
{
 echo $@
}

function restart_oscam()
{
 killall oscam-unstable
 rm -rf /tmp/*.info* /tmp/*.tmp* /tmp/.oscam/reader*
 /usr/bin/oscam-unstable -b -r 1 -c /etc/tuxbox/config
}

function reload_readers()
{
 wget http://192.168.0.10:83/readers.html?action=reloadreaders -O /tmp/reload_readers.html
}

function update_oscam()
{
 oscam_srvr=$1
 oscam_port=$2
 oscam_user=$3
 oscam_pass=$4

 echo $@ | tee -a /tmp/update_oscam.log
 echo Server: $oscam_srvr | tee -a /tmp/update_oscam.log
 echo Port:   $oscam_port | tee -a /tmp/update_oscam.log
 echo User:   $oscam_user | tee -a /tmp/update_oscam.log
 echo Pass:   $oscam_pass | tee -a /tmp/update_oscam.log

 oscam_file="/etc/tuxbox/config/oscam.$(echo $oscam_srvr | tr '.-' '_').server"

 if [[ ! -f "$oscam_file" ]] ; then
  cp /etc/tuxbox/config/template.oscam.server "$oscam_file"
 fi

 sed -i "s/\(label *= *\).*/\1$oscam_srvr/" $oscam_file
 sed -i "s/\(device *= *\).*/\1$oscam_srvr,$oscam_port/" $oscam_file
 sed -i "s/\(user *= *\).*/\1$oscam_user/" $oscam_file
 sed -i "s/\(password *= *\).*/\1$oscam_pass/" $oscam_file
 sed -i "s/\(enable *= *\).*/\11/" $oscam_file
}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$(basename $0)] $@" >> /tmp/update_oscam.log

sed -i "s/\(enable *= *\).*/\10/" /etc/tuxbox/config/oscam.*.server

if [[ "$1" == "restart" ]] ; then
 # restart_oscam
 reload_readers
 exit
elif [[ $# -eq 4 ]]; then
  update_oscam "$1" "$2" "$3" "$4"
else
 urls=( 'https://cccam.ch/free/get.php', 'http://boss-cccam.com/Test.php' )

 if [[ $# -gt 0 ]]; then
  urls=( "$1" )
 fi

 for url in "${urls[@]}" ; do 
  read -r -a array <<< $(wget $url -O - | egrep -i -m1 "C: " | sed -E 's/<\/h1>//' | sed -E 's/<h1>C: //' | sed -E 's/         <p class="text-center">Your Free Test line : <strong>c: //' | sed -E 's/<\/strong><\/p>//')

  oscam_srvr="${array[0]}"
  oscam_port="${array[1]}"
  oscam_user="${array[2]}"
  oscam_pass="${array[3]}"

  if [[ "$oscam_srvr" != "" ]] ; then
   update_oscam "$oscam_srvr" "$oscam_port" "$oscam_user" "$oscam_pass"
  fi
 done ;
fi

cat /etc/tuxbox/config/oscam.*.server > /home/vuuno/tuxbox/config/oscam.server
# restart_oscam
reload_readers


