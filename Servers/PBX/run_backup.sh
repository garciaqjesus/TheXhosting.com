#!/bin/bash
#################################################################################
# Script Name   :- run_backup.sh                                                #
# Description   :- Take Backups                                                 #
# Created By    :-                                                              #
# Created Date  :-                                                              #
# Modified By   :-                                                              #
# Modified Date :-                                                              #
# Version       :- 0.1.2 - Final                                                #
# Comments      :-                                                              #                                                            #                                                                               #                                         
#################################################################################    

storage_directory=""
times_to_run=0

#check .env is available, if not exit the script
if [ ! -f /.env ]; then
    echo "Welcome! It seems like your first time using our script."
    echo "Run backup_restore.sh to set the configurations first."
    exit 0;

fi

# Load .env file
source /.env

#below function is used to delete the existing Cron Job
delete_cron(){
    path_pwd=$(pwd)
    path=$(echo ${path_pwd}"/" | tr -s '//' '/')
    existing_command="run_backup.sh"
    crontab -l | grep -v "$existing_command" | crontab -
}

# Check the call from cron, if yes check the remaining runs
if [ $# -eq 0 ]; then
    if [ "$times_to_run" -eq 0 ];then
        exit 0;
    fi
fi

bkp_location="${1:-$storage_directory}"
bkp_items="${2:-$backup_type}"

backup_timestamp=$(date "$date_format")
#echo "1 - $bkp_location | 2 - $bkp_items | t - $backup_timestamp"

# Create the backup location directory if it doesn't exist
mkdir -p "${bkp_location}"
chmod 777 "${bkp_location}"

# Loop through each backup item and take backup
for options in $bkp_items
do 
    temp_loc=$(echo "$options" | tr '[:upper:]' '[:lower:]')
    source_loc_var=${temp_loc}_location
    source_loc=${!source_loc_var}

    if [ "$temp_loc" != "mysql" ]; then

        if [ "$temp_loc" = "redis" ]; then
            if [ ! -f "$source_loc" ]; then
                echo "Error : Invalid Source file location : $source_loc"
                exit 0;
            fi
        else
            if [ ! -d "$source_loc" ]; then
                echo "Error : Invalid Source file location : $source_loc"
                exit 0;
            fi
        fi
        
		# Create a tarball backup for non-MySQL items
        tar -czvf "${bkp_location}"/"${options}"-backup-"${backup_timestamp}".tar.gz -P "$source_loc"
        if [ $? != 0 ]; then
            echo "Error : Taking the Bakup for $source_loc failed. Try Again after sometime."
            exit 0;
        else 
            echo -e "────────────────────────────────────────────────────────────────────────────────────────"
            echo "     Backup taken for $source_loc and Stored in below location: "
            echo "     ${bkp_location}/${options}-backup-${backup_timestamp}.tar.gz "
            echo -e "────────────────────────────────────────────────────────────────────────────────────────"
        fi
    else
        #echo "mysqldump -u "$db_user" -p"$db_pass" "$source_loc" > "${bkp_location}"/"${options}"-backup-"${backup_timestamp}".sql"
		# Create a SQL backup using mysqldump for MySQL items
        mysqldump -u "$db_user" -p"$db_pass" "$source_loc" > "${bkp_location}"/"${options}"-backup-"${backup_timestamp}".sql
        if [ $? != 0 ]; then
            echo "Error : Taking the Backup for $source_loc failed. Try Again after sometime."
                    exit 0;
        else 
            echo -e "────────────────────────────────────────────────────────────────────────────────────────"
            echo "     Backup taken for $source_loc and Stored in below location: "
            echo "     ${bkp_location}/${options}-backup-${backup_timestamp}.sql"
            echo -e "────────────────────────────────────────────────────────────────────────────────────────"
        fi
    fi
done

# Check the call from cron, if yes update the remaining runs
if [ $# -eq 0 ]; then
    if [ "$times_to_run" -gt 0 ];then
        times_to_run=$((times_to_run -1))
        if [ $times_to_run -eq 0 ];then
            sed -i "/backup_type=\".*\"/d" /.env
            sed -i "/schedule=\".*\"/d" /.env
            sed -i "/times_to_run=\".*\"/d" /.env
            sed -i "/interval=\".*\"/d" .env
            sed -i "/nofrun=\".*\"/d" .env
                                
            delete_cron
        else 
            sed -i "s|times_to_run=\".*\"|times_to_run=\"$times_to_run\"|" /.env
        fi
        sed -i "s|Auto_Last_Run_Tmst=\".*\"|Auto_Last_Run_Tmst=\"$(date)\"|" /.env
        
    fi
fi
