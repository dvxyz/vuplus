#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:05:00
MV="mv"
RM="rm"
RECDIR=$1
DUPE=$RECDIR/_dupe_
RECFILE="${RECDIR}/${2}"
MKVDIR=/mnt/passport/vuuno4k
LOGFILE=/tmp/ffmpeg_mkv.log

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
  mkdir -p $DUPE ;
  echo "$(date) [dupe] ${MV} ${TSDIR}/${METADATA}*.{eit,ap,cuts,meta,sc,ts} ${DUPE}" | tee -a $LOGFILE;
  $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$DUPE/" ;
 else
  echo "$(date) [ffmp] ${FFMPEG} -ss ${OFFSET} -y -i ${TSFILE} -map 0:v -map 0:a -c:v ${VCODEC} -c:a ${ACODEC} -sn ${MKVDIR}/${MKVFILE}" | tee -a $LOGFILE ;
  $FFMPEG -ss $OFFSET -y -i "$TSFILE" -map 0:v -map 0:a -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
  if [[ $? -eq 0 ]] ; then
   mkdir -p "$ARCHIVED" ;
   echo "$(date) ${MV} ${TSDIR}/${METADATA}*.{eit,ap,cuts,meta,sc,ts} ${ARCHIVED}/" | tee -a $LOGFILE ;
   $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$ARCHIVED/" ;
   for f in ts/"$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do ln -nsf "$f" "${f:19}" ; done
  else
   echo "$TSFILE : RC $?" ;
   mkdir -p "$SCRAMBLE" ;
   echo "$(date) [scrm] ${MV} ${TSDIR}/${METADATA}*.{eit,ap,cuts,meta,sc,ts} ${SCRAMBLE}/" | tee -a $LOGFILE
   $MV "$TSDIR/$METADATA"*.{eit,ap,cuts,meta,sc,ts} "$SCRAMBLE/" ;
   $RM "$MKVDIR/$MKVFILE" ;
  fi ;
 fi ;
}

cd $RECDIR

echo "$(date) $0 $@" | tee -a $LOGFILE
echo "$(date) RECDIR: [${RECDIR}]" | tee -a $LOGFILE
echo "$(date) RECFILE: [${RECFILE}]" | tee -a $LOGFILE

if [[ -d "$RECFILE" ]] ; then
 for TSFILE in "$RECFILE"*.ts ; do
  if [[ -f "$TSFILE" ]] ; then
   echo "$(date) ffmpeg_mkv ${TSFILE};" | tee -a $LOGFILE ;
   ffmpeg_mkv "$TSFILE" ;
  fi ;
 done ;
elif [[ -f "$RECFILE" ]] ; then
 echo "$(date) ffmpeg_mkv ${RECFILE} ;" | tee -a $LOGFILE ;
 ffmpeg_mkv "$RECFILE" ;
else
 echo "$(date) else ..." | tee -a $LOGFILE ;
fi

cd -
