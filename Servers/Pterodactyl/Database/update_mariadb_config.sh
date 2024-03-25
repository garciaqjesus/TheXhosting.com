#!/bin/bash

# Define the configuration file path
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

# Check if the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi

# Backup the original configuration file
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"

# Change character-set-collations to utf8mb4=utf8mb4_general_ci
sed -i 's/\[mysqld\]/\[mysqld\]\ncollation-server = utf8mb4_general_ci\ncharacter-set-server = utf8mb4/' "$CONFIG_FILE"

# Restart MariaDB
systemctl restart mariadb

echo "Configuration updated and MariaDB restarted successfully."