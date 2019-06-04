#!/bin/bash

GENERALI=194.147.195.250
DE=95.90.205.224
UK=91.110.23.243

if [ "$1" = "clear" ] ; then
 iptables -t filter -P OUTPUT ACCEPT
 iptables -t filter -P INPUT ACCEPT
 iptables -t filter -P FORWARD ACCEPT
 iptables -F

 echo "Cleared all rules."
 exit;
fi

# input exceptions.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -s ch.velezschrod.xyz -j ACCEPT
iptables -A INPUT -s es.velezschrod.xyz -j ACCEPT
iptables -A INPUT -s $UK -j ACCEPT
iptables -A INPUT -s $DE -j ACCEPT
iptables -A INPUT -s $GENERALI -j ACCEPT

# for ip in $(egrep nameserver /etc/resolv.conf | cut -d ' ' -f 2) ; do
# iptables -A INPUT -p udp -s $ip --sport 53 -m state --state ESTABLISHED -j ACCEPT
# done

# default policies
iptables -t filter -P OUTPUT ACCEPT
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP

