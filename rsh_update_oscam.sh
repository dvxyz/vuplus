#!/bin/bash

echo $(whoami) > /tmp/whoami.$$.log

while read mail; do

 read -r -a array <<< $(echo $mail | egrep -i -m1 "C: " | rev)

 oscam_srvr="${array[3]}"
 oscam_port="${array[2]}"
 oscam_user="${array[1]}"
 oscam_pass="${array[0]}"
 
 if [[ "$oscam_srvr" != "" ]] ; then
  oscam_srvr=$(rev <<< $oscam_srvr)
  oscam_port=$(rev <<< $oscam_port)
  oscam_user=$(rev <<< $oscam_user)
  oscam_pass=$(rev <<< $oscam_pass)

  echo "$oscam_srvr $oscam_port $oscam_user $oscam_pass" >> /tmp/rsh_update_oscam.log
  rsh -i /home/nobody/.ssh/id_rsa root@192.168.0.10 /home/root/update_oscam.sh $oscam_srvr $oscam_port $oscam_user $oscam_pass
 fi

done
