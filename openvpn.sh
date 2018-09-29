	clear
	echo "--------------------------"
	echo "| DEVELOPPED BY JORDAN B.|"
	echo "--------------------------"
	echo ""
	echo  " Check Dependancy ..."
	echo  ""
	sleep 2
	opkg update
	opkg install luci-app-openvpn openvpn-openssl openvpn-easy-rsa openssh-sftp-server
	sleep 2
	echo ""
	echo " Generate SSL Certificates..."
	echo ""
	
### Step 1: Create the PKI directory tree
  PKI_DIR="/etc/openvpn/ssl"
# rm -r ${PKI_DIR}  ## ir required, remove the folder, and start again

  mkdir -pv ${PKI_DIR}
# chown -R root:root ${PKI_DIR}
  chmod -R 0600 ${PKI_DIR}

  cd ${PKI_DIR} ## popd ${PKI_DIR}
  
  touch index.txt; echo 1000 > serial
  mkdir newcerts # certs crl csr private
# chmod 0700 private
  
  
### Step 2: Start with a clean configuration, and establish the basic variables
  cp -v /etc/ssl/openssl.cnf ${PKI_DIR}
  PKI_CNF=${PKI_DIR}/openssl.cnf
  
  sed -i '/^dir/   s:=.*:= /etc/openvpn/ssl:'                      ${PKI_CNF}
  sed -i '/.*Name/ s:= match:= optional:'                    ${PKI_CNF}

  sed -i '/organizationName_default/    s:= .*:= WWW Ltd.:'  ${PKI_CNF}
  sed -i '/stateOrProvinceName_default/ s:= .*:= London:'    ${PKI_CNF}
  sed -i '/countryName_default/         s:= .*:= GB:'        ${PKI_CNF}
  
  sed -i '/default_days/   s:=.*:= 3650:'                    ${PKI_CNF} ## default usu.: -days 365 
  sed -i '/default_bits/   s:=.*:= 4096:'                    ${PKI_CNF} ## default usu.: -newkey rsa:2048
# sed -i '/default_md/     s:=.*:= default:'                 ${PKI_CNF} ## default usu.: sha256


cat >> ${PKI_CNF} <<"EOF"
###############################################################################
### Check via: openssl x509 -text -noout -in *.crt | grep 509 -A 1
[ my-server ] 
#  X509v3 Key Usage:          Digital Signature, Key Encipherment
#  X509v3 Extended Key Usage: TLS Web Server Authentication
  keyUsage = digitalSignature, keyEncipherment
  extendedKeyUsage = serverAuth

[ my-client ] 
#  X509v3 Key Usage:          Digital Signature
#  X509v3 Extended Key Usage: TLS Web Client Authentication
  keyUsage = digitalSignature
  extendedKeyUsage = clientAuth

EOF
  
  
### Step 3a: Create the CA, Server, and Client certificates (*without* using easy-rsa):
# pkitool --initca            ## equivalent to the 'build-ca' script
  openssl req -batch -nodes -new -keyout "ca.key" -out "ca.crt" -x509 -config ${PKI_CNF}  ## x509 (self-signed) for the CA

# pkitool --server my-server  ## equivalent to the 'build-key-server' script
  openssl req -batch -nodes -new -keyout "my-server.key" -out "my-server.csr" -subj "/CN=my-server" -config ${PKI_CNF}
  openssl ca  -batch -keyfile "ca.key" -cert "ca.crt" -in "my-server.csr" -out "my-server.crt" -config ${PKI_CNF} -extensions my-server
  
# pkitool          my-client  ## equivalent to the 'build-key' script
  openssl req -batch -nodes -new -keyout "my-client.key" -out "my-client.csr" -subj "/CN=my-client" -config ${PKI_CNF}
  openssl ca  -batch -keyfile "ca.key" -cert "ca.crt" -in "my-client.csr" -out "my-client.crt" -config ${PKI_CNF} -extensions my-client     

  chmod 0600 "ca.key"
  chmod 0600 "my-server.key"
  chmod 0600 "my-client.key"
 

### Step 3b: Create the Diffie-Hellman parameters (will take a long time - you may want to go get a meal!):
  openssl dhparam -out dh2048.pem 2048     ## equivalent to the 'build-dh' script


