#!/usr/bin/env bash

set -o pipefail
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.

instance=$1

cd $(dirname $0)
cd "$instance/stores"

echo "Dumping stores for $instance"
echo

for name in "ap-keystore" "ap-truststore" "tls-keystore" "tls-truststore"; do
  echo "### dumping $name.p12"
  echo
  keytool --list -keystore "$name.p12" -v -storepass "$name-$instance"
done
