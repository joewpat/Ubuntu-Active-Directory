#!/bin/bash


#Ubuntu 18 quick config script by joe


#this is for <helpdesk tech> so he don't forget

echo "Getting ready..."

echo "The next step will install kerberos packages and needs user input. enter the domain OPTIMUMHIT.LOCAL IN ALL CAPS. That part is important"

read -p "Press Enter to continue"


#dependency installs

apt install -y krb5-user samba sssd chrony openssh-server cifs-utils


#user will be asked for the domain name at this time(example.tld)



#mount the file share. mine are stored on a windows 2016 file server so I mount it with CIFS:


sudo mount -t cifs '<path to share with configs>' /mnt -o user=administrator@example.tld

#password for admin here



#copy config files. 


echo "copying NTP config files"

cp /mnt/chrony.conf /etc/chrony/chrony.conf

echo 'copying PAM config files'
cp /mnt/common-session /etc/pam.d/common-session

echo "copying Kerberos config files"
cp /mnt/krb5.conf /etc/krb5.conf
echo "copying NSSwitch.conf"
cp /mnt/nsswitch.conf /etc/nsswitch.conf
echo "copying Samba config files"
cp /mnt/smb.conf /etc/samba/smb.conf
echo "copying SSSD config files"
cp /mnt/sssd.conf /etc/sssd/sssd.conf
echo "configuring Sudo access"
cp /mnt/sudoers /etc/sudoers.d/sudoers

echo "file copy complete :)"


echo "modifying SSSD configuration file permissions"

chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf

echo 'complete!'


echo "starting services"
systemctl restart chrony.service

systemctl restart smbd.service nmbd.service

systemctl start sssd.service


echo "joining domain, hold my beer!"

kinit administrator

klist


echo "cool, looks like im in. here goes nothing"


net ads join -k


systemctl restart sssd.service

echo "Done!"
