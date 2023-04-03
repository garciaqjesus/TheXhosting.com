# Automated Data Backup Script (FTP) 

This script automates the process of creating a compressed tar.gz archive of your data from a VPS or dedicated server, and securely sending it to a remote FTP server for backup purposes, providing an efficient and reliable backup solution for your important data.

## How to

1.First, copy the backup_client.sh script to the machine where you want to run it. 
To download it use:

```bash
  wget https://github.com/garciaqjesus/TheXhosting.com/blob/main/Servers/Backups/backup_client.sh
```

2. Make sure the script is executable. You can do this with the following command:

```bash
  chmod +x backup_client.sh
```

3. Edit the script's information as needed.

```bash
  nano thexhosting.sh
```

4. To verify that the script is functioning properly, run the "backup_client.sh" command.

```bash
  ./backup_client.sh
```

5. Once you have confirmed that the script works, you can set up the cron job to run it automatically every day. 
To do this, open the crontab file using the following command:

```bash
  crontab -e
```

6. Add the following line to the crontab file:

```bash
  Every day -> 0 0 * * * /bin/bash /path/to/backup_client.sh
  Every 2 days -> 0 */48 * * * /bin/bash /path/to/backup_client.sh
  Every 3 days -> 0 0 */3 * * /bin/bash /path/to/backup_client.sh
  Every 7 days -> 0 0 */7 * * /bin/bash /path/to/backup_client.sh
  Every 15 days -> 0 0 */15 * * /bin/bash /path/to/backup_client.sh
```

7. You will need to modify the "/path/to/backup_client.sh" part of the cron job entry to reflect the actual path to the "backup_client.sh" script on your system.

For example, if the script is located in the "/home/user/scripts" directory, the cron job entry would look like this:

```bash
  0 0 * * * /bin/bash /home/user/scripts/backup_client.sh
```

The "/bin/bash" part of the cron job entry specifies the location of the bash executable, which should be left unchanged.

