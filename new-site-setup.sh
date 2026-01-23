#!/bin/bash

# Prompt user for username
read -p "Enter the username: " username

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User '$username' already exists. Exiting."
    exit 1
fi

# Create user
sudo useradd -m -s /bin/bash "$username"

# Check if user creation was successful
if [ $? -eq 0 ]; then
    echo "User '$username' created successfully."
else
    echo "Failed to create user '$username'. Exiting."
    exit 1
fi


sudo cp /backup/default_fpm_pool.conf /etc/php/8.4/fpm/pool.d/$username.conf

sudo sed -i "s/unique_id/${username}/g" /etc/php/8.4/fpm/pool.d/$username.conf

sudo wget -q https://gist.githubusercontent.com/ApostateDevOps/2490db9aa6d11efacb67815974bc5e82/raw/b0f92350918ba72ff272236ebdb02b645c69b17f/nginx_site_proxy.conf -O /etc/nginx/sites-enabled/$username-proxy.conf

sudo sed -i "s/unique_id/${username}/g" /etc/nginx/sites-enabled/$username-proxy.conf

sudo cp /backup/default_nginx.conf /etc/nginx/sites-enabled/$username.conf

sudo sed -i "s/unique_id/${username}/g" /etc/nginx/sites-enabled/$username.conf


sudo mkdir /var/www/${username}
sudo ln -s /var/www/${username} /home/"$username"/public_html

sudo chown -R ${username}: /var/www/${username}
sudo chown -R ${username}: /home/"$username"/public_html

echo "Directory created under /home/$username/public_html."

sudo tee -a /etc/logrotate.d/${username} <<EOF
/var/www/${username}/public_html/shared/var/log/*.log {
    su ${username} ${username}
    rotate 30
    daily
    compress
    delaycompress
    missingok
    notifempty
    create 0664 ${username} ${username}
}
EOF

sudo tee -a /etc/sudoers.d/${username} <<EOF
%${username} ALL= NOPASSWD: /usr/bin/systemctl start php8.4-fpm
%${username} ALL= NOPASSWD: /usr/bin/systemctl reload php8.4-fpm
%${username} ALL= NOPASSWD: /usr/bin/systemctl restart php8.4-fpm
EOF


