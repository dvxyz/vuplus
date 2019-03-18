#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:05:00
MV="mv"
RM="rm"
RECDIR=/mnt/usb
DUPE=$RECDIR/_dupe_
RECFILE=${1:-*.ts}
RECFILE="${RECDIR}/${1}"
MKVDIR=/mnt/passport/vuuno4k

function test() {
	TSFILE="$1";
	echo "Files: $TSFILE";
}

function ffmpeg_mkv() {
 TSFILE="$1"
 TSDIR=$(dirname "$TSFILE")
 ARCHIVED="$TSDIR/ts"
 SCRAMBLE="$TSDIR/scrambled"
 METADATA=$(basename "$TSFILE" .ts)
 MKVFILE=$(basename "$TSFILE" .ts)
 MKVFILE="${MKVFILE:16}".mp4

 if [[ -f "$MKVDIR/$MKVFILE" ]] ; then
  mkdir -p $DUPE
  $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$DUPE/"
 else
  $FFMPEG -ss $OFFSET -y -i "$TSFILE" -map 0:v -map 0:a -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
  if [[ $? -eq 0 ]] ; then
   mkdir -p "$ARCHIVED" ;
   $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$ARCHIVED/"
   for f in ts/"$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do ln -nsf "$f" "${f:19}" ; done
  else
   echo "$TSFILE : RC $?" ;
   mkdir -p "$SCRAMBLE"
   $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$SCRAMBLE/";
   $RM "$MKVDIR/$MKVFILE";
  fi ;
 fi ;
}

if [[ -d "$RECFILE" ]] ; then
 exit ;
 for TSFILE in "$RECFILE"/*.ts ; do
  echo ffmpeg_mkv "$TSFILE" ;
 done ;
elif [[ -f "$RECFILE" ]] ; then
 ffmpeg_mkv "$RECFILE" ;
else
 echo "else" ;
fi

