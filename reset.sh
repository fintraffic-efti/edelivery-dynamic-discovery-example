#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname $0)"

docker compose down -v
rm -rf harmony/party-a/stores harmony/party-b/stores
rm certs/*.p12 certs/*.cer certs/*.csr
