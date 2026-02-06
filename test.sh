#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname $0)"

FROM_PARTY=$1 docker compose --profile test up --force-recreate --build --no-deps edelivery-send
