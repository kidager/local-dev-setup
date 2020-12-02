#!/bin/bash

MKCERT_VERSION="v1.4.3";
MKCERT_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep tag_name | cut -d '"' -f 4);

echo "### Download mkcert";
[[ -f mkcert ]] || curl -sLo "mkcert" "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64";

echo "### Make mkcert executable";
chmod +x "mkcert";

echo "### Check mkcert version";
echo "mkcert version : $(./mkcert --version)";

echo "### Install mkcert certs";
./mkcert -install;

echo "### Generate dev certificates";
SSL_DOMAINS="maildev maildev.localhost maildev.local dashboard dashboard.localhost dashboard.local phpmyadmin phpmyadmin.localhost phpmyadmin.local *.dev.localhost *.dev.local *.docker.localhost *.docker.local";
if [[ -f ./ssl-domains.txt ]]; then
    SSL_DOMAINS="${SSL_DOMAINS} $(< ./ssl-domains.txt)"
fi;

# shellcheck disable=SC2086
./mkcert \
    -cert-file "certs/_default.pem" \
    -key-file "certs/_default-key.pem" \
    $SSL_DOMAINS \
;


echo "### Create external volumes";
mkdir -p "$PWD/volumes/mysql-data";
docker volume create --driver local --opt type=none --opt o=bind --opt device="$PWD/volumes/mysql-data" volume-mysql;

mkdir -p "$PWD/volumes/portainer-data";
docker volume create --driver local --opt type=none --opt o=bind --opt device="$PWD/volumes/portainer-data" volume-portainer;

echo "### Create external network";
docker network create local-network;
