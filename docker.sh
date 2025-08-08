#!/bin/bash

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

growpart /dev/nvme0n1 4
lvextend -L +20G /dev/RootVG/rootVol
lvextend -L +10G /dev/RootVG/varVol

xfs_growfs /
xfs_growfs /var


# eks install 

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
eksctl versio

### kublet 

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