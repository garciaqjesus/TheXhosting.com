#!/bin/bash

# COLORS
GREEN="\033[1;32m";
RED='\033[0;31m'

BoldWhite='\033[1;37m'
BoldCyan='\033[1;36m'
NoColor='\033[0m'


# THEXHOSTING START
banner(){
    clear;
    echo -e "${GREEN}  _______ _    _ ________   ___    _  ____   _____ _______ _____ _   _  _____ ${NoColor}";
    echo -e "${GREEN} |__   __| |  | |  ____\ \ / / |  | |/ __ \ / ____|__   __|_   _| \ | |/ ____|${NoColor}";
    echo -e "${GREEN}    | |  | |__| | |__   \ V /| |__| | |  | | (___    | |    | | |  \| | |  __ ${NoColor}";
    echo -e "${GREEN}    | |  |  __  |  __|   > < |  __  | |  | |\___ \   | |    | | | .   | | |_ |${NoColor}";
    echo -e "${GREEN}    | |  | |  | | |____ / . \| |  | | |__| |____) |  | |   _| |_| |\  | |__| |${NoColor}";
    echo -e "${GREEN}    |_|  |_|  |_|______/_/ \_\_|  |_|\____/|_____/   |_|  |_____|_| \_|\_____|${NoColor}";
    echo -e "${BoldCyan}======================== CREATED BY THEXHOSTING ========================${NoColor}";
}

# Enter Maintenance Mode

cd /var/www/pterodactyl
php artisan down

# Download the Update

curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
chmod -R 755 storage/* bootstrap/cache

# Update Dependencies

composer install --no-dev --optimize-autoloader

# Clear Compiled Template Cache

php artisan view:clear
php artisan config:clear

# Database Updates
php artisan migrate --seed --force

# Set Permissions

chown -R www-data:www-data /var/www/pterodactyl/*

# Restarting Queue Workers

php artisan queue:restart

#Exit Maintenance Mode

php artisan up


