#!/bin/ash

EXIT=0
ASCI_IMG="config/asci_img"
OWN_PATH=$(pwd)
OVPN_PATH="install/openvpn_install.sh"

function updating {
	echo "PACKAGE UPDATING ....."
	echo ""
	sleep 1
	opkg update
}

function top {
	clear
	cat $ASCI_IMG
}

function menu {
	while [ ${EXIT} -eq 0 ]
		do
			top
			echo "Select your choose"
			echo ""
			echo "1) Install OpenVPN"
			echo "2) Install owncloud (TODO)"
			echo "3) EXTROOT (Advanced Usage !)"
 			echo "4) Install Extras-Packages"
			echo "5) EXIT"
			echo
			read CHOOSE

			case $CHOOSE in
				1) install_openvpn;;
				2) ;;
				3) extroot;;
				4) install_extras_packages;;
				5) EXIT=1;;
			esac
	done
}

function install_openvpn {
	top
	updating
	echo
	echo  " Check Dependancy ..."
	echo  ""
	sleep 1
	opkg install luci-app-openvpn openvpn-openssl openvpn-easy-rsa openssh-sftp-server

	echo "LAUNCH CONFIGURATION FILE ...."
	echo ""
	./${OVPN_PATH}

	echo "The Client File Config is in /home/openvpn_cert"
	echo "You can Shared it with scp => FTP by SSH"
	echo "You can use sshfs for mount /home/openvpn_cert"
}

function install_extras_packages {
	top
	updating
	opkg install ca-certificates ca-bundle git-http
}

function extroot() {
	top
	updating
	
	clear
	top

	echo ""
        echo "Installing Dependancy Package ..."
	echo ""
	opkg install block-mount kmod-fs-ext4 kmod-usb-storage-extras kmod-usb-core

	select_drive
	
	DRIVE="/dev/$DRIVE"

	# Mount the drive and copy existing File
	mount $DRIVE /mnt ; 
	tar -C /overlay -cvf - . | tar -C /mnt -xf - ; 
	umount /mnt

	generate_fstab

	echo ""
	echo "CHECK THE fstab /etc/config/fstab !!!"
	echo "You can compare with :"
	echo ""
	echo "=> https://wiki.openwrt.org/doc/howto/extroot"
	echo "=> https://github.com/djbertix/Openwrt_config"
	echo "EDIT : => vi /etc/config/fstab"
	echo "CHECK : => cat /etc/config/fstab"
	echo ""
	echo "You can try to mount with "
	echo "MOUNT => mount /dev/sda1 /overlay"
	echo "CHECK => df -h or mount"
	echo "IF you are not warning or error you can reboot Safely !"
	echo ""
}

function generate_fstab {

   block detect > /etc/config/fstab; \
   sed -i s/option$'\t'enabled$'\t'\'0\'/option$'\t'enabled$'\t'\'1\'/ /etc/config/fstab; \
   sed -i s#/mnt/sda1#/overlay# /etc/config/fstab; \
   cat /etc/config/fstab;
}

function select_drive {
	
	clear 
	top
	echo ""	
	echo "Select USB Drive for mount ROOT PARTITION"
	echo "(EX: /dev/sda1)"
	echo ""
	echo ""
	
	########### < Listing Drive > ########### 
        ls -la /dev/ | egrep "sd" | awk '{print $10}' | egrep [0-9] > drives 
	CPT=0

	while read line 
	do 
	   echo -e "$CPT) $line"
	   let "CPT=CPT+1"

	done < drives

	echo ""
	read DRIVE

	######### < Get Drive from CPT > #########
	CPT=0
	while read line
        do
           if [ $DRIVE == $CPT ]; then
	   	DRIVE=$line
	   fi
	let "CPT=CPT+1"
        done < drives
	rm drives
}

function main {
	top
	menu
}
main
