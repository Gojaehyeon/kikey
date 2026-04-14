#!/usr/bin/env bash
# Create a stable self-signed code-signing identity ("Kikey Local") in the
# login keychain so every locally-built Kikey.app gets the same signature.
# This makes macOS TCC (Input Monitoring permission) persist across rebuilds
# instead of re-prompting after every build.
#
# Idempotent: re-running is a no-op if the identity already exists.
set -euo pipefail

IDENTITY="Kikey Local"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-identity -v -p codesigning "$KEYCHAIN" | grep -q "$IDENTITY"; then
  echo "✓ Code signing identity '$IDENTITY' already exists."
  exit 0
fi

echo "==> Generating self-signed code signing cert '$IDENTITY'"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.cnf" <<EOF
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = codesign
[ dn ]
CN = $IDENTITY
[ codesign ]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:FALSE
subjectKeyIdentifier = hash
EOF

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$TMP/kikey.key" \
  -out    "$TMP/kikey.crt" \
  -days   3650 \
  -config "$TMP/cert.cnf"

openssl pkcs12 -export \
  -out "$TMP/kikey.p12" \
  -inkey "$TMP/kikey.key" \
  -in    "$TMP/kikey.crt" \
  -name "$IDENTITY" \
  -passout pass:kikey

echo "==> Importing into login keychain"
security import "$TMP/kikey.p12" \
  -k "$KEYCHAIN" \
  -P kikey \
  -T /usr/bin/codesign \
  -T /usr/bin/security

# Allow codesign to use the key without a password prompt
security set-key-partition-list \
  -S apple-tool:,apple:,codesign: \
  -s -k "" "$KEYCHAIN" >/dev/null 2>&1 || true

echo "✓ Identity installed."
security find-identity -v -p codesigning "$KEYCHAIN" | grep "$IDENTITY"
