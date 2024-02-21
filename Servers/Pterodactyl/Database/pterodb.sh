#!/bin/bash

# Update the MySQL/MariaDB configuration file and restart the service
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf && service mariadb restart

systemctl restart mysql

systemctl restart mariadb

# Function to generate a random string of specified length
generate_random_string() {
    length=$1
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c $length
}

# Generate a random username for Pterodactyl
pterodactyl_user="pterodactyl-user-$(generate_random_string 10)"

# Generate a random 50-character password
password=$(generate_random_string 50)

# MySQL command to create the user and grant privileges
mysql_command="create user '${pterodactyl_user}'@'%' identified by '${password}'; grant all privileges on *.* to '${pterodactyl_user}'@'%' with grant option; flush privileges;"

# Print detailed information
echo "======================"
echo "USERNAME: ${pterodactyl_user}"
echo "PASSWORD: ${password}"
echo "======================"
echo "USERNAME AND PASSWORD CREATED. ADD THIS TO YOUR PTERODACTYL."

# Create the mysql-data.txt file and save the information
echo -e "======================\nUSERNAME: ${pterodactyl_user}\nPASSWORD: ${password}\n======================" > mysql-data.txt

echo "MySQL data has been saved to mysql-data.txt."