# syntax=docker/dockerfile:1
FROM nginx:1.27-alpine

# Buildless static site
WORKDIR /usr/share/nginx/html
COPY frontend/ .

# Optionally, configure Nginx for SPA or API proxy by editing default.conf
