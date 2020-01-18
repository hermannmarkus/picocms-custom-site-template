#!/usr/bin/env bash
# Provision PicoCMS

set -eo pipefail

echo " * Custom site template provisioner ${PICO_SITE_NAME} - downloads and installs a copy of PicoCMS for testing, building client sites, etc"

# fetch the first host as the primary domain. If none is available, generate a default using the site name
DOMAIN=$(get_primary_host "${PICO_SITE_NAME}".test)
SITE_TITLE=$(get_config_value 'site_title' "${DOMAIN}")

echo " * Setting up the log subfolder for Apache logs"
noroot mkdir -p "${PICO_PATH_TO_SITE}/log"
noroot touch "${PICO_PATH_TO_SITE}/log/apache-error.log"
noroot touch "${PICO_PATH_TO_SITE}/log/apache-access.log"

PICO_INSTALL_PATH="${PICO_PATH_TO_SITE}/public_html"

echo " * Creating public_html folder if it doesn't exist already"
noroot mkdir -p "${PICO_INSTALL_PATH}"


if [ "$(ls -A $PICO_INSTALL_PATH)" ]; then
  echo " * Installing PicoCMS"
  noroot composer create-project picocms/pico-composer "${PICO_INSTALL_PATH}"
fi

cd "${PICO_INSTALL_PATH}"

echo " * Copying the sites apache config template"
if [ -f "${PICO_PATH_TO_SITE}/provision/pico-apache-custom.conf" ]; then
  echo " * A pico-apache-custom.conf file was found"
  cp -f "${PICO_PATH_TO_SITE}/provision/pico-apache-custom.conf" "${PICO_PATH_TO_SITE}/provision/pico-apache.conf"
else
  echo " * Using the default pico-apache-default.conf, to customize, create a pico-apache-custom.conf"
  cp -f "${PICO_PATH_TO_SITE}/provision/pico-apache-default.conf" "${PICO_PATH_TO_SITE}/provision/pico-apache.conf"
fi

echo " * Site Template provisioner script completed for ${PICO_SITE_NAME}"