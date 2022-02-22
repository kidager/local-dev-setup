# -*- mode: makefile -*-
#
#--------------------------------------------------------------------------
# Variable definition
#--------------------------------------------------------------------------
#
# Use to differentiate makefile run on local vs CI
#
COMPOSE = MSYS_NO_PATHCONV=1 docker compose
DOCKER = MSYS_NO_PATHCONV=1 docker

# https://github.com/FiloSottile/mkcert#installation
ifeq ($(OS),Windows_NT)
	MKCERT_BINARY = ./bin/mkcert-v1.4.3-windows-amd64.exe
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		MKCERT_BINARY = ./bin/mkcert-v1.4.3-linux-amd64
	endif
	ifeq ($(UNAME_S),Darwin)
		MKCERT_BINARY = ./bin/mkcert-v1.4.3-darwin-amd64
	endif
endif

#
#--------------------------------------------------------------------------
##@ Help
#--------------------------------------------------------------------------
#
.PHONY: help
help: ## Print this help with list of available commands/targets and their purpose
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

#
#--------------------------------------------------------------------------
##@ Docker Compose
#--------------------------------------------------------------------------
#
# Manage docker compose instances
#
.PHONY: up
up: pull ## Start the stack
	@$(COMPOSE) up -d

.PHONY: down
down: ## Stop the stack
	@$(COMPOSE) down --remove-orphans

.PHONY: pull
pull: ## Pull the latest images for the docker compose file
	@$(COMPOSE) pull


#
#--------------------------------------------------------------------------
##@ SSL Certificates
#--------------------------------------------------------------------------
#
# To manage self-signed ssl certificates
#
.PHONY: ssl-generate
ssl-generate: ## Generate the SSL certificates needed for https
	@$(MKCERT_BINARY) \
		-cert-file "./certs/_default.pem" \
		-key-file "./certs/_default-key.pem" \
		"ankorstore.localhost" \
		"*.ankorstore.localhost" \
		"dev.localhost" \
		"*.dev.localhost" \
		"ankorlocal.com" \
		"*.ankorlocal.com" \
		$$(tr '\n' ' ' < ./ssl-domains.txt || printf '')

.PHONY: ssl-import
ssl-import: ## Import the root certificate of mkcert
	@$(MKCERT_BINARY) -install

.PHONY: ssl-reset
ssl-reset: ## Remove the generated certificates
	rm -f \
		"./certs/_default.pem" \
		"./certs/_default-key.pem"

%: force
	@mkdir -p ./certs;
	@mkdir -p ./config/phpmyadmin;
	@mkdir -p ./volumes/mysql-data;
	@mkdir -p ./volumes/portainer-data;

	@if [ ! -f .env ]; then cp .env.example .env ; fi;
	@if [ ! -f ./config/phpmyadmin/config.creds.inc.php ]; then cp ./config/phpmyadmin/config.creds{.example,}.inc.php; fi;

	@[ "$$($(DOCKER) volume list --quiet --filter name="mysql-data")" ] || $(DOCKER) volume create --driver "local" --opt "type=none" --opt "o=bind" --opt "device=volumes/mysql-data" "mysql-data";
	@[ "$$($(DOCKER) volume list --quiet --filter name="portainer-data")" ] || $(DOCKER) volume create --driver "local" --opt "type=none" --opt "o=bind" --opt "device=volumes/portainer-data" "portainer-data";
	@[ "$$($(DOCKER) network list --quiet --filter name="traefik-network")" ] || $(DOCKER) network create "traefik-network";

.PHONY: force
force:
