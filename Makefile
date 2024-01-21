include .env

default: list

.PHONY: list
list:

.PHONY: init
init:
	@echo "Initialising environment..."
	./scripts/init.sh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: clean-up
clean-up:
	@echo "Cleaning-up files, plugins & themes..."
	./scripts/clean-up.sh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: import-db
import-db:
	@echo "Importing DB..."
	./scripts/import-db.sh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: import-uploads
import-uploads:
	@echo "Importing uploads..."
	./scripts/import-uploads.sh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: docker-build
docker-build:
	@echo "Building docker..."
	docker build -t $(filter-out $@,$(MAKECMDGOALS)):latest .

.PHONY: docker-up
docker-up:
	@echo "Starting docker..."
	docker compose up -d --remove-orphans --force-recreate

.PHONY: composer-i
composer-i:
	@echo "Composer install..."
	./scripts/composer-commands.sh install $(filter-out $@,$(MAKECMDGOALS))

.PHONY: composer-u
composer-u:
	@echo "Composer update..."
	./scripts/composer-commands.sh update $(filter-out $@,$(MAKECMDGOALS))

.PHONY: composer-require
composer-require:
	@echo "Composer require..."
	./scripts/composer-commands.sh require $(filter-out $@,$(MAKECMDGOALS))

.PHONY: composer-remove
composer-remove:
	@echo "Composer remove..."
	./scripts/composer-commands.sh remove $(filter-out $@,$(MAKECMDGOALS))

.PHONY: docker-sh
docker-sh:
	@echo "Docker shell..."
	docker exec -it ${DOCKER_WEB_CONTAINER} /bin/bash

.PHONY: wp-sh
wp-sh:
	@echo "WP-CLI shell..."
	docker exec -it ${DOCKER_WP_CLI_CONTAINER} /bin/bash

.PHONY: wp
wp:
	@echo "WP-CLI..."
	docker exec ${DOCKER_WP_CLI_CONTAINER} wp --path=${SERVER_PATH}/${WEB_ROOT_FOLDER} $(filter-out $@,$(MAKECMDGOALS))

.PHONY: enable-xdebug
enable-xdebug:
	@echo "Enable Xdebug..."
	docker exec -it ${DOCKER_WEB_CONTAINER} sed -i 's/xdebug.mode=off/xdebug.mode=debug/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
	docker exec -it ${DOCKER_WEB_CONTAINER} /etc/init.d/apache2 restart

.PHONY: disable-xdebug
disable-xdebug:
	@echo "Disable Xdebug..."
	docker exec -it ${DOCKER_WEB_CONTAINER} sed -i 's/xdebug.mode=debug/xdebug.mode=off/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
	docker exec -it ${DOCKER_WEB_CONTAINER} apache2ctl restart


# Pass arguments via command line: https://stackoverflow.com/a/6273809/1826109
%:
	@:
