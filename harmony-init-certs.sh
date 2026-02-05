#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname "$0")"
SMP_SIGN_CERT=$1

ROOT_CA_CERT=./certs/root-ca.cer
ROOT_CA_KEYSTORE=./certs/root-ca.p12
ROOT_CA_PASSWORD="store-pwd-123"

if [ ! -d "harmony/party-a/stores" ] || \
   [ ! -d "harmony/party-b/stores" ]; then
  echo "Generating Harmony certificates and stores..."

  ./harmony-create-stores.sh party-a "$ROOT_CA_CERT" "$ROOT_CA_KEYSTORE" "$ROOT_CA_PASSWORD"
  ./harmony-create-stores.sh party-b "$ROOT_CA_CERT" "$ROOT_CA_KEYSTORE" "$ROOT_CA_PASSWORD"

  ./harmony-trust-tls-cert.sh party-a some-root-ca "$ROOT_CA_CERT"
  ./harmony-trust-tls-cert.sh party-b some-root-ca "$ROOT_CA_CERT"
else
    echo "Harmony stores directories already exist, skipping generation."
fi
