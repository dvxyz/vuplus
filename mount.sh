#!/bin/bash

ACTION="$1"
DRIVE="$2"
DEFAULT="Mount/Umount <hts|passport>"

if [[ "$ACTION" == "mount" || "$ACTION" == "umount" ]] ; then
	case "$DRIVE" in
		hts)
			if mount | egrep /home/hts > /dev/null ; then
				umount /mnt/hts > /dev/null 2>&1 ;
			else
				mount.nfs4 -o port=3049 es.velezschrod.xyz:/home/hts /mnt/hts > /dev/null 2>&1 ;
			fi ;;
		passport)
			$ACTION /mnt/passport > /dev/null 2>&1 & ;;
		*) 
			echo $DEFAULT ;;
	esac
else
	echo $DEFAULT ;
fi

# case "$ACTION" in
# 	mount) 
# 		if [[ "$DRIVE" == "passport" ]] ; then
# 			mount 192.168.0.200:/Volumes/My\ Passport\ Studio /mnt/passport
# 		elif [[ "$DRIVE" == "hts" ]] ; then
# 			mount /mnt/hts
# 		fi
# 	;;
# 	umount)
# 		if [[ "$DRIVE" == "passport" ]] ; then
# 			umount /mnt/passport
# 		elif [[ "$DRIVE" == "hts" ]] ; then
# 			umount /mnt/hts
# 		fi
# 	;;
# 	*)	echo "Mount/Umount <hts|passport>"
# esac
