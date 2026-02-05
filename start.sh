#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

cd "$(dirname $0)"

CERTS_DIR="./certs"
KEYSTORE_PASSWORD="store-pwd-123"
VALIDITY_DAYS=3650
SMP_DB_ROOT_PWD=local-pwd-123

echo "Creating certificates directory..."
mkdir -p "${CERTS_DIR}"

# Function to generate SQL script for updating certificate
generate_ap_cert_update_sql() {
    local instance="$1"
    local cert_file="./harmony/$instance/stores/ap.pem"
    local placeholder="<!-- placeholder $instance ap cert -->"

    # Read the certificate file content
    local cert_content
    cert_content="$(cat "${cert_file}")"

    # Remove PEM BEGIN and END markers
    cert_content="$(echo "${cert_content}" | grep -v "^-----BEGIN CERTIFICATE-----$" | grep -v "^-----END CERTIFICATE-----$")"

    # Escape special characters for SQL
    # Replace backslashes first, then single quotes, then newlines
    cert_content="${cert_content//\\/\\\\}"
    cert_content="${cert_content//\'/\\\'}"
    cert_content="${cert_content//$'\n'/\\n}"

    # Generate the UPDATE statement
    cat <<EOF
UPDATE SMP_DOCUMENT_VERSION
SET DOCUMENT_CONTENT = REPLACE(DOCUMENT_CONTENT, '${placeholder}', '${cert_content}')
WHERE DOCUMENT_CONTENT LIKE '%${placeholder}%';
EOF
}

# Function to generate certificates
generate_certificates() {
    echo "Generating Root CA certificate..."
    # Root CA certificate (self-signed)
    if [ ! -f "${CERTS_DIR}/root-ca.p12" ]; then
        keytool -genkeypair \
            -alias root-ca \
            -keyalg RSA \
            -keysize 4096 \
            -validity ${VALIDITY_DAYS} \
            -dname "CN=SomeOrg Root CA,OU=Certificate Authority,O=SomeOrg,L=Helsinki,ST=Uusimaa,C=FI" \
            -keypass ${KEYSTORE_PASSWORD} \
            -keystore "${CERTS_DIR}/root-ca.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12 \
            -ext BasicConstraints:critical=ca:true \
            -ext KeyUsage:critical=keyCertSign,cRLSign

        # Export Root CA certificate
        keytool -exportcert \
            -alias root-ca \
            -keystore "${CERTS_DIR}/root-ca.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -file "${CERTS_DIR}/root-ca.cer"

        echo "Root CA certificate created and exported"
    fi

    echo "Generating SML server certificate..."
    # SML server certificate (for TLS)
    if [ ! -f "${CERTS_DIR}/sml-server.p12" ]; then
        # Generate key pair
        keytool -genkeypair \
            -alias sml-server \
            -keyalg RSA \
            -keysize 2048 \
            -validity ${VALIDITY_DAYS} \
            -dname "CN=sml,OU=eDelivery,O=SomeOrg,L=Helsinki,ST=Uusimaa,C=FI" \
            -keypass ${KEYSTORE_PASSWORD} \
            -keystore "${CERTS_DIR}/sml-server.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12

        # Generate certificate signing request
        keytool -certreq \
            -alias sml-server \
            -keystore "${CERTS_DIR}/sml-server.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -file "${CERTS_DIR}/sml-server.csr"

        # Sign with Root CA
        keytool -gencert \
            -alias root-ca \
            -keystore "${CERTS_DIR}/root-ca.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -infile "${CERTS_DIR}/sml-server.csr" \
            -outfile "${CERTS_DIR}/sml-server.cer" \
            -validity ${VALIDITY_DAYS} \
            -ext KeyUsage:critical=digitalSignature,keyEncipherment \
            -ext ExtendedKeyUsage=serverAuth,clientAuth

        # Import Root CA into SML keystore first
        # This is required so keytool can verify the certificate chain when importing the signed certificate
        keytool -importcert \
            -alias root-ca \
            -file "${CERTS_DIR}/root-ca.cer" \
            -keystore "${CERTS_DIR}/sml-server.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -noprompt

        # Import signed certificate (requires Root CA to be in keystore for chain validation)
        keytool -importcert \
            -alias sml-server \
            -file "${CERTS_DIR}/sml-server.cer" \
            -keystore "${CERTS_DIR}/sml-server.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -noprompt
    fi

    echo "Generating SMP client certificate..."
    # SMP client certificate (for mutual TLS authentication with SML)
    if [ ! -f "${CERTS_DIR}/smp-client.p12" ]; then
        # Generate key pair
        keytool -genkeypair \
            -alias smp-client \
            -keyalg RSA \
            -keysize 2048 \
            -validity ${VALIDITY_DAYS} \
            -dname "CN=smp-1,OU=eDelivery,O=SomeOrg,L=Helsinki,ST=Uusimaa,C=FI" \
            -keypass ${KEYSTORE_PASSWORD} \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12

        # Generate certificate signing request
        keytool -certreq \
            -alias smp-client \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -file "${CERTS_DIR}/smp-client.csr"

        # Sign with Root CA
        keytool -gencert \
            -alias root-ca \
            -keystore "${CERTS_DIR}/root-ca.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -infile "${CERTS_DIR}/smp-client.csr" \
            -outfile "${CERTS_DIR}/smp-client.cer" \
            -validity ${VALIDITY_DAYS} \
            -ext KeyUsage:critical=digitalSignature,keyEncipherment \
            -ext ExtendedKeyUsage=serverAuth,clientAuth

        # Import Root CA into SMP keystore first
        # This is required so keytool can verify the certificate chain when importing the signed certificate
        keytool -importcert \
            -alias root-ca \
            -file "${CERTS_DIR}/root-ca.cer" \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -noprompt

        # Import signed certificate (requires Root CA to be in keystore for chain validation)
        keytool -importcert \
            -alias smp-client \
            -file "${CERTS_DIR}/smp-client.cer" \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -noprompt

        # Generate SMP sign certificate key pair
        keytool -genkeypair \
            -alias smp-sign \
            -keyalg RSA \
            -keysize 2048 \
            -validity ${VALIDITY_DAYS} \
            -dname "CN=smp-1-sign,OU=eDelivery,O=SomeOrg,L=Helsinki,ST=Uusimaa,C=FI" \
            -keypass ${KEYSTORE_PASSWORD} \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12

        # Generate certificate signing request for sign cert
        keytool -certreq \
            -alias smp-sign \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -file "${CERTS_DIR}/smp-sign.csr"

        # Sign with Root CA
        keytool -gencert \
            -alias root-ca \
            -keystore "${CERTS_DIR}/root-ca.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -infile "${CERTS_DIR}/smp-sign.csr" \
            -outfile "${CERTS_DIR}/smp-sign.cer" \
            -validity ${VALIDITY_DAYS} \
            -ext KeyUsage:critical=digitalSignature \
            -ext ExtendedKeyUsage=serverAuth,clientAuth

        # Import signed sign certificate (Root CA already in keystore, so chain can be validated)
        keytool -importcert \
            -alias smp-sign \
            -file "${CERTS_DIR}/smp-sign.cer" \
            -keystore "${CERTS_DIR}/smp-client.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -noprompt
    fi

    echo "Creating SML truststore..."
    # SML truststore (trusts Root CA, which means it trusts all certificates signed by it)
    if [ ! -f "${CERTS_DIR}/sml-truststore.p12" ]; then
        keytool -importcert \
            -alias root-ca \
            -file "${CERTS_DIR}/root-ca.cer" \
            -keystore "${CERTS_DIR}/sml-truststore.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12 \
            -noprompt
    fi

    echo "Creating SMP truststore..."
    # SMP truststore (trusts Root CA, which means it trusts all certificates signed by it)
    if [ ! -f "${CERTS_DIR}/smp-truststore.p12" ]; then
        keytool -importcert \
            -alias root-ca \
            -file "${CERTS_DIR}/root-ca.cer" \
            -keystore "${CERTS_DIR}/smp-truststore.p12" \
            -storepass ${KEYSTORE_PASSWORD} \
            -storetype PKCS12 \
            -noprompt
    fi

    echo "Certificates and keystores created successfully!"
    echo "Root CA certificate: ${CERTS_DIR}/root-ca.cer"
    echo "Keystore password: ${KEYSTORE_PASSWORD}"
    echo ""
    echo "To trust all certificates, import the Root CA certificate into your truststore:"
    echo "  keytool -importcert -alias some-root-ca -file ${CERTS_DIR}/root-ca.cer -keystore /path/to/truststore"
}

