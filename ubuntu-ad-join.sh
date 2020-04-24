#!/bin/bash
#Ubuntu 18.04 Active Directory join script
#make this script executable and run as root to join an Ubuntu machine to a Windows domain
#please be sure to look over the configuration files and modify them to suit your domain

echo "The next step will install kerberos packages and needs user input. enter the domain <DOMAIN.LOCAL> IN ALL CAPS. That part is important"

read -p "Press Enter to continue"

#dependency installs
apt install -y krb5-user samba sssd chrony openssh-server cifs-utils
#user will be asked for the domain name at this time(example.tld)

echo "copying config files"

cp chrony.conf /etc/chrony/chrony.conf
cp common-session /etc/pam.d/common-session
cp krb5.conf /etc/krb5.conf
cp nsswitch.conf /etc/nsswitch.conf
cp smb.conf /etc/samba/smb.conf
cp sssd.conf /etc/sssd/sssd.conf
cp sudoers /etc/sudoers.d/sudoers

echo "modifying SSSD configuration file permissions"

chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf

echo "starting services"
systemctl restart chrony.service
systemctl restart smbd.service nmbd.service
systemctl start sssd.service

kinit administrator
klist
net ads join -k

systemctl restart sssd.service

echo "Complete."
#The end
