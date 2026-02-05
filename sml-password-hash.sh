#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd $(dirname $0)

text="$1"

# Build the SML image if needed
docker compose build sml

# Run a temporary container without starting Tomcat
# We override the entrypoint to prevent Tomcat from starting
docker compose run --rm --no-deps --entrypoint "" -v "./certs:/tmp/certs" sml \
    sh -c "unzip -q /usr/local/tomcat/webapps/edelivery-sml.war -d /usr/local/tomcat/webapps/edelivery-sml ; java -cp \"/usr/local/tomcat/webapps/edelivery-sml/WEB-INF/lib/*\" eu.europa.ec.bdmsl.common.util.EncryptPassword /tmp/certs/encryptionPrivateKey.private \"$text\""
