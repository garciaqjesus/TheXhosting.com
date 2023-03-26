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
  ssh username@server_ip_address:2222
```
OR
```bash
  ssh username@server_ip_address -p 2222
```    