#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname "$0")"

# Check parameters
if [ $# -lt 2 ]; then
  echo "Usage: $0 <alias> <root-ca-cert-path> [root-ca-keystore-path] [root-ca-password]"
  echo "  alias: Identifier for the Harmony instance (e.g., party-a, party-b)"
  echo "  root-ca-cert-path: Path to the Root CA certificate file (e.g., ../certs/root-ca.cer)"
  echo "  root-ca-keystore-path: Path to the Root CA keystore (optional, defaults to root-ca.p12 in same dir as cert)"
  echo "  root-ca-password: Root CA keystore password (optional, defaults to 'store-pwd-123')"
  exit 1
fi

alias=$1
root_ca_cert="$(pwd)/$2"
root_ca_keystore="$(pwd)/$3"
root_ca_password=$4
expiration_days=3650
stores_directory="harmony/$alias/stores"

# Validate that the Root CA files exist
if [ ! -f "$root_ca_cert" ]; then
  echo "Error: Root CA certificate not found at: $root_ca_cert"
  exit 1
fi

if [ ! -f "$root_ca_keystore" ]; then
  echo "Error: Root CA keystore not found at: $root_ca_keystore"
  exit 1
fi

echo "Using Root CA certificate: $root_ca_cert"
echo "Using Root CA keystore: $root_ca_keystore"

if [ -d "$stores_directory" ]; then
  echo "Stores are already created in local-setup/local-harmony/$stores_directory"
  echo "Remove directory if you want to recreate."
  exit 0
fi

mkdir -p "$stores_directory"
cd "$stores_directory"

echo "Creating AP and TLS certificates signed by Root CA"

# Create AP certificate key and CSR
# NOTE: the sending harmony seems to get the receiver's party name from CN field in the certificate.
openssl req -sha256 -noenc -newkey rsa:4096 \
 -keyout ap.key -out ap.csr -subj "/C=FI/O=Fintraffic/OU=SomeOrg/CN=$alias"

# Sign AP certificate with Root CA using keytool (since Root CA is in a Java keystore)
keytool -gencert \
  -alias root-ca \
  -keystore "$root_ca_keystore" \
  -storepass "$root_ca_password" \
  -infile ap.csr \
  -outfile ap.crt \
  -validity $expiration_days \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment,dataEncipherment \
  -ext ExtendedKeyUsage=clientAuth,serverAuth

# Convert to PEM format (text-based)
openssl x509 -inform DER -in ap.crt -out ap.pem

# Create TLS certificate key and CSR
openssl req -sha256 -noenc -newkey rsa:4096 \
 -keyout tls.key -out tls.csr -subj "/C=FI/O=Fintraffic/OU=SomeOrg/CN=Local Harmony TLS ($alias)"

# Sign TLS certificate with Root CA using keytool
keytool -gencert \
  -alias root-ca \
  -keystore "$root_ca_keystore" \
  -storepass "$root_ca_password" \
  -infile tls.csr \
  -outfile tls.crt \
  -validity $expiration_days \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment,dataEncipherment \
  -ext ExtendedKeyUsage=clientAuth,serverAuth \
  -ext SubjectAlternativeName=DNS:harmony-$alias

echo "Exporting as p12"
# Create certificate chains that include the Root CA
cat ap.crt "$root_ca_cert" > ap-chain.crt
cat tls.crt "$root_ca_cert" > tls-chain.crt

# Export with full certificate chains
openssl pkcs12 -export -in ap-chain.crt -inkey ap.key -out ap.p12 -password pass:changeit
openssl pkcs12 -export -in tls-chain.crt -inkey tls.key -out tls.p12 -password pass:changeit

echo "Creating AP and TLS keystores"
keytool -importkeystore -noprompt \
  -srckeystore ap.p12 -srcstoretype PKCS12 -srcstorepass changeit -alias 1 \
  -destkeystore ap-keystore.p12 -deststorepass "ap-keystore-$alias" -destalias "$alias"
keytool -importkeystore -noprompt \
  -srckeystore tls.p12 -srcstoretype PKCS12 -srcstorepass changeit -alias 1 \
  -destkeystore tls-keystore.p12 -deststorepass "tls-keystore-$alias" -destalias "$alias"

echo "Creating AP and TLS truststores with Root CA"
# Create truststores and import Root CA certificate so they trust all certificates signed by it
keytool -importcert -noprompt \
  -alias root-ca \
  -file "$root_ca_cert" \
  -keystore ap-truststore.p12 \
  -storepass "ap-truststore-$alias"

keytool -importcert -noprompt \
  -alias root-ca \
  -file "$root_ca_cert" \
  -keystore tls-truststore.p12 \
  -storepass "tls-truststore-$alias"

echo "Cleaning up temporary files"
rm ./tls.p12 ./ap.p12
rm ./tls.csr ./ap.csr
rm ./ap-chain.crt ./tls-chain.crt
