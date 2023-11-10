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

# Composer install.
echo "Composer install."
#if [ "${environment}" = "prod" ]; then
#  composer i --ignore-platform-reqs --working-dir=./ --no-interaction --no-dev
#else
#  docker exec ${DOCKER_WEB_CONTAINER} composer i --working-dir=${SERVER_PATH} --no-interaction
#fi

# Create htaccess.
echo "Create htaccess."
if [ "${environment}" = "local" ]; then
  rsync -avz --ignore-existing "${DEFAULTS_PATH}"/wordpress/"${environment}"/.htaccess "${WEB_ROOT_PATH}"/.htaccess
else
  cp -f "${DEFAULTS_PATH}"/wordpress/"${environment}"/.htaccess "${WEB_ROOT_PATH}"/.htaccess
fi

# Create wp-config.php.
echo "Create wp-config.php."
if [ "${environment}" = "prod" ]; then
  cp -f "${DEFAULTS_PATH}"/wordpress/wp-config.php "${WEB_ROOT_PATH}"/wp-config.php
else
  rsync -avz --ignore-existing "${DEFAULTS_PATH}"/wordpress/wp-config.php "${WEB_ROOT_PATH}"/wp-config.php
fi

# Clean-up files.
echo "Clean-up files."
for FILE_TO_DELETE in "${FILES_TO_DELETE[@]}"; do
  echo -e "Delete file: ${WEB_ROOT_PATH}/${FILE_TO_DELETE}"
  rm -rf "${WEB_ROOT_PATH:?}"/"${FILE_TO_DELETE}"
done

# Move to webroot for the subsequent commands.
cd ${WEB_ROOT_PATH}

# Clean-up plugins.
echo "Clean-up plugins."
for PLUGIN_TO_DELETE in "${PLUGINS_TO_DELETE[@]}"; do
  echo -e "Delete plugin: ${PLUGIN_TO_DELETE}"
  if [ "${environment}" = "prod" ]; then
    wp plugin delete ${PLUGIN_TO_DELETE} --path="${WEB_ROOT_PATH}"
  else
    ${DOCKER_WP_CLI_EXEC} wp plugin delete ${PLUGIN_TO_DELETE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  fi
done

# Activate theme before cleaning up themes.
echo -e "Activate theme: ${THEME_TO_ACTIVATE}"
if [ "${environment}" = "prod" ]; then
  wp theme activate ${THEME_TO_ACTIVATE} --path="${WEB_ROOT_PATH}"
else
  ${DOCKER_WP_CLI_EXEC} wp theme activate ${THEME_TO_ACTIVATE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
fi

# Clean-up themes.
echo "Clean-up themes."
for THEME_TO_DELETE in "${THEMES_TO_DELETE[@]}"; do
  echo -e "Delete theme: ${THEME_TO_DELETE}"
  if [ "${environment}" = "prod" ]; then
    wp theme delete ${THEME_TO_DELETE} --path="${WEB_ROOT_PATH}"
  else
    ${DOCKER_WP_CLI_EXEC} wp theme delete ${THEME_TO_DELETE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
  fi
done
