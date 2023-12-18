#!/usr/bin/env bash

### Used to initialise an environment for the first time.

# shellcheck source=scripts/script-vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "init.sh [local|prod]\n"
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

# Create htaccess.
echo "Create htaccess..."
if [ "${environment}" = "local" ]; then
  rsync -avz --ignore-existing "${DEFAULTS_PATH}"/wordpress/"${environment}"/.htaccess "${WEB_ROOT_PATH}"/.htaccess
else
  cp -f "${DEFAULTS_PATH}"/wordpress/"${environment}"/.htaccess "${WEB_ROOT_PATH}"/.htaccess
fi

# Create wp-config.php.
echo "Create wp-config.php..."
if [ "${environment}" = "prod" ]; then
  cp -f "${DEFAULTS_PATH}"/wordpress/wp-config.php "${WEB_ROOT_PATH}"/wp-config.php
else
  rsync -avz --ignore-existing "${DEFAULTS_PATH}"/wordpress/wp-config.php "${WEB_ROOT_PATH}"/wp-config.php
fi