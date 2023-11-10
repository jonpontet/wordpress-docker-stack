
# Load .env  file.
if [ -z "$1" ]; then
  # shellcheck source=scripts/load-env-file.sh
  . "$(dirname "${BASH_SOURCE[0]}")"/load-env-file.sh local
else
  # shellcheck source=scripts/load-env-file.sh
  . "$(dirname "${BASH_SOURCE[0]}")"/load-env-file.sh "$1"
fi

# Confirm paths.
echo -e "PROJECT_PATH: ${PROJECT_PATH}"
echo -e "WEB_ROOT_PATH: ${WEB_ROOT_PATH}"

# shellcheck disable=SC2034
NOW=$(date "+%Y-%m-%d-%Hh%Mm%Ss")

FILES_TO_DELETE=(
  readme.html
  license.txt
  wp-config-sample.php
)

PLUGINS_TO_DELETE=(
)

THEMES_TO_DELETE=(
)

PLUGINS_TO_DEACTIVATE=(
)

THEME_TO_ACTIVATE=

PLUGINS_TO_KEEP=(
)
