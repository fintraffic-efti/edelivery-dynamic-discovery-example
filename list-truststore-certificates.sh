#!/usr/bin/env bash
#
# List all certificates in truststores under dynamic-discovery-proto
#
# This script scans for all *-truststore.p12 files and displays:
# - Truststore file path
# - Certificate alias
# - Certificate owner (subject DN)
# - Certificate issuer DN
# - Validity period
# - Serial number
#
# Usage: ./list-truststore-certificates.sh
#
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail
cd "$(dirname $0)"
KEYSTORE_PASSWORD="store-pwd-123"
# Counters for summary
total_truststores=0
total_certificates=0
non_empty_truststores=0
echo "==================================================================="
echo "Certificate Listing for All Truststores"
echo "==================================================================="
echo ""
# Function to determine the password for a truststore
get_truststore_password() {
    local truststore_path="$1"
    local truststore_name=$(basename "$truststore_path")
    # Check if this is a harmony truststore
    if [[ "$truststore_path" == *"/harmony/"* ]]; then
        # Extract the party name (e.g., "party-a" or "party-b")
        local party=$(echo "$truststore_path" | sed 's|.*/harmony/\([^/]*\)/.*|\1|')
        # Determine truststore type (ap or tls)
        if [[ "$truststore_name" == "ap-truststore.p12" ]]; then
            echo "ap-truststore-$party"
        elif [[ "$truststore_name" == "tls-truststore.p12" ]]; then
            echo "tls-truststore-$party"
        else
            echo "$KEYSTORE_PASSWORD"
        fi
    else
        # For non-harmony truststores, use the default password
        echo "$KEYSTORE_PASSWORD"
    fi
}
# Function to list certificates in a truststore
list_truststore_certs() {
    local truststore_path="$1"
    local truststore_name=$(basename "$truststore_path")
    total_truststores=$((total_truststores + 1))
    if [ ! -f "$truststore_path" ]; then
        echo "WARNING: Truststore not found: $truststore_path"
        echo ""
        return
    fi
    echo "+-----------------------------------------------------------------"
    echo "| Truststore: $truststore_path"
    echo "+-----------------------------------------------------------------"
    # Get the appropriate password for this truststore
    local password=$(get_truststore_password "$truststore_path")
    # Get list of aliases
    local aliases=$(keytool -list -keystore "$truststore_path" -storepass "$password" 2>/dev/null | \
                    grep -E "^[a-zA-Z0-9_-]+," | \
                    cut -d',' -f1)
    if [ -z "$aliases" ]; then
        echo "  (empty - no certificates found)"
        echo ""
        return
    fi
    non_empty_truststores=$((non_empty_truststores + 1))
    # Iterate through each alias and display details
    local count=0
    for alias in $aliases; do
        count=$((count + 1))
        total_certificates=$((total_certificates + 1))
        # Get certificate details
        local cert_info=$(keytool -list -v -alias "$alias" -keystore "$truststore_path" -storepass "$password" 2>/dev/null)
        # Extract key information
        local owner=$(echo "$cert_info" | grep "Owner:" | sed 's/Owner: //' | head -1)
        local issuer=$(echo "$cert_info" | grep "Issuer:" | sed 's/Issuer: //' | head -1)
        local valid_from=$(echo "$cert_info" | grep "Valid from:" | sed 's/.*Valid from: //' | sed 's/ until:.*//')
        local valid_until=$(echo "$cert_info" | grep "Valid from:" | sed 's/.*until: //')
        local serial=$(echo "$cert_info" | grep "Serial number:" | sed 's/.*Serial number: //')
        echo ""
        echo "  [$count] Alias: $alias"
        echo "      Owner:  $owner"
        echo "      Issuer: $issuer"
        echo "      Valid:  $valid_from -> $valid_until"
        if [ ! -z "$serial" ]; then
            echo "      Serial: $serial"
        fi
    done
    echo ""
    echo "  Total certificates: $count"
    echo ""
}
# Find and list all truststores
echo "Scanning for truststores..."
echo ""
# List truststores in certs directory
if [ -d "./certs" ]; then
    for truststore in ./certs/*-truststore.p12; do
        if [ -f "$truststore" ]; then
            list_truststore_certs "$truststore"
        fi
    done
fi
# List truststores in harmony directories
if [ -d "./harmony" ]; then
    for harmony_dir in ./harmony/*/stores; do
        if [ -d "$harmony_dir" ]; then
            for truststore in "$harmony_dir"/*-truststore.p12; do
                if [ -f "$truststore" ]; then
                    list_truststore_certs "$truststore"
                fi
            done
        fi
    done
fi
echo "==================================================================="
echo "Summary"
echo "==================================================================="
echo "  Total truststores found:    $total_truststores"
echo "  Non-empty truststores:      $non_empty_truststores"
echo "  Total certificates:         $total_certificates"
echo "==================================================================="