# Generate certificates if they don't exist
if [ ! -f "${CERTS_DIR}/root-ca.p12" ] || \
   [ ! -f "${CERTS_DIR}/sml-server.p12" ] || \
   [ ! -f "${CERTS_DIR}/smp-client.p12" ] || \
   [ ! -f "${CERTS_DIR}/sml-truststore.p12" ] || \
   [ ! -f "${CERTS_DIR}/smp-truststore.p12" ]; then
    generate_certificates
else
    echo "Certificates already exist, skipping generation..."
fi

# Ensure git submodules are initialized and updated
git submodule update --init --recursive

./harmony-init-certs.sh ./certs/smp-sign.cer
./harmony/config.sh 'party-a'
./harmony/config.sh 'party-b'

echo "Checking if database initialization is needed..."

# Check and initialize SML database
if ! docker compose ps --format '{{.Service}}' | grep -q '^sml-db$'; then
    echo "Initializing SML database..."
    docker compose --profile init up --force-recreate sml-db-init
else
    echo "SML database already exists, skipping initialization..."
fi

# Check and initialize SMP database
if ! docker compose ps --format '{{.Service}}' | grep -q '^smp-db-1$'; then
    echo "Initializing SMP database..."
    docker compose --profile init up --force-recreate smp-db-init-1

    echo "Update actual harmony ap certificates to SMP db..."
    echo "$(generate_ap_cert_update_sql party-a)" | docker compose exec -T smp-db-1 mysql -u root -p$SMP_DB_ROOT_PWD harmony_smp
    echo "$(generate_ap_cert_update_sql party-b)" | docker compose exec -T smp-db-1 mysql -u root -p$SMP_DB_ROOT_PWD harmony_smp
else
    echo "SMP database already exists, skipping initialization..."
fi

echo "Starting services..."
docker compose up --build -d