### Step 4: Keep the PKI even if performing a sysupgrade, check with: sysupgrade -l | grep rsa
# echo ${PKI_DIR}/*     > /lib/upgrade/keep.d/my-pki
  
  
### Step 5: Create the client's .ovpn file
###

  OVPN_FILE="/etc/openvpn/uk-tunnel0.ovpn"

tee /etc/openvpn/uk-tunnel0.ovpn >/dev/null <<EOF2
  client     ## implies pull, tls-client
  dev tun
# proto udp  ## udp is the default
  fast-io
  remote ${MY_PUBLIC_FQDN} 1194
  remote-cert-tls server
  nobind
  persist-key
  persist-tun
  comp-lzo no
  verb 3
EOF2

echo '<ca>'    >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < ca.crt        
echo '</ca>'   >> ${OVPN_FILE}

echo '<cert>'  >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < my-client.crt 
echo '</cert>' >> ${OVPN_FILE}

echo '<key>'   >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < my-client.key 
echo '</key>'  >> ${OVPN_FILE}


	# Distributed Certificated
	echo " Distributed Certificated"
	echo ""
	mkdir -pv /home/openvpn_cert
	cp -avr /etc/openvpn/ssl/ca.crt /etc/openvpn/ssl/my-server.* /etc/openvpn/ssl/dh2048.pem /etc/openvpn
	cp -avr /etc/openvpn/ssl/ca.crt /etc/openvpn/ssl/my-client.* /home/openvpn_cert/
	echo ""

	echo " Configure the network on the OpenWrt router"
	echo ""
# Configure the network on the OpenWrt router
uci set network.vpn0=interface
uci set network.vpn0.ifname=tun0
uci set network.vpn0.proto=none
uci set network.vpn0.auto=1

uci set firewall.Allow_OpenVPN_Inbound=rule
uci set firewall.Allow_OpenVPN_Inbound.target=ACCEPT
uci set firewall.Allow_OpenVPN_Inbound.src=*
uci set firewall.Allow_OpenVPN_Inbound.proto=udp
uci set firewall.Allow_OpenVPN_Inbound.dest_port=1194

uci set firewall.vpn=zone
uci set firewall.vpn.name=vpn
uci set firewall.vpn.network=vpn0
uci set firewall.vpn.input=ACCEPT
uci set firewall.vpn.forward=REJECT
uci set firewall.vpn.output=ACCEPT
uci set firewall.vpn.masq=1

uci set firewall.vpn_forwarding_lan_in=forwarding
uci set firewall.vpn_forwarding_lan_in.src=vpn
uci set firewall.vpn_forwarding_lan_in.dest=lan

uci set firewall.vpn_forwarding_lan_out=forwarding
uci set firewall.vpn_forwarding_lan_out.src=lan
uci set firewall.vpn_forwarding_lan_out.dest=vpn

uci set firewall.vpn_forwarding_wan=forwarding
uci set firewall.vpn_forwarding_wan.src=vpn
uci set firewall.vpn_forwarding_wan.dest=wan

uci commit network
/etc/init.d/network reload
uci commit firewall
/etc/init.d/firewall reload

	echo ""
	echo " Configure Open-VPN..."
	echo ""
	
	echo > /etc/config/openvpn # clear the openvpn uci config
	uci set openvpn.myvpn=openvpn
	uci set openvpn.myvpn.enabled=1
	uci set openvpn.myvpn.verb=3
	uci set openvpn.myvpn.port=1194
	uci set openvpn.myvpn.proto=udp
	uci set openvpn.myvpn.dev=tun
	uci set openvpn.myvpn.server='10.8.0.0 255.255.255.0'
	uci set openvpn.myvpn.keepalive='10 120'
	uci set openvpn.myvpn.ca=/etc/openvpn/ca.crt
	uci set openvpn.myvpn.cert=/etc/openvpn/my-server.crt
	uci set openvpn.myvpn.key=/etc/openvpn/my-server.key
	uci set openvpn.myvpn.dh=/etc/openvpn/dh2048.pem
	uci commit openvpn

	# Enable OpenVpn
	/etc/init.d/openvpn enable
	/etc/init.d/openvpn start
	echo ""
	echo  " Configure Clients For Your Server"
	echo  ""

cat >> client.ovpn <<"EOF"

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

EOF
