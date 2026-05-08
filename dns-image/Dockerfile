FROM ubuntu/bind9:latest

# Instalar utilidades necesarias
RUN apt-get update && apt-get install -y \
    iputils-ping \
    curl \
    dnsutils \
    iproute2 \
    bind9utils \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Copiar los archivos de configuración de BIND
COPY named.conf /etc/bind/named.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local

# Copiar los archivos de zona
COPY zones/ /etc/bind/zones/

# Permisos correctos
RUN chmod 644 /etc/bind/zones/* && \
    chown -R bind:bind /etc/bind/zones/

# Puerto para DNS
EXPOSE 53/udp 53/tcp