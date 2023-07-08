#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Disable password prompt for sudo for this user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null

# Update all packages and cache
sudo apt -y update && sudo apt -y upgrade

# Install VMWare Tools
sudo apt -y install open-vm-tools

# Install Docker
sudo apt-get -y install ca-certificates curl gnupg
# Add Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyring
sudo rm -rf /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
# Install the Docker package
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Add this user to the docker group
sudo usermod -aG docker $USER
# Launch Docker on startup
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Disable SSH password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Enable key-based authentication
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Remove packages that failed to isntall
sudo apt-get -y autoclean
# Remove APT cache
sudo apt-get -y clean
# Remove dependencies that are no longer needed
sudo apt-get -y autoremove

# Clean machine ID so the cloned VM gets a new IP with DHCP
sudo truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id

# Shutdown the VM so it can be exported
sudo -S shutdown -P now
