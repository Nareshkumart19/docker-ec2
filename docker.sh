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

