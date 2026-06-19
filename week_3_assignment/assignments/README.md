# Real-World DevOps Labs & Challenges

A collection of six production-style **bash automation scripts** covering server
recovery, deployment, monitoring, and infrastructure setup. Every script is
commented, passes `bash -n` syntax checks, and has a `CONFIG` block at the top
to adapt it to your environment.

> Each lab/challenge below includes a terminal screenshot of the script running.
> Lab 3 and Challenge 1 show **real captured output**; the others show a
> representative run (they need root/nginx/EC2/mail to execute on a live host).

---

## Contents

| # | File | Type | What it solves |
|---|------|------|----------------|
| 1 | `lab1-nginx-watchdog.sh` | Lab | Auto-recover nginx when it crashes |
| 2 | `lab2-deploy.sh` | Lab | One-command deploy with health check + rollback |
| 3 | `lab3-monitor.sh` | Lab | Disk / memory / CPU monitoring with logs |
| 4 | `challenge1-devops-menu.sh` | Challenge | Interactive menu-driven ops tool |
| 5 | `challenge2-onboard-users.sh` | Challenge | Bulk user creation + emailed credentials |
| 6 | `challenge3-ec2-setup.sh` | Challenge | Full EC2 provisioning from scratch |
| — | `users.txt` | Sample | Input file for Challenge 2 |

---

## Prerequisites

- A Linux host (Ubuntu/Debian or Amazon Linux/RHEL family).
- `bash`, `git`, `curl` available (the setup script installs git/curl for you).
- `root`/`sudo` for anything that touches services, users, or `/var/log`.
- Optional for notifications/email: `mailutils` or `ssmtp`, and/or a Slack
  Incoming Webhook URL.

## Install

```bash
unzip devops-labs.zip      # or copy the folder onto the server
cd devops-labs
chmod +x *.sh
```

---

## Lab 1 — Production Server Recovery

**Scenario:** nginx crashes at midnight. We need automation that *detects* the
failure, *restarts* the service, *logs* the incident, and *sends a
notification*.

**File:** `lab1-nginx-watchdog.sh`

**How it works:**
- Health is "up" only if `systemctl is-active nginx` succeeds **and** an HTTP
  request to `HEALTH_URL` returns success.
- On failure it restarts nginx, re-checks, and logs everything to
  `/var/log/nginx-watchdog.log`.
- It notifies via email (`NOTIFY_EMAIL`) and/or Slack (`SLACK_WEBHOOK`) — both
  optional.
- `--install` writes a **systemd service + timer** that runs the check every
  minute, so recovery happens unattended (including at midnight).

**Configure:** `HEALTH_URL`, `NOTIFY_EMAIL`, `SLACK_WEBHOOK`.

**Run:**
```bash
sudo ./lab1-nginx-watchdog.sh            # one check now
sudo ./lab1-nginx-watchdog.sh --install  # install the every-minute timer
systemctl status nginx-watchdog.timer    # verify it's active
```

**Screenshots**

![Lab 1 nginx watchdog run](screenshots/lab1.png)

---

## Lab 2 — DevOps Deployment Script

**Objective:** a single script that pulls the latest code from GitHub, restarts
the application, clears cache, and verifies service health.

**File:** `lab2-deploy.sh`

**How it works:**
1. Saves the current commit (for rollback).
2. `git fetch` + `git reset --hard origin/<branch>` for a clean, deterministic
   checkout.
3. Clears the configured cache directories.
4. Restarts the app via `RESTART_CMD`.
5. Polls `HEALTH_URL` up to `HEALTH_RETRIES` times. **If it never passes, it
   automatically rolls back** to the previous commit and restarts.

**Configure:** `APP_DIR`, `GIT_BRANCH`, `APP_SERVICE`/`RESTART_CMD`,
`CACHE_DIRS`, `HEALTH_URL`.

**Run:**
```bash
./lab2-deploy.sh
```
Logs to `/var/log/deploy.log`.

**Screenshots**

![Lab 2 deploy run](screenshots/lab2.png)

---

## Lab 3 — AWS EC2 Monitoring Automation

**Objective:** scripts that monitor disk, memory, and CPU and store logs in
`/var/log/monitoring`.

**File:** `lab3-monitor.sh`

