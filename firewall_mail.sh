#!/bin/bash

if [ -z "$1" ]
  then
	echo "Missing Argument! Ex: iptables.sh ###.###.###.###/##"
	exit 1
fi

clear
echo "Are you sure \"$1\" is correct? (Y/n)"
read choice

case $choice in
Y)
	echo "Starting"
;;
n)
	echo "Exiting"
	exit 0
;;
*)
	echo "Character entered not valid"
	exit 1
;;
esac

echo "Clearing firewall rules..."

iptables -F
ip6tables -F
iptables -X
ip6tables -X

echo "Adding firewall rules..."

ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -s $1 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s $1 --dport smtp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s $1 --dport imap -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s $1 --dport pop3 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -d $1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -s $1 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p tcp -d $1 --sport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d $1 --sport smtp -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d $1 --sport imap -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d $1 --sport pop3 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d us.archive.ubuntu.com --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d archive.ubuntu.com --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -d $1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -s $1 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

echo "Adding rules complete. Saving rules to startup..."

iptables-save > ~/rules.fw
mv -v ~/rules.fw /root/rules.fw

if grep -Fxq "/sbin/iptables-restore < /root/rules.fw" /etc/rc.local
then
  echo "rc.local String exists. Ignoring..."
else
  sed -i '/exit 0/d' /etc/rc.local
  echo "Adding iptables script to rc.local"
  echo "/sbin/iptables-restore < /root/rules.fw" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local
fi

echo "Saving complete."
echo "Press enter to continue..."
read

vim -c "echo 'Add \"post-up iptables-restore\" underneath eth0'" /etc/network/interfaces

clear
echo "Complete"
echo "Press enter to continue"
read
