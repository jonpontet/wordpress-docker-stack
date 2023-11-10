#!/usr/bin/env bash

### Download and import prod or stage database.

# shellcheck source=scripts/vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "import-db.sh [stage|prod]\n"
}

environment=''

if [ -n "$1" ]; then
  environment=$1
fi

# Check that all required parameters are there.
if [ -z "${environment}" ]; then
  echo "Missing environment parameter."
  usage
  exit 1
fi

echo "Environment: ${environment}"

if [ "${environment}" = "stage" ]; then
  DOMAIN=${STAGE_DOMAIN}
  IP=${STAGE_IP}
  DEPLOY_PATH=${STAGE_DEPLOY_PATH}
else
  DOMAIN=${PROD_DOMAIN}
  IP=${PROD_IP}
  DEPLOY_PATH=${PROD_DEPLOY_PATH}
fi

FILE=${DOMAIN}-${NOW}-db.sql

cd ${PROJECT_PATH} && mkdir -p backups

# Export remote DB to file.
echo "Export remote database to: ${FILE}"
$SSH "${SSH_USER}"@"${IP}" "cd ${DEPLOY_PATH}/${WEB_ROOT_FOLDER} && wp db export ${FILE} --add-drop-table"

# Download remote export.
echo "Download remote export."
scp -v ${SSH_USER}"@"${IP}:${DEPLOY_PATH}/${WEB_ROOT_FOLDER}/${FILE} "${PROJECT_PATH}/backups"

# Import DB export.
echo "Import downloaded file: ${FILE}"
docker exec -i ${PROJECT_NAME}-db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < "${PROJECT_PATH}/backups/${FILE}"

# Update domain.
# shellcheck source=scripts/update-domain.sh
. "$(dirname "${BASH_SOURCE[0]}")"/update-domain.sh "${environment}"

# Deactivate plugins.
# shellcheck source=scripts/deactivate-plugins.sh
. "$(dirname "${BASH_SOURCE[0]}")"/deactivate-plugins.sh