#!/bin/bash

set -e  # Exit on error

# Configurable variables
VERSION="1.33.0"
RELEASE_DATE="2025-05-01"
ARCH="amd64"
OS="linux"
BIN_PATH="/usr/local/bin"
DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/${VERSION}/${RELEASE_DATE}/bin/${OS}/${ARCH}/kubectl"
TMP_FILE="./kubectl"

echo "📥 Downloading kubectl v$VERSION for $OS/$ARCH..."
curl -O "$DOWNLOAD_URL"

echo "🔧 Setting executable permission..."
chmod +x "$TMP_FILE"

echo "📦 Moving kubectl to $BIN_PATH..."
sudo mv "$TMP_FILE" "$BIN_PATH/kubectl"

echo "✅ kubectl installed. Verifying version:"
kubectl version --client