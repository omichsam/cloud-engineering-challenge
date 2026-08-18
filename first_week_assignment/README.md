# DevOps Practice — Linux Fundamentals

## Week summary

This week establishes the command-line foundation used by the later Docker, Kubernetes, and AWS projects. It covers file operations, permissions, processes, networking, SSH/SCP, logs, and a practical DevOps project walkthrough. Evidence images are stored in `images/`.

A collection of Linux exercises and hands-on labs completed as part of DevOps practice. Each markdown file documents the tasks, the commands used, and screenshots of the actual output from a Linux VM.

---

## Contents

### [linux-scenarios.md](./linux-scenarios.md)
Short-form Q&A covering 25 common Linux scenarios — file management, permissions, processes, networking, SSH, and bonus conceptual questions. Acts as a quick-reference cheat sheet for everyday Linux commands.

**Topics covered:**
- File management (`mv`, `mkdir`, `cp`, `rm`, `find`)
- File viewing (`tail`, `grep`, `less`)
- Permissions & ownership (`chmod`, `chown`)
- Process management (`ps`, `top`, `kill`, `jobs`)
- Networking (`ping`, `hostname`, `ss`, `dig`)
- SSH & SCP basics

---

### [devops-linux-assignment.md](./devops-linux-assignment.md)
A full hands-on assignment walking through a DevOps project setup from scratch, with screenshots for each step.

**Parts:**
1. File Management — building a project folder structure
2. File Viewing & Log Investigation
3. Permissions & Ownership
4. Process Management — background processes, monitoring tools (`htop`, `glances`)
5. Networking & Connectivity — IP discovery, port listening checks
6. SSH & SCP — remote EC2 access and file transfer
7. Disk & System Information
8. Compression & Backups (`tar`)

Includes a "Lessons Learned" section documenting typos, path mistakes, and tools that had to be installed along the way.

---

### [log-analysis-lab.md](./log-analysis-lab.md)
A focused lab on Linux text processing tools using a simulated `~/loglab/logs/` environment with `app.log`, `auth.log`, and `system.log` files.

**Parts:**
1. `find` — locating files by name or pattern
2. `locate` — fast filesystem search with database
3. `grep` — searching file contents for ERROR / WARNING entries
4. `awk` — extracting specific fields (timestamps, usernames, percentages)
5. Piping — chaining commands (`grep | awk | sort | uniq -c`)
6. `xargs` — turning file lists into command arguments

Ends with an **Advanced Challenge**: investigating an unstable server by combining all the tools to produce a system health summary.

---

### [images/](./images/)
Screenshots from the actual VM showing the output of each task. Image files are named to match the task numbers referenced in the markdown files (e.g. `task-01.png`, `adv-03.png`).

---


## Environment

These exercises were run on:
- **OS:** Ubuntu (Linux on VirtualBox)
- **Shell:** Bash
- **Extra tools installed during the work:** `htop`, `glances`, `net-tools`, `curl`

For the SSH/SCP tasks, an AWS EC2 Ubuntu instance was used as the remote target.

---

## Author

Documenting my NextGen DevOps program learning journey Linux command at a time.
