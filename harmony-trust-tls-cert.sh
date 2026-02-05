#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname "$0")"

party=$1
alias=$2
cert=$3

party_a_truststore="harmony/$party/stores/tls-truststore.p12"
party_a_password="tls-truststore-$party"

keytool -delete -alias "$alias" -keystore "$party_a_truststore" -storepass "$party_a_password" || true

keytool -importcert -noprompt \
  -file "$cert" -keystore "$party_a_truststore" -alias "$alias" -storepass "$party_a_password"
