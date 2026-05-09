# dns server local 1
service named start
service named status
# si falla
named -g 2>&1 | head -30
ip addr flush dev eth0
ip addr add 10.1.0.10/24 dev eth0
ip link set eth0 up
ip route add default via 10.1.0.1
ip route add 10.2.0.0/24 via 10.1.0.1
ip route get 10.2.0.10
# Verificar
ip addr show eth0
apt-get update -qq && apt-get install -y iputils-ping curl dnsutils
ping -c 3 10.1.0.1  
# Dentro del contenedor dns-server
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# Ahora sí actualizar e instalar
apt-get update && apt-get install -y iputils-ping curl dnsutils iproute2
# Probar
ping -c 3 10.1.0.1
# Paso 2
docker exec -it b33287dea4c2 sh
service named status
named-checkconf /etc/bind/named.conf
named-checkzone dominio.local /etc/bind/zones/db.dominio.local
named-checkzone dominio.com /etc/bind/zones/db.dominio.com.internal

# probar 3
NEW_ID=$(docker ps | grep dns-server-local | awk '{print $1}')
docker exec $NEW_ID bash -c "ss -ulnp | grep 53 | grep -v 127 | head -5"

docker exec 4bd5d09c88ca rndc querylog on

# probar 4 dns local LAN 1
# 2. Desde dns-server (LAN1) - ambos dominios deben resolver
DNS_ID=$(docker ps | grep dns-server | awk '{print $1}')
docker exec $DNS_ID bash -c "dig @127.0.0.1 dominio.local +short"
docker exec $DNS_ID bash -c "dig @127.0.0.1 dominio.com +short"

# web server local 1
ip addr flush dev eth0
ip addr add 10.1.0.11/24 dev eth0
ip link set eth0 up
ip route add default via 10.1.0.1
# Verificar
ip addr show eth0
ping 10.1.0.1 -c 3
# Dentro del contenedor web
wget -qO- http://10.1.0.11/
# Debe mostrar el HTML de dominio.com o dominio.local

# cliente 
ip addr flush dev eth0
ip addr add 10.2.0.10/24 dev eth0
ip link set eth0 up
ip route add default via 10.2.0.1
# Verificar
ip addr show eth0
ping -c 3 10.2.0.1

# 3. Desde web-server (LAN1) - verificar acceso local
WEB_ID=$(docker ps | grep web-server | awk '{print $1}')
docker exec $WEB_ID sh -c "wget -qO- --header='Host: dominio.local' http://localhost/"
docker exec $WEB_ID sh -c "wget -qO- --header='Host: dominio.com' http://localhost/"


# Entrar al cliente (segunda prueba)
docker exec -it f4f52aff26b3 sh
# Ping a R4 (gateway)
ping -c3 10.2.0.1
# Ping a R1 (cara NAT)
ping -c3 10.0.12.1
# DNS - resolver dominio.com (debe devolver 10.0.12.1)
nslookup dominio.com 10.1.0.10
# HTTP - acceder al sitio via NAT
wget -qO- --header='Host: dominio.com' http://10.0.12.1/
# Verificar que dominio.local NO resuelve desde LAN2
nslookup dominio.local 10.1.0.10

# prueba 3 por tcp y no udp
nslookup -vc dominio.com 10.0.12.1

# prueab 4 desde el cliente 
nslookup dominio.com 10.0.12.1
nslookup dominio.com 10.1.0.10

nslookup dominio.local 10.1.0.10
nslookup dominio.local 10.0.12.1

# prueba 5 desde el dns
dig @10.1.0.10 dominio.local +short

# prueba 6 desde el web server
nslookup dominio.local 10.1.0.10
wget -qO- --header='Host: dominio.local' http://10.1.0.11/

## routers
show ip ospf neighbor # en cada router

show ipv6 ospf neighbor
show ipv6 route ospf

# verificar nats en R1
show ip nat translations 
# verificar ACLs
show access-lists


# debug log
debug ip nat
debug ip packet detail



undebug all

# Asignacion de ipv6
# DNS server → fd00:1::10
docker exec $DNS_ID bash -c "
ip -6 addr add fd00:1::10/64 dev eth0 2>/dev/null || true
ip -6 route add default via fd00:1::1 2>/dev/null || true
echo 'DNS IPv6:'
ip addr show eth0 | grep 'fd00:1::10'
"