**How it works:**
- **Disk** via `df`, **memory** via `/proc/meminfo`, **CPU** by sampling
  `/proc/stat` over one second.
- Each metric writes a timestamped line to `disk.log`, `memory.log`, or
  `cpu.log` under `/var/log/monitoring`, tagged `OK` or `ALERT` against its
  threshold.

**Configure:** `DISK_THRESHOLD`, `MEM_THRESHOLD`, `CPU_THRESHOLD`, `DISK_MOUNT`.

**Run:**
```bash
sudo ./lab3-monitor.sh all     # all three checks
sudo ./lab3-monitor.sh cpu     # just one (disk|mem|cpu)
sudo ./lab3-monitor.sh --cron  # prints a cron line for every-5-min runs
```

**Example run (real output):**

![Lab 3 monitoring run](screenshots/lab3.png)

---

## Challenge 1 — Menu-Driven DevOps Tool

**Goal:** an interactive menu built with `case`, loops, and functions:
1. Check CPU  2. Check RAM  3. Restart nginx  4. Backup logs  5. Exit

**File:** `challenge1-devops-menu.sh`

**How it works:** a `while true` loop prints the menu and a `case` statement
dispatches to one function per action. Log backups are written to
`/var/backups/logs/` as timestamped `.tar.gz` archives.

**Run:**
```bash
sudo ./challenge1-devops-menu.sh
```

**Example run (real output):**

![Challenge 1 menu run](screenshots/challenge1.png)

---

## Challenge 2 — Automated User Onboarding

**Goal:** read usernames from a file, create the users, generate random
passwords, and email the credentials.

**File:** `challenge2-onboard-users.sh`
**Input:** `users.txt` — one entry per line: `username  email` (`#` comments and
blank lines are ignored).

**How it works:**
- Skips users that already exist.
- Creates each user with a home dir and bash shell.
- Generates a 16-char random password (via `openssl`/`/dev/urandom`).
- Forces a password change at first login (`chage -d 0`).
- Emails credentials when `mail` is available; otherwise records them in the
  report log.

**Security note:** emailing plaintext passwords is convenient but not ideal —
the forced first-login change is the mitigation. Prefer SSH keys or a secrets
manager in production.

**Run:**
```bash
sudo ./challenge2-onboard-users.sh users.txt
```
Report: `/var/log/user-onboarding.log`.

**Screenshots**

![Challenge 2 onboarding run](screenshots/challenge2.png)

---

## Challenge 3 — Infrastructure Setup Automation

**Goal:** fully prepare a new EC2 instance — update packages, install Docker,
install nginx, configure the firewall, clone a GitHub repo, and deploy the app.

**File:** `challenge3-ec2-setup.sh`

**How it works:**
1. Detects the package manager (apt/dnf/yum) and updates the system.
2. Installs Docker (official convenience script) and enables it.
3. Installs and enables nginx.
4. Opens ports 22/80/443 via `ufw` or `firewalld`.
5. Clones (or pulls) the given repo into `/opt/app`.
6. Deploys: Docker Compose if a compose file exists -> else a `Dockerfile` build
   -> else serves the repo as a static nginx site.

**Run:**
```bash
sudo ./challenge3-ec2-setup.sh https://github.com/you/your-repo.git
```

**AWS note:** the script handles the host firewall, but your EC2 **Security
Group** is the real gate — open 80/443 there too.

**Screenshots**

![Challenge 3 EC2 setup run](screenshots/challenge3.png)

---

## Logs at a glance

| Script | Log location |
|--------|--------------|
| Lab 1 | `/var/log/nginx-watchdog.log` |
| Lab 2 | `/var/log/deploy.log` |
| Lab 3 | `/var/log/monitoring/{disk,memory,cpu}.log` |
| Challenge 1 | backups in `/var/backups/logs/` |
| Challenge 2 | `/var/log/user-onboarding.log` |

## General safety

- Read the `CONFIG` block of each script and adjust before first run.
- Test in a throwaway VM or instance before pointing anything at production.
- These scripts modify services, users, firewalls, and packages — run them with
  intent and the right privileges.

---

*All scripts validated with `bash -n`. Replace placeholder values (repo URLs,
endpoints, emails, service names) with your own before use.*
