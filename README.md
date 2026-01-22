# Magento 2.4.8 Infrastructure Setup

This repository contains shell scripts and Docker Compose configurations to set up a high-performance infrastructure for **Magento 2.4.8** on **Ubuntu 24.04 LTS**.

## 🚀 Installation Scripts

These scripts are designed to be run on a fresh Ubuntu 24.04 instance. They automate the installation and configuration of the core stack components.

| Script | Description |
| :--- | :--- |
| `install-docker.sh` | **Docker Engine**: Installs the latest Docker Engine (Communtiy Edition) and Docker Compose plugin from the official Docker repositories. Cleans up conflicting packages and verifies the installation. |
| `nginx-install.sh` | **Nginx Web Server**: Installs the latest stable Nginx from the official Nginx packages. Sets up the repo, signing keys, and validates the service status. |
| `php84-install.sh` | **PHP 8.4**: Installs PHP 8.4 (Development version) via the `ondrej/php` PPA. Includes essential extensions for Magento (bcmath, ctype, curl, dom, gd, iconv, intl, mbstring, mysql, soap, xml, xsl, zip, sockets, amqp, redis, etc.) and applies `php.ini` performance tuning. |
| `varnish77-install.sh` | **Varnish Cache 7.7**: Installs Varnish Cache 7.7 (Magento 2.4.x compatible) from the PackageCloud repository. Configures the service to run on boot. |
| `mariadb-install.sh` | **MariaDB 11.4 LTS**: Installs MariaDB 11.4 Server and Client from the official MariaDB repository. Sets up signing keys and ensures the service is running. |

---

## ☁️ Cloud-Init User Data

### `dev-user-data.sh`
This script is intended for use as **Cloud-Init User Data** when launching a new cloud instance (e.g., AWS EC2, Azure VM).

**What it does:**
1.  **Bootstrap**: Runs automatically on the first boot.
2.  **Download**: Fetches all the above individual installer scripts from this repository (via raw GitHub URLs).
3.  **Execute**: Runs them sequentially: Docker -> Nginx -> PHP -> Varnish.
4.  **Log**: Captures all output to `/var/log/user-data.log` for debugging.

> [!IMPORTANT]
> Before using, ensure the URLs in the script point to your specific repository branch/commit if necessary.

---

## 🐳 Containerized Services

Supporting services are managed via `docker-compose` to keep the host system clean and allow for easy version management.

Located in `container-apps/`:

### RabbitMQ
**Path**: `container-apps/rabbitmq/docker-compose.yml`
- **Service**: RabbitMQ 3.13
- **Usage**: Message queue for Magento asynchronous operations.
- **Access**:
    - AMQP Port: `5672`
    - Management UI: `http://<server-ip>:15672` (User/Pass: `guest`/`guest`)

### OpenSearch
**Path**: `container-apps/opensearch/docker-compose.yml`
- **Service**: OpenSearch 3.x Cluster (2 Nodes) + Dashboards
- **Usage**: Search engine for Magento Catalog Search.
- **Configuration**:
    - Disables security plugin (for dev/internal use).
    - Sets appropriate JVM heap sizes (`512m`).
    - Configures `ulimits` for performance.
- **Access**:
    - API: `9200`
    - Dashboards: `5601`

### Valkey (Redis Alternative)
**Path**: `container-apps/valkey/docker-compose.yml`
- **Service**: Valkey 8 (High-performance Redis fork)
- **Usage**: Redis/Cache instances for different Magento cache segments or multi-store setups (e.g., `shoeconz`, `shoecoau`, `novonz`, etc.).
- **Configuration**:
    - Multiple isolated instances on different ports (`6371` - `6375`).
    - Memory limits configured for each instance.