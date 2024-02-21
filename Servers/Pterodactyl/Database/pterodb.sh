#!/bin/bash

# Update the MySQL/MariaDB configuration file and restart the service
config_file="/etc/mysql/mariadb.conf.d/50-server.cnf"

# Use sed with a backup file
sed -i.bak 's/127.0.0.1/0.0.0.0/g' "$config_file"

# Restart MariaDB service
systemctl restart mariadb

# Function to generate a random string of specified length
generate_random_string() {
    length=$1
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Generate a random username for Pterodactyl
pterodactyl_user="pterodactyl_user_$(generate_random_string 10)"

# Generate a random 50-character password
password=$(generate_random_string 50)

# MySQL command to create the user and grant privileges
mysql_command="CREATE USER '$pterodactyl_user'@'%' IDENTIFIED BY '$password'; GRANT ALL PRIVILEGES ON *.* TO '$pterodactyl_user'@'%'; FLUSH PRIVILEGES;"

# Execute MySQL command
mysql -u root -p <<EOF
$mysql_command
EOF

# Print detailed information
clear
echo "======================"
echo "USERNAME: $pterodactyl_user"
echo "PASSWORD: $password"
echo "======================"
echo "USERNAME AND PASSWORD CREATED. ADD THIS TO YOUR PTERODACTYL."

# Create the mysql-data.txt file and save the information
echo -e "======================\nUSERNAME: $pterodactyl_user\nPASSWORD: $password\n======================\nPlease subscribe to my YouTube channel: https://www.youtube.com/channel/UCzJH8mcKKVdLD1nLWs4CZZw" > mysql-data.txt

echo "MySQL data has been saved to mysql-data.txt."

# FUTURE UPDATE CHECK AUTOMATIC PASSWORD; 
# BEING ABLE TO CHECK ALL ACCOUNTS CREATED WITH THIS SCRIPT, AND ABLE TO DELET IT. 
