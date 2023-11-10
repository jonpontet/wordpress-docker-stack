#!/usr/bin/env bash

### Deactivate un-required plugins.

# shellcheck source=scripts/vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

# Deactivate plugins.
echo "Deactivate plugins."
for PLUGIN_TO_DEACTIVATE in "${PLUGINS_TO_DEACTIVATE[@]}"
do
  echo -e "Deactivate plugin: ${PLUGIN_TO_DEACTIVATE}"
  ${DOCKER_WP_CLI_EXEC} wp plugin deactivate ${PLUGIN_TO_DEACTIVATE} --path=${SERVER_PATH}/${WEB_ROOT_FOLDER}
done