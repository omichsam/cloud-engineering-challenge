#!/usr/bin/env bash
#
# challenge2-onboard-users.sh
# ---------------------------
# Reads usernames from a file, creates each Linux user, generates a strong
# random password, forces a password change at first login, and emails the
# credentials.
#
# Usage:
#   sudo ./challenge2-onboard-users.sh users.txt
#
# users.txt format — one entry per line:
#   alice          alice@example.com
#   bob            bob@example.com
#   # lines starting with # and blank lines are ignored
#
# SECURITY NOTES
#   * Emailing plaintext passwords is convenient but not best practice.
#     We mitigate by forcing `chage -d 0` (must change password at first login).
#   * For production, prefer SSH keys or a secrets manager over emailed passwords.
#
set -uo pipefail

USER_FILE="${1:-}"
REPORT="/var/log/user-onboarding.log"

[[ -z "$USER_FILE" ]] && { echo "Usage: $0 <users-file>"; exit 1; }
[[ -f "$USER_FILE" ]] || { echo "File not found: $USER_FILE"; exit 1; }
[[ "$(id -u)" -eq 0 ]] || { echo "Run as root (sudo)."; exit 1; }

log() { echo "$(date '+%F %T') | $*" | tee -a "$REPORT"; }

gen_password() {
    # 16-char password from a safe character set (no shell-tricky chars).
    if command -v openssl >/dev/null; then
        openssl rand -base64 18 | tr -dc 'A-Za-z0-9@#%+=' | head -c 16
    else
        tr -dc 'A-Za-z0-9@#%+=' < /dev/urandom | head -c 16
    fi
}

send_email() {
    # send_email <to> <subject> <body>
    local to="$1" subject="$2" body="$3"
    if command -v mail >/dev/null; then
        printf '%s\n' "$body" | mail -s "$subject" "$to" \
            && log "  emailed credentials to $to" \
            || log "  WARN: failed to email $to"
    else
        log "  WARN: 'mail' not installed — could not email $to (install mailutils/ssmtp)"
    fi
}

log "=== Onboarding run started from $USER_FILE ==="

while read -r username email _; do
    # skip comments and blank lines
    [[ -z "${username:-}" || "$username" == \#* ]] && continue

    if id "$username" &>/dev/null; then
        log "SKIP: user '$username' already exists."
        continue
    fi

    if ! useradd -m -s /bin/bash "$username"; then
        log "ERROR: failed to create '$username'."
        continue
    fi

    password="$(gen_password)"
    echo "${username}:${password}" | chpasswd
    chage -d 0 "$username"          # force change at first login
    log "CREATED: $username (must change password at first login)"

    if [[ -n "${email:-}" ]]; then
        body="Hello ${username},

Your account on $(hostname) has been created.

  Username: ${username}
  Temporary password: ${password}

You will be required to change this password the first time you log in.

Regards,
IT Operations"
        send_email "$email" "Your new account on $(hostname)" "$body"
    else
        log "  no email provided for $username — credentials in $REPORT only"
        log "  (temporary password for $username: $password)"
    fi
done < "$USER_FILE"

log "=== Onboarding run finished ==="
echo "Done. Full report: $REPORT"
