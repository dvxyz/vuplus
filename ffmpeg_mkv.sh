#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:05:00
MV="mv"
RM="rm"
RECDIR=/mnt/usb
RECFILE=${1:-*.ts}
MKVDIR=/mnt/passport/vuuno4k

function test() {
	TSFILE="$1";
	echo "Files: $TSFILE";
}

function ffmpeg_mkv() {
 TSFILE="$1";
 TSDIR=$(dirname "$TSFILE")
 ARCHIVED="$TSDIR/ts"
 SCRAMBLE="$TSDIR/scrambled"
 METADATA=$(basename "$TSFILE" .ts);
 MKVFILE=$(basename "$TSFILE" .ts).mkv

 $FFMPEG -ss $OFFSET -y -i "$TSFILE" -map 0:v -map 0:a -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
 if [[ $? -eq 0 ]] ; then
  mkdir -p "$ARCHIVED"
  $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$ARCHIVED/"
 else
  echo "$TSFILE : RC $?" ;
  mkdir -p "$SCRAMBLE"
  $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$SCRAMBLE/";
  # $RM "$MKVDIR/$MKVFILE";
 fi ;	
}

if [[ -d "$RECFILE" ]] ; then
	for TSFILE in "$RECFILE/"*.ts ; do
		ffmpeg_mkv "$TSFILE";
	done
elif [[ -f "$RECFILE" ]] ; then
	ffmpeg_mkv "$RECFILE";
elif [[ -f "$RECDIR/$RECFILE" ]] ; then
	ffmpeg_mkv "$RECDIR/$RECFILE";
fi