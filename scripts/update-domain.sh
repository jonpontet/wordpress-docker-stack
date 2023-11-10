#!/usr/bin/env bash

### Update WP domain.

# shellcheck source=scripts/vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "update-domain.sh [stage|prod]\n"
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
else
  DOMAIN=${PROD_DOMAIN}
fi

REPLACEMENT_DOMAIN="${LOCAL_DOMAIN}"
REPLACEMENT_SSL_DOMAIN="${LOCAL_DOMAIN}"
if [ ! -z "${LOCAL_PORT}" ]; then
  REPLACEMENT_DOMAIN="${LOCAL_DOMAIN}":"${LOCAL_PORT}"
fi
if [ ! -z "${LOCAL_SSL_PORT}" ]; then
  REPLACEMENT_SSL_DOMAIN="${LOCAL_DOMAIN}":"${LOCAL_SSL_PORT}"
fi

if [ "${USE_HTTPS}" = "yes" ]; then
  echo -e "Replacing domain https://${DOMAIN} for https://${REPLACEMENT_SSL_DOMAIN}"
  ${DOCKER_WP_CLI_EXEC} wp search-replace 'https://${DOMAIN}' 'https://${REPLACEMENT_SSL_DOMAIN}' --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  ${DOCKER_WP_CLI_EXEC} wp search-replace 'http://${DOMAIN}' 'https://${REPLACEMENT_SSL_DOMAIN}' --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
else
  echo -e "Replacing domain https://${DOMAIN} for http://${REPLACEMENT_DOMAIN}"
  ${DOCKER_WP_CLI_EXEC} wp search-replace 'http://${DOMAIN}' 'http://${REPLACEMENT_DOMAIN}' --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  ${DOCKER_WP_CLI_EXEC} wp search-replace 'https://${DOMAIN}' 'http://${REPLACEMENT_DOMAIN}' --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
fi

${DOCKER_WP_CLI_EXEC} wp search-replace '//${DOMAIN}' '//${REPLACEMENT_DOMAIN}' --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}