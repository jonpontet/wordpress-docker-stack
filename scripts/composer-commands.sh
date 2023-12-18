#!/usr/bin/env bash

### Handle composer commands.

# shellcheck source=scripts/vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "composer-commands.sh <command> <environment> [package] [--dev]\n"
}

command=''
environment=''
package=''
dev=''

if [ -n "$1" ]; then
  command=$1
fi

if [ -n "$2" ]; then
  environment=$2
fi

if [ -n "$3" ]; then
  package=$3
fi

if [ -n "$4" ]; then
  dev=$4
fi

# Check that all required parameters are there.
if [ -z "${command}" ]; then
  echo "Missing command parameter."
  usage
  exit 1
fi

if [ -z "${environment}" ]; then
  echo "Missing environment parameter."
  usage
  exit 1
fi

if [ "${command}" = "require" ] || [ "${command}" = "remove" ] && [ -z "${package}" ]; then
  echo "Missing package parameter."
  usage
  exit 1
fi

echo "Command: ${command}"
echo "Environment: ${environment}"
if [ -n "${package}" ]; then
  echo "Package: ${package}"
fi
if [ -n "${dev}" ]; then
  echo "Dev mode: ${dev}"
fi

# Composer install.
if [ "${command}" = "install" ]; then
  echo "Composer install..."
  if [ "${environment}" = "prod" ]; then
    composer i --ignore-platform-reqs --working-dir=./ --no-interaction --no-dev
  else
    docker exec ${DOCKER_WEB_CONTAINER} composer i --working-dir=${SERVER_PATH} --no-interaction
  fi
fi

# Composer update.
if [ "${command}" = "update" ]; then
  echo "Composer update..."
  docker exec ${DOCKER_WEB_CONTAINER} composer u --working-dir=${SERVER_PATH} --no-interaction
fi

# Composer require.
if [ "${command}" = "require" ]; then
  echo "Composer require..."
  docker exec ${DOCKER_WEB_CONTAINER} composer require ${package} ${dev}
fi

# Composer remove.
if [ "${command}" = "remove" ]; then
  echo "Composer remove..."
  docker exec ${DOCKER_WEB_CONTAINER} composer remove ${package} ${dev}
fi
