#!/bin/sh

[ -f mkcert ] || {
    MKCERT_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep tag_name | cut -d '"' -f 4);
    echo "⏬ Download mkcert";
    curl -sLo "mkcert" "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64";
} && {
    echo "✅ mkcert already downloaded";
}

echo "🖥️ Make mkcert executable";
chmod +x "mkcert";

echo "🖥️ Check mkcert version";
echo "mkcert version : $(./mkcert --version)";
echo "";

echo "🖥️ Install mkcert certs";
./mkcert -install;

echo "🔐 Generate dev certificates";
SSL_DOMAINS="maildev maildev.localhost maildev.local dashboard dashboard.localhost dashboard.local phpmyadmin phpmyadmin.localhost phpmyadmin.local *.dev.localhost *.dev.local *.docker.localhost *.docker.local";
if [ -f ./ssl-domains.txt ]; then
    SSL_DOMAINS="${SSL_DOMAINS} $(tr '\n' ' ' < ./ssl-domains.txt)";
fi;

# shellcheck disable=SC2086
./mkcert -cert-file "certs/_default.pem" -key-file "certs/_default-key.pem" $SSL_DOMAINS;
echo "";

echo "💽 Create external volumes";
if [ "$(docker volume list --quiet --filter name="volume-mysql")" ]; then
    echo '  ✅ Volume "volume-mysql" already created.'
else
    echo '  ✅ Creating volume "volume-mysql"'
    mkdir -p "$PWD/volumes/mysql-data";
    docker volume create --driver "local" --opt "type=none" --opt "o=bind" --opt "device=volumes/mysql-data" --name "mysql-data" "volume-mysql";
fi

if [ "$(docker volume list --quiet --filter name="portainer-data")" ]; then
    echo '  ✅ Volume "portainer-data" already created.'
else
    echo '  ✅ Creating volume "portainer-data"'
    mkdir -p "$PWD/volumes/portainer-data";
    docker volume create --driver "local" --opt "type=none" --opt "o=bind" --opt "device=volumes/portainer-data" --name "portainer-data" "volume-portainer";
fi
echo "";

echo "🌍 Create external network";
if [ "$(docker network list --quiet --filter name="local-network")" ]; then
    echo '  ✅ Network "local-network" already created.'
else
    echo '  ✅ Creating network "local-network"'
    docker network create "local-network";
fi
echo "";

echo "📜 Checking .env file";
if [ -e ".env" ]; then
    echo "  ✅ .env file exists";
else
    echo "  🔄 Copying .env.example to .env";
    echo "  💬 Think about customizing it to your liking before starting docker";
    cp ".env.example" ".env"
fi
echo "";

echo "✅ ALL GOOD ✅";
echo "You can now start your docker environment using \`docker compose up -d\`";
