#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:00:00
MV="mv"
RM="rm"
RECDIR="/mnt/usb/${1:-*}"
SCRAMBLE=$(dirname "$RECDIR")/scrambled

mkdir -p "$SCRAMBLE"

for f in "$RECDIR" ; do
 MKVDIR=$(dirname "$f") ;
 MKVFILE=$(basename "$f" .ts).mkv ;
 $FFMPEG -ss $OFFSET -y -i "$f" -map 0:v -map 0:a -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
 if [[ $? -eq 0 ]] ; then 
  $RM "$f"; 
 else
  echo "$f : RC $?" ;
  $MV "$f" "$SCRAMBLE/" ; 
  $RM "$MKVDIR/$MKVFILE" ; 
 fi ;
done

