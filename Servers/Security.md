# SECURITY

The information stored in our servers is very important and needs to be protected from hackers and other individuals who may want to steal the data. To accomplish this, we have compiled some recommendations that can be very helpful in securing our servers.

## CHANGE THE PORT FROM SSH

By default, SSH uses port 22, which is often the first port that attackers will target. To mitigate this risk, we recommend changing the default SSH port to a different port.

To change the default SSH port in Ubuntu, follow these steps:

1. Log in to your Ubuntu server as the root user or a user with sudo privileges.

2. Open the SSH configuration file using a text editor. The file is located at /etc/ssh/sshd_config.

```bash
  sudo nano /etc/ssh/sshd_config
```
3. Find the line that specifies the SSH port, which is usually commented out with a '#'.

```bash
  # Port 22
```

4. Uncomment the line and change the port number to a different port of your choice. For example, you can change it to port 5412:

```bash
  Port 5412
```

5. Save the changes to the file and exit the editor.

6. Restart the SSH service for the changes to take effect:

```bash
  sudo systemctl restart sshd
```

7. Verify that the SSH service is running on the new port by attempting to connect to the server using the new port number:

```bash
  ssh username@server_ip_address:5412
```
OR
```bash
  ssh username@server_ip_address -p 5412
```    

## FAIL2BAN

Fail2ban is a software that helps protect servers from brute-force attacks and other malicious activities by monitoring log files and taking action against IP addresses that show malicious behavior. It does this by automatically blocking IP addresses that violate rules specified in its configuration file, typically after detecting a specified number of failed login attempts from the same IP address. This can help improve server security by reducing the risk of unauthorized access and minimizing the impact of malicious activities.

To install Fail2ban on Ubuntu, follow these steps:

1. Update your system's package index:

```bash
  sudo apt update
```    

2. Install Fail2ban using the following command:

```bash
  sudo apt install fail2ban
``` 

3. Once the installation is complete, copy the Fail2ban configuration file to a custom file to avoid overwriting the original configuration:

```bash
  sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
``` 

4. Open the Fail2ban configuration file in your preferred text editor:

```bash
  sudo nano /etc/fail2ban/jail.local
``` 

5. Configure Fail2ban rules according to your needs. You can enable and disable different security rules for different services like SSH, Apache, Nginx, etc.

6. Save and close the Fail2ban configuration file.

7. Start the Fail2ban service:

```bash
  sudo systemctl start fail2ban
``` 

8. Ensure that the Fail2ban service starts automatically at system boot:

```bash
  sudo systemctl enable fail2ban
```

⚠️ EXTRA

Dont forget that we have changed the port default from SSH so we have to change it also in the config of FAIL2BAN, for that follow this steps:

1. Open the Fail2ban configuration file with a text editor:

```bash
  sudo nano /etc/fail2ban/jail.conf
```

2. Find the section that begins with [sshd], which contains settings for the SSH server.

3. Update the port setting to match the new SSH port number. In this case, change port = ssh to port = 3451.

```bash
  [sshd]

  port    = ssh
  ...
```
IF YOUR PORT IS 3451, CHANGE IT TO: 

```bash
  [sshd]

  port    = 3451
  ...
```

4. Save and close the file.

5. Restart the Fail2ban service to apply the changes:
```bash
  sudo systemctl restart fail2ban
```


