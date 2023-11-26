#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root user, Permission denied"
    exit 1
fi

# Uninstall node exporter 
if [ "$1" == "--uninstall" ] || [ "$1" == "-u" ]; then
    # Stop and remove the Prometheus service
    sudo systemctl stop node-exporter.service
    sudo systemctl disable node-exporter.service
    sudo rm /etc/systemd/system/node-exporter.service
    sudo systemctl daemon-reload

    # Remove node_exporter installation
    sudo rm /usr/local/bin/node_exporter
    echo "Uninstallation complete."
    exit 0
fi

# Specify the GitHub repository and retrieve the latest release version
repo="prometheus/node_exporter"
latest_version=$(curl -sI https://github.com/$repo/releases/latest | grep -i "location" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')

# Check if the version retrieval was successful
if [ -z "$latest_version" ]; then
    echo "Failed to retrieve the latest version from GitHub. Exiting."
    exit 1
fi

# Set up user and download latest release
sudo useradd --no-create-home node_exporter

wget "https://github.com/$repo/releases/download/v$latest_version/node_exporter-$latest_version.linux-amd64.tar.gz"
tar xzf "node_exporter-$latest_version.linux-amd64.tar.gz"

# Check if the file exists and remove it if it does
if [ -f "/usr/local/bin/node_exporter" ]; then
    sudo rm -f "/usr/local/bin/node_exporter"
fi

# Install node_exporter
sudo cp "node_exporter-$latest_version.linux-amd64/node_exporter" /usr/local/bin/node_exporter

# Clean up downloaded files
rm -rf "node_exporter-$latest_version.linux-amd64.tar.gz" "node_exporter-$latest_version.linux-amd64"

# Copy systemd service file
sudo cat <<EFO | sudo tee /etc/systemd/system/node-exporter.service
[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EFO
# Reload systemd, enable, start, and check status
sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter --no-pager
