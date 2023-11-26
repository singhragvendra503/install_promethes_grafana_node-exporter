#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root user, Permission denied"
    exit 1
fi

# Uninstall Grafana
if [ "$1" == "--uninstall" ] || [ "$1" == "-u" ]; then
    # Stop Grafana service
    sudo systemctl stop grafana-server

    # Uninstall Grafana package
    sudo apt-get remove --purge grafana -y

    # Clean up Grafana directories and files
    sudo rm -rf /etc/grafana /var/lib/grafana /usr/share/grafana /usr/sbin/grafana-server /usr/sbin/grafana-cli /usr/sbin/grafana-cli

    # Remove Grafana user if exists
    if id "grafana" &>/dev/null; then
        sudo userdel grafana
    fi

    echo "Uninstallation of Grafana completed."
    exit 0
fi

# Specify the Grafana repository and retrieve the latest release version
repo="grafana/grafana"
latest_version=$(curl -sI https://github.com/$repo/releases/latest | grep -i "location" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')

# Check if the version retrieval was successful
if [ -z "$latest_version" ]; then
    echo "Failed to retrieve the latest version from GitHub. Exiting."
    exit 1
fi

# Install dependencies
sudo apt-get install -y adduser libfontconfig1 musl

# Download and install the latest Grafana release
wget "https://dl.grafana.com/oss/release/grafana_${latest_version}_amd64.deb"
sudo dpkg -i "grafana_${latest_version}_amd64.deb"

# Clean up downloaded files
rm -rf "grafana_${latest_version}_amd64.deb"

# Reload systemd, start Grafana, and check status
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service
sudo systemctl status grafana-server --no-pager


