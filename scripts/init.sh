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

# Clean-up files.
echo "Clean-up files..."
for FILE_TO_DELETE in "${FILES_TO_DELETE[@]}"; do
  echo -e "Delete file: ${WEB_ROOT_PATH}/${FILE_TO_DELETE}"
  rm -rf "${WEB_ROOT_PATH:?}"/"${FILE_TO_DELETE}"
done

# Move to webroot for the subsequent commands.
cd ${WEB_ROOT_PATH} || {
  echo "Directory ${WEB_ROOT_PATH} not found"
  exit 1
}

# Check WordPress is installed before continuing.
if [ "${environment}" = "prod" ]; then
  wp core is-installed --path="${WEB_ROOT_PATH}" || {
    echo "WordPress is not installed: run wp core install."
    exit 1
  }
else
  ${DOCKER_WP_CLI_EXEC} wp core is-installed --path=${SERVER_PATH}/${WEB_ROOT_FOLDER} || {
    echo "WordPress is not installed: run wp core install."
    exit 1
  }
fi

# Clean-up plugins.
echo "Clean-up plugins..."
for PLUGIN_TO_DELETE in "${PLUGINS_TO_DELETE[@]}"; do
  echo -e "Delete plugin: ${PLUGIN_TO_DELETE}"
  if [ "${environment}" = "prod" ]; then
    wp plugin delete ${PLUGIN_TO_DELETE} --path="${WEB_ROOT_PATH}"
  else
    ${DOCKER_WP_CLI_EXEC} wp plugin delete ${PLUGIN_TO_DELETE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  fi
done

# Activate theme before cleaning up themes.
if [ -n "${THEME_TO_ACTIVATE}" ]; then
  echo -e "Activate theme: ${THEME_TO_ACTIVATE}"
  if [ "${environment}" = "prod" ]; then
    wp theme activate ${THEME_TO_ACTIVATE} --path="${WEB_ROOT_PATH}"
  else
    ${DOCKER_WP_CLI_EXEC} wp theme activate ${THEME_TO_ACTIVATE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  fi
fi

# Clean-up themes.
echo "Clean-up themes..."
for THEME_TO_DELETE in "${THEMES_TO_DELETE[@]}"; do
  echo -e "Delete theme: ${THEME_TO_DELETE}"
  if [ "${environment}" = "prod" ]; then
    wp theme delete ${THEME_TO_DELETE} --path="${WEB_ROOT_PATH}"
  else
    ${DOCKER_WP_CLI_EXEC} wp theme delete ${THEME_TO_DELETE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  fi
done
