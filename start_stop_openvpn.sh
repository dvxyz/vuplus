#!/bin/bash

declare -a ACTIONS=(stop start)

ifconfig tun0 > /dev/null 2>&1

ACTION="${ACTIONS[$?]}"

case "$ACTION" in
	start)
		openvpn --config /home/root/raspberrypi_client_vuplus.ovpn --daemon --log /var/log/openvpn.log
		# sleep 5
		timeout -t 5 tail -f /var/log/openvpn.log
		ifconfig tun0
		./mount.sh mount hts
		;;
	stop)
		./mount.sh umount hts
		killall openvpn > /dev/null 2>&1
		./update_oscam.sh restart
		;;
	*)
		echo "Start/Stop OpenVPN"
		;;
esac

exit
