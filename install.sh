#!/bin/ash

EXIT=0
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
	echo "---------------------------"
	echo "| DEVELOPPED BY JORDAN B. |"
	echo "---------------------------"
	echo
}

function menu {
	while [ ${EXIT} -eq 0 ]
		do
			top
			echo "Select your choose"
			echo ""
			echo "1) Install OpenVPN"
			echo "2) Install owncloud (TODO)"
			echo "3) TODO"
 			echo "4) Install Extras-Packages"
			echo "5) EXIT"
			echo
			read CHOOSE

			case $CHOOSE in
				1) install_openvpn;;
				2) ;;
				3) ;;
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



function main {
	menu
}
main
