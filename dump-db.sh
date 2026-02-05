#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

MYSQL_ROOT_PASSWORD=local-pwd-123

service=${1:-""}

if [[ "$service" == "smp-db-1" ]]; then
  database="harmony_smp"
elif [[ "$service" == "sml-db" ]]; then
  database="harmony_sml"
else
  echo "Unsupported service: $service"
  exit 1
fi

cd "$(dirname $0)"

docker compose exec $service sh -c "exec mysqldump --no-create-db --no-create-info -uroot -p\"$MYSQL_ROOT_PASSWORD\" $database"
