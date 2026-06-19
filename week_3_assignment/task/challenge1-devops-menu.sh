#!/usr/bin/env bash
#
# challenge1-devops-menu.sh
# -------------------------
# A menu-driven DevOps helper demonstrating case, loops, and functions.
#
#   1) Check CPU
#   2) Check RAM
#   3) Restart nginx
#   4) Backup logs
#   5) Exit
#
# Usage:  sudo ./challenge1-devops-menu.sh
#
set -uo pipefail

BACKUP_DIR="/var/backups/logs"
LOG_SOURCE="/var/log"

# ----------------------------- FUNCTIONS --------------------------
check_cpu() {
    read -r _ u1 n1 s1 i1 w1 _ < /proc/stat; sleep 1
    read -r _ u2 n2 s2 i2 w2 _ < /proc/stat
    local idle=$(( (i2+w2) - (i1+w1) ))
    local total=$(( (u2+n2+s2+i2+w2) - (u1+n1+s1+i1+w1) ))
    local pct=0
    (( total > 0 )) && pct=$(( (total - idle) * 100 / total ))
    echo ">> CPU usage: ${pct}%"
}

check_ram() {
    local total avail pct
    total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    pct=$(( (total - avail) * 100 / total ))
    echo ">> RAM usage: ${pct}%  ($(( (total-avail)/1024 )) MB / $(( total/1024 )) MB)"
}

restart_nginx() {
    if ! command -v systemctl >/dev/null; then
        echo ">> systemctl not found on this system."; return 1
    fi
    echo ">> Restarting nginx..."
    if sudo systemctl restart nginx; then
        echo ">> nginx restarted. State: $(systemctl is-active nginx)"
    else
        echo ">> Failed to restart nginx. Check: systemctl status nginx"
    fi
}

backup_logs() {
    mkdir -p "$BACKUP_DIR" || { echo ">> Cannot create $BACKUP_DIR (try sudo)"; return 1; }
    local archive="$BACKUP_DIR/logs-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo ">> Archiving $LOG_SOURCE -> $archive"
    if sudo tar -czf "$archive" -C "$(dirname "$LOG_SOURCE")" "$(basename "$LOG_SOURCE")" 2>/dev/null; then
        echo ">> Backup complete: $(du -h "$archive" | cut -f1)"
    else
        echo ">> Backup finished with some warnings (open files skipped)."
    fi
}

pause() { read -rp $'\nPress Enter to continue...' _; }

print_menu() {
    cat <<'MENU'

============================
   DevOps Quick Tool
============================
  1) Check CPU
  2) Check RAM
  3) Restart nginx
  4) Backup logs
  5) Exit
============================
MENU
}

# ----------------------------- MAIN LOOP --------------------------
while true; do
    print_menu
    read -rp "Choose an option [1-5]: " choice
    case "$choice" in
        1) check_cpu;      pause ;;
        2) check_ram;      pause ;;
        3) restart_nginx;  pause ;;
        4) backup_logs;    pause ;;
        5) echo "Goodbye."; exit 0 ;;
        *) echo "Invalid option: '$choice'. Pick 1-5."; pause ;;
    esac
done
