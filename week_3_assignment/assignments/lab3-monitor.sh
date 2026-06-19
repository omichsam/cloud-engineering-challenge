#!/usr/bin/env bash
#
# lab3-monitor.sh
# ---------------
# Monitors disk, memory, and CPU on an EC2 (or any Linux) instance and writes
# timestamped logs to /var/log/monitoring. Raises an alert line when any metric
# crosses its threshold.
#
# Usage:
#   sudo ./lab3-monitor.sh                 # run all checks once
#   sudo ./lab3-monitor.sh disk            # run a single check (disk|mem|cpu)
#   sudo ./lab3-monitor.sh --cron          # print a crontab line to run every 5 min
#
set -uo pipefail

# ----------------------------- CONFIG -----------------------------
LOG_DIR="/var/log/monitoring"
DISK_THRESHOLD=80      # percent used
MEM_THRESHOLD=80       # percent used
CPU_THRESHOLD=85       # percent used
DISK_MOUNT="/"         # filesystem to watch
# ------------------------------------------------------------------

mkdir -p "$LOG_DIR" 2>/dev/null || { echo "Need sudo to create $LOG_DIR" >&2; exit 1; }

ts() { date '+%Y-%m-%d %H:%M:%S'; }

write_log() {
    # write_log <logfile> <message>
    local file="$LOG_DIR/$1"; shift
    echo "$(ts) | $*" >> "$file"
}

# ----- Disk -------------------------------------------------------
monitor_disk() {
    local used
    used=$(df --output=pcent "$DISK_MOUNT" | tail -1 | tr -dc '0-9')
    local level="OK"
    (( used >= DISK_THRESHOLD )) && level="ALERT"
    write_log "disk.log" "${level} disk usage on ${DISK_MOUNT}: ${used}% (threshold ${DISK_THRESHOLD}%)"
    echo "DISK ${level}: ${used}%"
}

# ----- Memory -----------------------------------------------------
monitor_mem() {
    # Use /proc/meminfo for portability.
    local total avail used pct
    total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    avail=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    used=$(( total - avail ))
    pct=$(( used * 100 / total ))
    local level="OK"
    (( pct >= MEM_THRESHOLD )) && level="ALERT"
    write_log "memory.log" "${level} memory usage: ${pct}% (threshold ${MEM_THRESHOLD}%)"
    echo "MEM ${level}: ${pct}%"
}

# ----- CPU --------------------------------------------------------
monitor_cpu() {
    # Sample /proc/stat over 1 second to compute busy percentage.
    read -r _ u1 n1 s1 i1 w1 irq1 si1 _ < /proc/stat
    sleep 1
    read -r _ u2 n2 s2 i2 w2 irq2 si2 _ < /proc/stat
    local idle1=$(( i1 + w1 ))
    local idle2=$(( i2 + w2 ))
    local total1=$(( u1 + n1 + s1 + i1 + w1 + irq1 + si1 ))
    local total2=$(( u2 + n2 + s2 + i2 + w2 + irq2 + si2 ))
    local totald=$(( total2 - total1 ))
    local idled=$(( idle2 - idle1 ))
    local pct=0
    (( totald > 0 )) && pct=$(( (totald - idled) * 100 / totald ))
    local level="OK"
    (( pct >= CPU_THRESHOLD )) && level="ALERT"
    write_log "cpu.log" "${level} cpu usage: ${pct}% (threshold ${CPU_THRESHOLD}%)"
    echo "CPU ${level}: ${pct}%"
}

case "${1:-all}" in
    disk)  monitor_disk ;;
    mem)   monitor_mem ;;
    cpu)   monitor_cpu ;;
    all)   monitor_disk; monitor_mem; monitor_cpu ;;
    --cron)
        echo "*/5 * * * * root $(readlink -f "$0") all >/dev/null 2>&1"
        ;;
    *) echo "Usage: $0 [disk|mem|cpu|all|--cron]" >&2; exit 1 ;;
esac
