#!/bin/bash

# Set architecture and platform
ARCH="amd64"
PLATFORM="$(uname -s)_$ARCH"

echo "Downloading eksctl for $PLATFORM..."

# Download eksctl tarball
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

# Verify checksum
echo "Verifying checksum..."
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" \
  | grep "$PLATFORM" \
  | sha256sum --check || {
    echo "❌ Checksum verification failed!"
    exit 1
  }

# Extract and install
echo "Extracting and installing eksctl..."
tar -xzf eksctl_"${PLATFORM}".tar.gz -C /tmp && rm eksctl_"${PLATFORM}".tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

# Confirm installation
echo "✅ eksctl version installed:"
eksctl version