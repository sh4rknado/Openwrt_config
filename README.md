# OpenWrt-Toolkit 

Le script d'installation a été développé pour un router ACM3200WRT
	- <a href="https://www.linksys.com/be/p/P-WRT3200ACM/">LINKSYS ACM3200WRT</a>
	
## Installation de OPENVPN

Ce script peut prendre un peux de temps lors de la générations des certificats SSL

   chmod +x openvpn.sh
   ./openvpn.sh  

Le script a été développé et testé et analysé line par line afin de vous assurer 
de son bon fonctionnement.


## configuration du client :

   Fichier de config Client : /home/openvpn_cert/ => (client.cert,client.key,..)
   Fichier de config openvpn : /home/openvpn_cert/ => (client.ovpn) 

   Explication du fichier de configuration openvpn :
	 - Modifier <path> par le repertoire (ca.cert,client.key,..)�
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
