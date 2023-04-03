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


# Variables
ftp_server="YOUR_FTP_IP_ADDRESS"
ftp_user="YOUR_FTP_USERNAME"
ftp_password="YOUR_FTP_PASSWORD"
folder_path="/path/to/folder/to/backup"
backup_name="backup-$(date +%d-%m-%Y).tar.gz"

# Create backup
tar -czvf "$backup_name" "$folder_path"

# Upload file to FTP server
ftp -n $ftp_server <<END_SCRIPT
quote USER $ftp_user
quote PASS $ftp_password
put $backup_name
quit
END_SCRIPT

# Remove backup file
rm "$backup_name"