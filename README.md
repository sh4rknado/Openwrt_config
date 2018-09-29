# OpenWrt-Toolkit 

The installation script has been developed for <br/> 
	-> ACM3200WRT router <a href="https://www.linksys.com/be/p/P-WRT3200ACM/">LINKSYS ACM3200WRT</a><br/>
	
## Installation of OpenVPN

This script can take a long time during the generation of SSL certificates

	chmod +x openvpn.sh 
	./openvpn.sh  

The script has been developed tested and analyzed line by line.


## configuration of client :
   => CHECK into router<br/><br/>
   File config of Client : /home/openvpn_cert/ => ( client.cert, client.key, ... )<br/>
   File config of openvpn : /home/openvpn_cert/ => ( client.ovpn )

   Explains file config client of openvpn :<br/>
	-> TODO Modify <path> by your path ( ca.cert, client.key, ...)<br/>
	-> TODO Modify SERVER_IP_ADDRESS => PUBLIC IP 
	
        # Configure Clients For Your Server
        dev tun
        proto udp

        log openvpn.log
        verb 3

        ca   <path>/ca.crt
        cert <path>/my-client.crt
        key  <path>/my-client.key

        client
        remote-cert-tls server
        remote PUBLIC_IP_ADDRESS 1194

## Troubleshooting
If something doesn't work as expected while following this HOWTO:

Check that the client can ping the server: ping SERVER_IP_ADDRESS<br/>

Check that the OpenVPN daemon is running: ps | grep "openvpn"<br/>

Check that there is a TUN interface: ifconfig | grep "tun"<br/>

Check the log: cat /tmp/openvpn.log<br/>

You can try temporarily disabling the firewall on the OpenVPN server:<br/>
/etc/init.d/firewall stop<br/>

You can clear the OpenVPN configuration and start again from scratch: echo > /etc/config/openvpn<br/>

## Asking for help

You can ask for help on the OpenWrt forum: https://forum.openwrt.org/. or open an issue <br/>
When asking for help, you should at a minimum include the contents of the following files:<br/>

cat /tmp/openvpn.log <br/>
cat /etc/config/network<br/>
cat /etc/config/firewall<br/>
cat /etc/config/openvpn<br/>
