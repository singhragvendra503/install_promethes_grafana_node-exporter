# Monitoring Setup Scripts

This repository contains scripts for installing and uninstalling monitoring tools such as Grafana, Prometheus, and Node Exporter on an Ubuntu system.

## Clone Git repo
```
git clone https://github.com/singhragvendra503/install_promethes_grafana_node-exporter.git

cd install_promethes_grafana_node-exporter/
```
## Prometheus Installation
The `install_prometheus.sh` script facilitates the installation of Prometheus, retrieving the latest release from the Prometheus repository on GitHub.

To install Prometheus, execute the following command:
```
sudo bash install_prometheus.sh
```
To uninstall Prometheus, use:
```
sudo bash install_prometheus.sh --uninstall
```

## Grafana Installation
The `install_grafana.sh` script installs Grafana by fetching the latest release from the Grafana repository on GitHub.

To install Grafana, execute the following command:

```
sudo bash install_grafana.sh
```
To uninstall Grafana, use:
```
sudo bash install_grafana.sh --uninstall
```

## Node Exporter Installation
The `install_node_exporter.sh` script manages the installation of Node Exporter, fetching the latest release from the Node Exporter repository on GitHub.

To install Node Exporter, execute the following command:
```
sudo bash install_node_exporter.sh
```
To uninstall Node Exporter, use:
```
sudo bash install_node_exporter.sh --uninstall
```

## Important Notes
- Ensure you run these scripts with root privileges (sudo).
- Each installation script provides an option for uninstallation using the --uninstall or -u flag.
- Verify the status of the services after installation using their respective systemd status commands.
## Disclaimer
These scripts are provided as-is and should be used with caution. Always review and understand the code before executing scripts from external sources.

> [!NOTE]
> Please replace the commands with appropriate user permissions and verify paths before executing the scripts.
