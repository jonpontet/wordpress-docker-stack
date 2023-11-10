include .env

default: list

.PHONY: list
list:

.PHONY: init
init:
	@echo "Initialising environment..."
	./scripts/init.sh $(filter-out $@,$(MAKECMDGOALS))

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
	docker build -t pontetlabs-web:latest .

.PHONY: docker-up
docker-up:
	@echo "Starting docker..."
	docker compose up -d --remove-orphans --force-recreate

.PHONY: composer-i
composer-i:
	@echo "Composer install..."
	docker exec ${DOCKER_WEB_CONTAINER} composer i --working-dir=${SERVER_PATH} --no-interaction

.PHONY: composer-u
composer-u:
	@echo "Composer update..."
	docker exec ${DOCKER_WEB_CONTAINER} composer u --working-dir=${SERVER_PATH} --no-interaction

.PHONY: composer-require
composer-require:
	@echo "Composer require..."
	docker exec ${DOCKER_WEB_CONTAINER} composer require $(filter-out $@,$(MAKECMDGOALS))

.PHONY: composer-remove
composer-remove:
	@echo "Composer remove..."
	docker exec ${DOCKER_WEB_CONTAINER} composer remove $(filter-out $@,$(MAKECMDGOALS))

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

# Pass arguments via command line: https://stackoverflow.com/a/6273809/1826109
%:
	@:
