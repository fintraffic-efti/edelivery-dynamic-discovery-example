#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd $(dirname $0)

docker compose exec -ti smp-1 java -cp "/usr/local/tomcat/webapps/harmonysmp/WEB-INF/lib/*" eu.europa.ec.edelivery.smp.utils.BCryptPasswordHash $1
