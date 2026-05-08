FROM nginx:alpine

# Copiar configuración principal de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar los archivos de los sitios virtuales
COPY sites/ /etc/nginx/conf.d/

# Copiar el contenido de las páginas web
COPY html/ /var/www/

# Puerto para HTTP
EXPOSE 80
