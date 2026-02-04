# Magento 2 Advanced Installation Runbook - Site: aumcomm

## 1. Overview & Pre-requisites
**Target Environment:**
- **OS**: Ubuntu 24.04 (Linux)
- **Web Server**: Nginx 1.28 (Native)
- **Database**: MariaDB 11.4 (Native)
- **PHP**: PHP 8.4 (Native)
- **Services (Docker)**: Valkey, OpenSearch, RabbitMQ (Running via existing `container-apps/`)
- **Site Name**: `aumcomm`
- **Domain**: `aumcomm.cloudodin.space` (Assumed for local/VM)
- **Helper Scripts**: `new-site-setup.sh` (OS/Nginx/PHP), `db-setup.sh` (Database)

> [!IMPORTANT]
> This guide follows the [Adobe Commerce Advanced Installation](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/advanced) flow, automated where possible by local scripts.

## 2. Operating System & Web Server Preparation

### 2.1 Run Site Setup Script
Use the `new-site-setup.sh` script to create the system user, configure PHP-FPM, and set up Nginx virtual hosts.

**Pre-requisites:**
Ensure `/backup/default_fpm_pool.conf` and `/backup/default_nginx.conf` exist.

```bash
cd /home/abhishek/terrificminds/magento-248-setup
chmod +x new-site-setup.sh
./new-site-setup.sh
```

**Interactive Prompts:**
- **Username**: Enter `aumcomm`

**What this does:**
- Creates system user `aumcomm`.
- Configures PHP 8.4 FPM pool: `/etc/php/8.4/fpm/pool.d/aumcomm.conf`.
- Configures Nginx site: `/etc/nginx/conf.d/aumcomm.conf`.
- Creates web root: `/var/www/aumcomm` (linked to `/home/aumcomm/public_html`).
- Sets permissions and sudoers privileges.

### 2.2 Verify Nginx
The script reloads services, but verify the configuration:

```bash
sudo nginx -t
sudo systemctl status nginx
```

## 3. Infrastructure Services (Docker)
Ensure the shared infrastructure services are running.

```bash
# Start Valkey (Aumcomm specific)
cd /home/abhishek/terrificminds/magento-248-setup/container-apps/valkey-aumcomm && docker compose up -d

# Start Shared Services (OpenSearch, RabbitMQ)
cd /home/abhishek/terrificminds/magento-248-setup/container-apps/opensearch && docker compose up -d
cd /home/abhishek/terrificminds/magento-248-setup/container-apps/rabbitmq && docker compose up -d
```

> [!NOTE]
> - **OpenSearch**: Port `9200`
> - **RabbitMQ**: Port `5672`
> - **Valkey**: Port `6376` (from `valkey-aumcomm`)

## 4. Database Setup (MariaDB)
Use the `db-setup.sh` script to create the database and user.

```bash
cd /home/abhishek/terrificminds/magento-248-setup
chmod +x db-setup.sh
./db-setup.sh
```

**Interactive Prompts:**
- **Username**: Enter `aumcomm` (Creating DB `aumcomm` and User `aumcomm`)
- **Password**: Set a secure password (e.g., `aumcomm_password`)

## 5. Magento Codebase Installation (Composer)

### 5.1 Configure Authentication
As the `aumcomm` user, configure your Magento keys.

```bash
su - aumcomm

# Create auth.json
mkdir -p ~/.composer
cat > ~/.composer/auth.json <<EOF
{
    "http-basic": {
        "repo.magento.com": {
            "username": "<YOUR_PUBLIC_KEY>",
            "password": "<YOUR_PRIVATE_KEY>"
        }
    }
}
EOF
chmod 600 ~/.composer/auth.json
```

### 5.2 Create Project
Install Magento into the directory created by the setup script.

```bash
cd /var/www/aumcomm

# Create project
# Check for 'public_html' nesting if the script created it.
# Script creates /var/www/aumcomm -> /home/aumcomm/public_html
# So we are in the web root.
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .
```

## 6. PHP Configuration Check
Ensure `php.ini` limits are sufficient.

```bash
php -i | grep memory_limit
```

## 7. Magento Installation
Execute the CLI installation command from the `aumcomm` user.

**Run as `aumcomm` user:**
```bash
cd /var/www/aumcomm

bin/magento setup:install \
--base-url="http://aumcomm.cloudodin.space/" \
--db-host="localhost" \
--db-name="aumcomm" \
--db-user="aumcomm" \
--db-password="aumcomm_password" \
--admin-firstname="Admin" \
--admin-lastname="User" \
--admin-email="admin@example.com" \
--admin-user="admin" \
--admin-password="StrongPassword123" \
--language="en_AU" \
--currency="AUD" \
--timezone="Pacific/Auckland" \
--use-rewrites=1 \
--search-engine=opensearch \
--opensearch-host=localhost \
--opensearch-port=9200 \
--opensearch-index-prefix=aumcomm \
--cache-backend=redis \
--cache-backend-redis-server=localhost \
--cache-backend-redis-port=6376 \
--cache-backend-redis-db=1 \
--page-cache=redis \
--page-cache-redis-server=localhost \
--page-cache-redis-port=6376 \
--page-cache-redis-db=2 \
--session-save=redis \
--session-save-redis-host=localhost \
--session-save-redis-port=6376 \
--session-save-redis-db=0 \
--session-save-redis-disable-locking=1
--amqp-host=localhost \
--amqp-virtualhost=aumcomm
--amqp-port=5672 \
--amqp-user=guest \
--amqp-password=guest
```

## 8. Post-Installation Steps

### 8.1 Set Deployment Mode
```bash
bin/magento deploy:mode:set production
```

### 8.2 Configure Cron Jobs
```bash
bin/magento cron:install
```

### 8.3 Verify Permissions (Optional, script handles most)
```bash
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chmod u+x bin/magento
```

## 9. Verification
- Access `http://aumcomm.cloudodin.space/`
- Access Admin: `http://aumcomm.cloudodin.space/admin`
