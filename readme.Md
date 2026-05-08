dns

ip addr flush dev eth0
ip addr add 10.1.0.10/24 dev eth0
ip link set eth0 up
ip route add default via 10.1.0.1

# Verificar

ip addr show eth0
ping 10.1.0.1 -c 3

web server
ip addr flush dev eth0
ip addr add 10.1.0.11/24 dev eth0
ip link set eth0 up
ip route add default via 10.1.0.1

# Verificar

ip addr show eth0
ping 10.1.0.1 -c 3

client
ip addr flush dev eth0
ip addr add 10.2.0.10/24 dev eth0
ip link set eth0 up
ip route add default via 10.2.0.1

# Verificar

ip addr show eth0
ping 10.2.0.1 -c 3

## containers

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
a77b0f4ddf2b dns-server-local:latest "/gns3/init.sh docke…" 7 minutes ago Up 6 minutes GNS3.dns-server-local-1.923ba052-824d-4d28-bf4c-643fac4da401
f4f52aff26b3 cliente-victor:latest "/gns3/init.sh tail …" 31 minutes ago Up 25 minutes GNS3.cliente-victor-1.923ba052-824d-4d28-bf4c-643fac4da401
4a9e539e67c9 web-server-local:latest "/gns3/init.sh /dock…" 32 minutes ago Up 25 minutes GNS3.web-server-local-1.923ba052-824d-4d28-bf4c-643fac4da401

# ajustar paginas de nginx

# Desde tu PC host

docker cp ~/Downloads/proyecto/nginx/sites/dominio.local.conf 4a9e539e67c9:/etc/nginx/conf.d/
docker cp ~/Downloads/proyecto/nginx/sites/dominio.com.conf 4a9e539e67c9:/etc/nginx/conf.d/
docker cp ~/Downloads/proyecto/nginx/html/local 4a9e539e67c9:/var/www/
docker cp ~/Downloads/proyecto/nginx/html/com 4a9e539e67c9:/var/www/

# Recargar nginx

docker exec 4a9e539e67c9 sh -c "nginx -t && nginx -s reload"
