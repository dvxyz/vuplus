#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:05:00
MV="mv"
RM="rm"
RECDIR=$(dirname "${1:-/mnt/usb/.}")
RECFILE=$(basename "${1:-*.*}" .ts)
ARCHIVED="$RECDIR/ts"
SCRAMBLE="$RECDIR/scrambled"
MKVDIR=/mnt/passport/vuuno4k

echo "$RECDIR"
echo "$ARCHIVED"
echo "$SCRAMBLE"

mkdir -p "$ARCHIVED"
mkdir -p "$SCRAMBLE"

for f in "$RECDIR/$RECFILE" ; do
 METADATA=$(basename "$f" .ts);
 MKVFILE="$METADATA.mkv";
 $FFMPEG -ss $OFFSET -y -i "$f" -map 0:v -map 0:a -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
 if [[ $? -eq 0 ]] ; then 
  $MV "$RECDIR/./$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$ARCHIVED/"
 else
  echo "$f : RC $?" ;
  $MV "$RECDIR/./$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$SCRAMBLE/";
  $RM "$MKVDIR/$MKVFILE";
 fi ;
done

