#!/usr/bin/env bash
#
# lab1-nginx-watchdog.sh
# ----------------------
# Detects nginx failure, restarts it, logs the incident, and sends a
# notification. Designed to be run on a schedule (cron or a systemd timer).
#
# Usage:
#   sudo ./lab1-nginx-watchdog.sh            # run one check
#   sudo ./lab1-nginx-watchdog.sh --install  # install systemd service + timer
#
# Notifications: set ONE (or both) of the following in the CONFIG block:
#   - NOTIFY_EMAIL  : requires a working `mail`/`sendmail` (e.g. mailutils, ssmtp)
#   - SLACK_WEBHOOK : an Incoming Webhook URL
#
set -uo pipefail   # NOTE: no -e on purpose; we handle errors explicitly.

# ----------------------------- CONFIG -----------------------------
SERVICE="nginx"
HEALTH_URL="http://127.0.0.1/"          # set to a real health endpoint if you have one
LOG_FILE="/var/log/nginx-watchdog.log"
NOTIFY_EMAIL=""                          # e.g. "ops@example.com"
SLACK_WEBHOOK=""                         # e.g. "https://hooks.slack.com/services/XXX/YYY/ZZZ"
HOSTNAME_TAG="$(hostname -f 2>/dev/null || hostname)"
# ------------------------------------------------------------------

log() {
    # Append a timestamped line to the log file (and stderr).
    local msg="$1"
    local line
    line="$(date '+%Y-%m-%d %H:%M:%S') [${HOSTNAME_TAG}] ${msg}"
    echo "$line" | tee -a "$LOG_FILE" >&2
}

notify() {
    # Send a notification through whichever channels are configured.
    local subject="$1"
    local body="$2"

    if [[ -n "$NOTIFY_EMAIL" ]] && command -v mail >/dev/null 2>&1; then
        printf '%s\n' "$body" | mail -s "$subject" "$NOTIFY_EMAIL" \
            && log "Notification emailed to $NOTIFY_EMAIL" \
            || log "WARN: email notification failed"
    fi

    if [[ -n "$SLACK_WEBHOOK" ]] && command -v curl >/dev/null 2>&1; then
        local payload
        payload=$(printf '{"text":"*%s*\n%s"}' "$subject" "$body")
        curl -fsS -X POST -H 'Content-type: application/json' \
            --data "$payload" "$SLACK_WEBHOOK" >/dev/null \
            && log "Notification posted to Slack" \
            || log "WARN: Slack notification failed"
    fi

    if [[ -z "$NOTIFY_EMAIL" && -z "$SLACK_WEBHOOK" ]]; then
        log "INFO: no notification channel configured (set NOTIFY_EMAIL or SLACK_WEBHOOK)"
    fi
}

is_healthy() {
    # Returns 0 if nginx is active AND answering HTTP, 1 otherwise.
    systemctl is-active --quiet "$SERVICE" || return 1
    if command -v curl >/dev/null 2>&1; then
        curl -fsS --max-time 5 -o /dev/null "$HEALTH_URL" || return 1
    fi
    return 0
}

install_timer() {
    # Install a systemd service + timer that runs this script every minute.
    local script_path
    script_path="$(readlink -f "$0")"

    cat > /etc/systemd/system/nginx-watchdog.service <<EOF
[Unit]
Description=Nginx watchdog (detect, restart, log, notify)
After=network.target

[Service]
Type=oneshot
ExecStart=${script_path}
EOF

    cat > /etc/systemd/system/nginx-watchdog.timer <<EOF
[Unit]
Description=Run nginx watchdog every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
AccuracySec=10s

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now nginx-watchdog.timer
    log "Installed and started nginx-watchdog.timer (runs every minute)"
    echo "Installed. Check status with: systemctl status nginx-watchdog.timer"
}

main() {
    # Make sure we can write the log file.
    touch "$LOG_FILE" 2>/dev/null || {
        echo "Cannot write $LOG_FILE — run with sudo." >&2; exit 1; }

    if is_healthy; then
        log "OK: ${SERVICE} is healthy."
        exit 0
    fi

    log "ALERT: ${SERVICE} is DOWN or not responding. Attempting restart..."

    if systemctl restart "$SERVICE"; then
        sleep 3
        if is_healthy; then
            log "RECOVERED: ${SERVICE} restarted successfully."
            notify "[RECOVERED] ${SERVICE} on ${HOSTNAME_TAG}" \
                   "${SERVICE} was down and has been automatically restarted at $(date)."
            exit 0
        fi
    fi

    # Still broken after a restart attempt — escalate.
    local detail
    detail="$(systemctl status "$SERVICE" --no-pager -l 2>&1 | tail -n 20)"
    log "CRITICAL: ${SERVICE} could not be restarted. Manual intervention required."
    notify "[CRITICAL] ${SERVICE} DOWN on ${HOSTNAME_TAG}" \
           "Automatic restart FAILED at $(date).

Recent status:
${detail}"
    exit 2
}

case "${1:-}" in
    --install) install_timer ;;
    *)         main ;;
esac
