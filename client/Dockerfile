FROM alpine:latest

# Instalamos herramientas esenciales:
# - bind-tools: para usar 'dig' o 'nslookup'
# - curl/wget: para leer el HTML del servidor
# - iproute2/iputils: para comandos 'ip addr' y 'ping'
RUN apk update && apk add --no-cache \
    bind-tools \
    curl \
    wget \
    iproute2 \
    iputils \
    bash

# Definimos el directorio de trabajo
WORKDIR /root

# docker build --no-cache -t cliente-victor:latest .

# Mantenemos el contenedor encendido para que no se cierre en GNS3
CMD ["tail", "-f", "/dev/null"]