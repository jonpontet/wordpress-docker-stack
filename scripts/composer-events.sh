#!/usr/bin/env bash

### Handle composer scripts events.
# Uses SERVER_PATH because this is run by composer.

# shellcheck source=scripts/vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "composer-events.sh [pre-install-cmd|post-install-cmd]\n"
}

event=''

if [ -n "$1" ]; then
  event=$1
fi

# Check that all required parameters are there.
if [ -z "${event}" ]; then
  echo "Missing event parameter."
  usage
  exit 1
fi

echo "Event: ${event}"

# pre-install-cmd or pre-update-cmd.
if [[ "${event}" = "pre-install-cmd" || "${event}" = "pre-update-cmd" ]]; then
  cd ${SERVER_PATH} || {
    echo "Folder ${SERVER_PATH} not found"
    exit 1
  }
  mkdir -p tmp

  # Move theme as it will be overwritten.
  if [ -n "${THEME_TO_ACTIVATE}" ]; then
    echo "Move theme: ${THEME_TO_ACTIVATE}"
    mv ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/themes/${THEME_TO_ACTIVATE} ${SERVER_PATH}/tmp/${THEME_TO_ACTIVATE} || {
      echo "Folder ${THEME_TO_ACTIVATE} not found"
      exit 1
    }
  fi

  # Move plugin(s) as they will be overwritten.
  for PLUGIN_TO_KEEP in "${PLUGINS_TO_KEEP[@]}"; do
    echo "Move plugin: ${PLUGIN_TO_KEEP}"
    mv ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/plugins/${PLUGIN_TO_KEEP} ${SERVER_PATH}/tmp/${PLUGIN_TO_KEEP} || {
      echo "Plugin ${PLUGIN_TO_KEEP} not found"
      exit 1
    }
  done

  # Move uploads as it will be overwritten.
  echo "Move uploads..."
  mv ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/uploads ${SERVER_PATH}/tmp/uploads || {
    echo "Uploads folder not found"
    exit 1
  }
fi

# post-install-cmd or post-update-cmd.
if [[ "${event}" = "post-install-cmd" || "${event}" = "post-update-cmd" ]]; then
  # Copy back overwritten theme.
  if [ -n "${THEME_TO_ACTIVATE}" ]; then
    echo "Move back theme: ${THEME_TO_ACTIVATE}"
    cp ${SERVER_PATH}/tmp/${THEME_TO_ACTIVATE} ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/themes/"${THEME_TO_ACTIVATE}" || {
      echo "Theme ${THEME_TO_ACTIVATE} not found"
      exit 1
    }
  fi

  # Copy back plugin(s).
  for PLUGIN_TO_KEEP in "${PLUGINS_TO_KEEP[@]}"; do
    echo "Move back plugin: ${PLUGIN_TO_KEEP}"
    cp ${SERVER_PATH}/tmp/${PLUGIN_TO_KEEP} ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/plugins/"${PLUGIN_TO_KEEP}" || {
      echo "Plugin ${PLUGIN_TO_KEEP} not found"
      exit 1
    }
  done

  # Copy back overwritten uploads.
  echo "Move back uploads..."
  cp ${SERVER_PATH}/tmp/uploads ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/uploads || {
    echo "Uploads folder not found"
    exit 1
  }
fi

# post-install-cmd or post-update-cmd.
if [[ "${event}" = "post-install-cmd" || "${event}" = "post-update-cmd" ]]; then
  # Composer install on theme.
  if [ -n "${THEME_TO_ACTIVATE}" ]; then
    echo "Composer update theme: ${THEME_TO_ACTIVATE}"
    cd ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/themes/"${THEME_TO_ACTIVATE}" || {
      echo "Theme ${THEME_TO_ACTIVATE} not found"
      exit 1
    }
    composer install
  fi

  # Composer install on plugins.
  for PLUGIN_TO_KEEP in "${PLUGINS_TO_KEEP[@]}"; do
    echo "Composer update plugin: ${PLUGIN_TO_KEEP}"
    cd ${SERVER_PATH}/${WEB_ROOT_FOLDER}/wp-content/plugins/"${PLUGIN_TO_KEEP}" || {
      echo "Plugin ${PLUGIN_TO_KEEP} not found"
      exit 1
    }
    composer install
  done
fi
