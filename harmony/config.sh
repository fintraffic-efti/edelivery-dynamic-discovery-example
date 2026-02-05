#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

instance=$1
env_file="$instance/.env"

base64Path() {
  #OSX
  if [[ "$OSTYPE" == "darwin"* ]]; then
    base64 --break 0 < "$1"
  else
    base64 --wrap 0 < "$1"
  fi
}

rm -f "$env_file"
echo "PMODE_CONFIG_B64=""$(base64Path $instance/pmode.xml)""" >> "$env_file"
echo "SECURITY_KEYSTORE_B64=""$(base64Path $instance/stores/ap-keystore.p12)""" >> "$env_file"
echo "SECURITY_TRUSTSTORE_B64=""$(base64Path $instance/stores/ap-truststore.p12)""" >> "$env_file"
echo "TLS_KEYSTORE_B64=""$(base64Path $instance/stores/tls-keystore.p12)""" >> "$env_file"
echo "TLS_TRUSTSTORE_B64=""$(base64Path $instance/stores/tls-truststore.p12)""" >> "$env_file"
echo "EFTI_WSPLUGIN_PROPERTIES_BASE64=""$(base64Path $instance/wsplugin.properties)""" >> "$env_file"
