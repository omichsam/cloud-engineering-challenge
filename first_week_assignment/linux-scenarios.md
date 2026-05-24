# Linux Scenarios

## File Management Scenarios

### 1. Moving a file to the right directory
You accidentally created a file in the wrong directory. How would you move it to `/home/ubuntu/projects`?

```bash
mv filename /home/ubuntu/projects
```

### 2. Creating multiple folders at once
Your team needs a folder structure for `logs`, `scripts`, and `backups`. How would you create all folders using one command?

```bash
mkdir logs scripts backups
```

### 3. Backing up and removing a large file
A backup file is consuming space. How would you locate it, copy it to a backup directory, and delete the original?

```bash
find / -name "backup-file" 2>/dev/null
cd path_to_file
cp backup-file /home/backups
rm backup-file
```

---

## File Viewing & Management Scenarios

### 4. Viewing and monitoring logs
A web application is failing. The logs are stored in `/var/log/app.log`. How would you view the latest logs and continuously monitor updates?

```bash
tail /var/log/app.log      # view the latest logs
tail -f /var/log/app.log   # continuously monitor new logs
```

### 5. Searching logs for errors
You suspect the application has database errors. How would you search the log file for `ERROR`?

```bash
grep "ERROR" /var/log/app.log
```

### 6. Scrolling through a large config file
A configuration file is very large. Which command would help you scroll through it page by page?

```bash
less filename
```

---

## Permissions & Ownership Scenarios

### 7. Fixing "Permission denied" on a script
A deployment script `deploy.sh` fails with `Permission denied`. How would you fix it?

The file does not have execute permission. Add execute permission and run it:

```bash
chmod +x deploy.sh
./deploy.sh
```

### 8. Owner-only permissions
You want only the owner to read, write, and execute a file. Which permission number would you use?

```bash
chmod 700 file_name
```

### 9. Changing file ownership
A file belongs to the wrong user. How would you change ownership to `ubuntu`?

```bash
chown ubuntu file_name
```

### 10. Why world-writable files are dangerous
You accidentally gave everyone write access to a sensitive file. Why is this dangerous?

It is dangerous since anyone can modify the file, which could lead to data being tampered with or changed. This can lead to mistakes or intentional changes that break the trust and integrity of the file.

---

## Process Management Scenarios

### 11. Finding a high-CPU process
A Python application is consuming 95% CPU. Which commands would help you identify the process?

```bash
top         # or htop
ps aux | grep python
```

### 12. Stopping a background process
A background process named `sleep` is still running. How would you stop it?

```bash
ps aux | grep sleep
kill <PID>        # normal stop
kill -9 <PID>     # force stop
pkill sleep       # by name
```

### 13. Why check running processes?
Your server becomes slow. Why is checking running processes important?

It is important because it shows what programs are running and helps you find what is making the server slow (i.e. what is consuming memory or resources) so that you can identify and stop those programs.

### 14. Viewing background jobs
You started a process accidentally in the background. How would you view background jobs?

```bash
jobs
```

---

## Networking & Connectivity Scenarios

### 15. Testing internet connectivity
A student cannot connect to the internet from the Linux VM. Which command would you use first to test connectivity?

```bash
ping google.com
```

### 16. Finding your server's IP address
You need to know the IP address of your Linux server. Which command would you use?

```bash
hostname -I
ip a
```

### 17. Checking if a web server is listening on port 80
A web server should be listening on port 80. Which command helps confirm this?

```bash
ss -tuln | grep :80
netstat -tuln | grep :80
```

### 18. Troubleshooting DNS
A website domain is not resolving correctly. Which commands can help troubleshoot DNS?

```bash
dig domain.com
nslookup domain.com
```

---

## SSH & Remote Access Scenarios

### 19. Remotely managing a Linux server
You need to remotely manage a Linux server from Windows. Which command would you use?

Using the secure shell command `ssh`:

```bash
ssh username@ipaddress
```

### 20. Securely transferring a file to a remote server
You need to securely transfer `backup.tar.gz` from your local machine to a remote Linux server. Which command would you use?

Using the secure copy command `scp`:

```bash
scp source_path destination_path
```

---

## Bonus Challenge Questions

### 21. Why is Linux heavily used in cloud computing and DevOps?
- It is stable, fast, and reliable for running servers even under heavy use.
- It has easy automation that helps teams deploy and manage applications quickly across many machines.

### 22. Difference between `chmod 755` and `chmod 644`
- **`chmod 755`** — The owner has full permissions (read, write, execute), while the group and others have read and execute permissions.
- **`chmod 644`** — The owner has read and write permissions, while the group and others have read-only permission.

### 23. Why is `chmod +x script.sh` important before running scripts?
It makes the file (`script.sh`) executable, i.e. the system is allowed to run the program.

### 24. Why is SSH considered more secure than older remote access methods?
SSH completely encrypts all data transmission, preventing passwords and commands from being intercepted in plain text.

### 25. Why is process management important in Docker and Kubernetes environments?
It ensures system reliability, automated recovery, and efficient resource allocation.
