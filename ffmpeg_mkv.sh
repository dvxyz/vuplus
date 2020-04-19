#!/bin/bash

FFMPEG="ffmpeg"
ACODEC=copy
VCODEC=copy
OFFSET=00:05:00
MV="mv"
RM="rm"
RECDIR=${1:-/mnt/usb}
RECFILE=${2:-""}
MKVDIR=/mnt/passport/vuuno4k
LOGFILE=/tmp/ffmpeg_mkv.log

function ffmpeg_mkv() {
 TSFILE="$1"
 TSDIR=$(dirname "$TSFILE")
 METADATA=$(basename "$TSFILE" .ts)
 SIMPLE_TS="$METADATA"
 SIMPLE_TS="${SIMPLE_TS:16}"
 MKVFILE="${SIMPLE_TS}".mkv

 # return;

 for f in "$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do 
  channel=$(echo $f | cut -d'-' -f2 | sort -u | tr -d ' ') ;
  mkdir -p /media/usb/channels/$channel ;
  # echo "$f => $channel" ;
  ln -nsf "$RECDIR/$f" $RECDIR/channels/$channel/ ;
 done

 if [[ ! -f "${ARCHIVED}/${SIMPLE_TS}.ts" ]] ; then
  if [[ ! -f "$MKVDIR/$MKVFILE" ]] ; then
   echo "$(date) find ${SCRAMBLE} -type l -name ${METADATA}.*' -exec rm {} ;" | tee -a $LOGFILE ;
   find "$SCRAMBLE" -type l -name "$METADATA"'.*' -exec rm {} \;
   echo "$(date) [ffmp] ${FFMPEG} -ss ${OFFSET} -y -i ${TSFILE} -map 0:v -map 0:a -c:v ${VCODEC} -c:a ${ACODEC} -sn ${MKVDIR}/${MKVFILE}" | tee -a $LOGFILE ;
   $FFMPEG -ss $OFFSET -y -i "$TSFILE" -map 0:v -map 0:a:0 -c:v $VCODEC -c:a $ACODEC -sn "$MKVDIR/$MKVFILE" ;
   if [[ ! $? -eq 0 ]] ; then 
    $RM "$MKVDIR/$MKVFILE" ; 
    echo "$(date) ln -nsf $METADATA*.{eit,ap,cuts,meta,sc,ts} ${SCRAMBLE}/" | tee -a $LOGFILE ;
    for f in "$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do ln -nsf "../${f}" "${SCRAMBLE}/" ; done
   fi ;
  fi ;
  echo "$(date) ln -nsf ${METADATA}*.{eit,ap,cuts,meta,sc,ts} ${ARCHIVED}/" | tee -a $LOGFILE ;
  for f in "$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do ln -nsf "../${f}" "${ARCHIVED}/${f:16}" ; done
 else
   READLINK_A=$(readlink -f "${TSFILE}")
   READLINK_B=$(readlink -f "${ARCHIVED}/${SIMPLE_TS}.ts")
   echo "$(date) readlink: $READLINK_A => ${TSFILE}" | tee -a $LOGFILE;
   echo "$(date) readlink: $READLINK_B => ${ARCHIVED}/${SIMPLE_TS}.ts" | tee -a $LOGFILE;
  if [[ "${READLINK_A}" == "${READLINK_B}" ]] ; then
   echo "$(date) readlink: Skipping..." ;
  else
   echo "$(date) ln -nsf $METADATA*.{eit,ap,cuts,meta,sc,ts} ${DUPE}/" | tee -a $LOGFILE;
   for f in "$METADATA"*.{eit,ap,cuts,meta,sc,ts} ; do ln -nsf "../${f}" "${DUPE}/" ; done
  fi ;
 fi ;
}


if [[ $# -eq 0 ]] ; then
 echo "$(date) Usage $0 directory [filename]"
 exit ;
fi ;

if [[ "$RECFILE" == "" ]] ; then
  RECFILE=$RECDIR ;
else
  RECFILE=$RECDIR/$RECFILE;
fi ;

if [[ ! -d "$RECDIR" ]] ; then
  RECDIR=$(dirname "$RECDIR") ;
fi ;

ARCHIVED="$RECDIR/ts"
DUPE="$RECDIR/_dupe_"
SCRAMBLE="$RECDIR/scrambled"

echo "$(date) $0 $@" | tee -a $LOGFILE
echo "$(date) RECDIR: [${RECDIR}]" | tee -a $LOGFILE
echo "$(date) RECFILE: [${RECFILE}]" | tee -a $LOGFILE

pwd
cd $RECDIR

if [[ -d "$RECFILE" ]] ; then
 for TSFILE in "$RECFILE/"*.ts ; do
  if [[ -f "$TSFILE" ]] ; then
   echo "$(date) ffmpeg_mkv (d) ${TSFILE};" | tee -a $LOGFILE ;
   ffmpeg_mkv "$TSFILE" ;
  fi ;
 done ;
elif [[ -f "$RECFILE" ]] ; then
 echo "$(date) ffmpeg_mkv (f) ${RECFILE} ;" | tee -a $LOGFILE ;
 ffmpeg_mkv "$RECFILE" ;
else
 echo "$(date) else ..." | tee -a $LOGFILE ;
fi

echo "$(date) find -L $ARCHIVED $DUPE $SCRAMBLE -type l -exec rm {};" | tee -a $LOGFILE ;
find -L "$ARCHIVED" "$DUPE" "$SCRAMBLE" -type l -exec rm {} \;

cd -
