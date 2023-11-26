#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root user, Permission denied"
    exit 1
fi

# Uninstall node prometheus
if [ "$1" == "--uninstall" ] || [ "$1" == "-u" ]; then
    # Stop and remove the Prometheus service
    sudo systemctl stop prometheus.service
    sudo systemctl disable prometheus.service
    sudo rm /etc/systemd/system/prometheus.service
    sudo systemctl daemon-reload

    # Remove node_exporter installation
    sudo rm -r -f /usr/local/bin/prometheus /etc/prometheus
    echo "Uninstallation complete."
    exit 0
fi

# Specify the Prometheus repository and retrieve the latest release version
repo="prometheus/prometheus"
latest_version=$(curl -sI https://github.com/$repo/releases/latest | grep -i "location" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')

# Check if the version retrieval was successful
if [ -z "$latest_version" ]; then
    echo "Failed to retrieve the latest version from GitHub. Exiting."
    exit 1
fi

#  Show the system name
system_name=$(uname -s)
# Create Prometheus user and directories
sudo useradd --no-create-home prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Download and install the latest Prometheus release
wget "https://github.com/$repo/releases/download/v$latest_version/prometheus-$latest_version.linux-amd64.tar.gz"
tar -xvf "prometheus-$latest_version.linux-amd64.tar.gz"

# Check if the file exists and remove it if it does
if [ -f "/usr/local/bin/prometheus" ]; then
    sudo rm -f "/usr/local/bin/prometheus"
fi

sudo cp "prometheus-$latest_version.linux-amd64/prometheus" /usr/local/bin
sudo cp "prometheus-$latest_version.linux-amd64/promtool" /usr/local/bin
sudo cp -r "prometheus-$latest_version.linux-amd64/consoles" /etc/prometheus/
sudo cp -r "prometheus-$latest_version.linux-amd64/console_libraries" /etc/prometheus
sudo cp "prometheus-$latest_version.linux-amd64/promtool" /usr/local/bin/

# Clean up downloaded files
rm -rf "prometheus-$latest_version.linux-amd64.tar.gz" "prometheus-$latest_version.linux-amd64"

# Copy Prometheus configuration and systemd service file
sudo cat <<EOF | tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

sudo cat <<EFO | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EFO
# Set permissions
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Reload systemd, enable Prometheus, start, and check status
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus --no-pager