# Web server → fd00:1::11
docker exec $WEB_ID sh -c "
ip -6 addr add fd00:1::11/64 dev eth0 2>/dev/null || true
ip -6 route add default via fd00:1::1 2>/dev/null || true
echo 'Web IPv6:'
ip addr show eth0 | grep 'fd00:1::11'
"

# Cliente → fd00:2::10
docker exec $CLIENT_ID sh -c "
ip -6 addr add fd00:2::10/64 dev eth0 2>/dev/null || true
ip -6 route add default via fd00:2::1 2>/dev/null || true
echo 'Cliente IPv6:'
ip addr show eth0 | grep 'fd00:2::10'
"


# Corregir db.dominio.local
docker exec $DNS_ID bash -c "cat > /etc/bind/zones/db.dominio.local << 'EOF'
\$TTL 86400
@   IN  SOA ns1.dominio.local. admin.dominio.local. (
            2024010102
            3600
            1800
            604800
            86400 )
@       IN  NS      ns1.dominio.local.
ns1     IN  A       10.1.0.10
@       IN  A       10.1.0.11
www     IN  A       10.1.0.11
@       IN  AAAA    fd00:1::11
www     IN  AAAA    fd00:1::11
ns1     IN  AAAA    fd00:1::10
EOF"

# Corregir db.dominio.com.external
docker exec $DNS_ID bash -c "cat > /etc/bind/zones/db.dominio.com.external << 'EOF'
\$TTL 86400
@   IN  SOA ns1.dominio.com. admin.dominio.com. (
            2024010102
            3600
            1800
            604800
            86400 )
@       IN  NS      ns1.dominio.com.
ns1     IN  A       10.1.0.10
@       IN  A       10.0.12.1
www     IN  A       10.0.12.1
@       IN  AAAA    fd00:12::1
www     IN  AAAA    fd00:12::1
EOF"

# Corregir db.dominio.com.internal
docker exec $DNS_ID bash -c "cat > /etc/bind/zones/db.dominio.com.internal << 'EOF'
\$TTL 86400
@   IN  SOA ns1.dominio.com. admin.dominio.com. (
            2024010102
            3600
            1800
            604800
            86400 )
@       IN  NS      ns1.dominio.com.
ns1     IN  A       10.1.0.10
@       IN  A       10.1.0.11
www     IN  A       10.1.0.11
@       IN  AAAA    fd00:1::11
www     IN  AAAA    fd00:1::11
EOF"

# Pruebas con ipv6
DNS_ID=$(docker ps | grep dns-server | awk '{print $1}')
CLIENT_ID=$(docker ps | grep cliente | awk '{print $1}')

echo "=== LAN1 - dominio.local A ==="
docker exec $DNS_ID bash -c "dig @10.1.0.10 dominio.local A +short"

echo "=== LAN1 - dominio.local AAAA ==="
docker exec $DNS_ID bash -c "dig @10.1.0.10 dominio.local AAAA +short"

echo "=== LAN1 - dominio.com A ==="
docker exec $DNS_ID bash -c "dig @10.1.0.10 dominio.com A +short"

echo "=== LAN1 - dominio.com AAAA ==="
docker exec $DNS_ID bash -c "dig @10.1.0.10 dominio.com AAAA +short"

echo "=== LAN2 - dominio.com A (via NAT) ==="
docker exec $CLIENT_ID sh -c "nslookup dominio.com 10.0.12.1"

echo "=== LAN2 - dominio.local NO debe resolver ==="
docker exec $CLIENT_ID sh -c "nslookup dominio.local 10.0.12.1"

#verificacion post ipv6
WEB_ID=$(docker ps | grep web-server | awk '{print $1}')
CLIENT_ID=$(docker ps | grep cliente | awk '{print $1}')

# HTTP desde LAN1
docker exec $WEB_ID sh -c "wget -qO- --header='Host: dominio.local' http://10.1.0.11/ | grep title"
docker exec $WEB_ID sh -c "wget -qO- --header='Host: dominio.com' http://10.1.0.11/ | grep title"

# HTTP desde LAN2 via NAT
docker exec $CLIENT_ID sh -c "wget -qO- --header='Host: dominio.com' http://10.0.12.1/ | grep title"