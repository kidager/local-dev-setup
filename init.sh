#!/bin/bash

MKCERT_VERSION="v1.4.3";

echo "### Download mkcert";
[[ -f mkcert ]] || curl -sLo "mkcert" "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64";

echo "### Make mkcert executable";
chmod +x "mkcert";

echo "### Check mkcert version";
echo "mkcert version : $(./mkcert --version)";

echo "### Install mkcert certs";
./mkcert -install;

echo "### Generate dev certificates";
./mkcert \
    -cert-file "certs/_default.pem" \
    -key-file "certs/_default-key.pem" \
    "maildev" "maildev.localhost" "maildev.local" \
    "dashboard" "dashboard.localhost" "dashboard.local" \
    "phpmyadmin" "phpmyadmin.localhost" "phpmyadmin.local" \
    "*.dev.localhost" "*.dev.local" \
    "*.docker.localhost" "*.docker.local" \
;

echo "### Create external MySQL volume";
docker volume create --driver local --opt type=none --opt o=bind --opt device="$PWD/volumes/mysql-data" volume-mysql;

echo "### Create external network";
docker network create local-network;
