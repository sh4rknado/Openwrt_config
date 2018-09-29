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

        ca   <p style="color:red;"><path></p>/ca.crt
        cert <p style="color:red;"><path></p>/my-client.crt
        key  <p style="color:red;"><path></p>/my-client.key

        client
        remote-cert-tls server
        remote <p style="color:red;">PUBLIC_IP_ADDRESS</p> 1194
