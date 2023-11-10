#!/usr/bin/env bash

### Download production uploads.

# shellcheck source=scripts/script-vars.sh
. "$(dirname "${BASH_SOURCE[0]}")"/vars.sh local

usage() {
  printf "import-uploads.sh [stage|prod]\n"
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

FILE=${DOMAIN}-uploads-${NOW}.tar.gz

# Make temp directory to download to.
mkdir -p tmp

# Create a copy of wp-content/uploads.
echo "Create archive of uploads directory: ${FILE}"
$SSH "${SSH_USER}"@"${IP}" "cd ${DEPLOY_PATH} && tar -czf ${FILE} ${DEPLOY_PATH}/${WEB_ROOT_FOLDER}/wp-content/uploads"

# Download the copy of wp-content/uploads.
echo "Download archive."
scp -v ${SSH_USER}"@"${IP}:${DEPLOY_PATH}/${FILE} "${PROJECT_PATH}/tmp"

# Extract archive.
echo "Extract archive."
tar -xf ${PROJECT_PATH}/tmp/${FILE} -C ${PROJECT_PATH}/tmp

# Move extract to wp-content/uploads.
echo "Move uploads to wp-content."
# rsync: update, recursive.
rsync -ur --no-relative "${PROJECT_PATH}"/tmp"${DEPLOY_PATH}"/"${WEB_ROOT_FOLDER}"/wp-content/uploads/* "${WEB_ROOT_PATH}"/wp-content/uploads

# Delete local and remote files and folders when done.
echo "Clean-up."
$SSH "${SSH_USER}"@"${IP}" "rm -f ${DEPLOY_PATH}/${FILE}"
rm -fr ${PROJECT_PATH}/tmp