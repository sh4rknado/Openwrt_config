# OpenWrt-Toolkit 

The installation script has been developed for 
	- ACM3200WRT router <a href="https://www.linksys.com/be/p/P-WRT3200ACM/">LINKSYS ACM3200WRT</a>
	
## Installation of OpenVPN

This script can take a long time during the generation of SSL certificates

	chmod +x openvpn.sh 
	./openvpn.sh  

The script has been developed tested and analyzed line by line<br/> 
to ensure its smooth operation.


## configuration du client :

   Fichier de config Client : /home/openvpn_cert/ => (client.cert,client.key,..)
   Fichier de config openvpn : /home/openvpn_cert/ => (client.ovpn) 

   Explication du fichier de configuration openvpn :
	 - Modifier <path> par le repertoire (ca.cert,client.key,..)Ã
	 - Modifier SERVER_IP_ADDRESS => IP du server 
	
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
        remote SERVER_IP_ADDRESS 1194
