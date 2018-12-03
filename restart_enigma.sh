#!/bin/bash

telinit 4
if [[ "$1" == "timer" ]] ; then
 echo "clearing timers..."
 sleep 5
 rm -f /etc/enigma2/timers.xml
fi
telinit 3
