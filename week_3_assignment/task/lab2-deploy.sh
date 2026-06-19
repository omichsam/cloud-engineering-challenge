#!/usr/bin/env bash
#
# lab2-deploy.sh
# --------------
# One-shot deploy: pull latest code from GitHub, restart the app, clear cache,
# and verify the service is healthy. Rolls back to the previous commit if the
# health check fails after deploy.
#
# Usage:
#   ./lab2-deploy.sh
#
# Configure the CONFIG block for your environment.
#
set -euo pipefail

# ----------------------------- CONFIG -----------------------------
APP_DIR="/opt/myapp"                       # git working tree on the server
GIT_BRANCH="main"
APP_SERVICE="myapp"                        # systemd unit to restart (or use RESTART_CMD)
RESTART_CMD="sudo systemctl restart ${APP_SERVICE}"
CACHE_DIRS=("${APP_DIR}/tmp/cache" "${APP_DIR}/var/cache")
HEALTH_URL="http://127.0.0.1:8080/health"  # endpoint that returns HTTP 200 when healthy
HEALTH_RETRIES=10
HEALTH_DELAY=3                             # seconds between health attempts
LOG_FILE="/var/log/deploy.log"
# ------------------------------------------------------------------

log() { echo "$(date '+%F %T') | $*" | tee -a "$LOG_FILE"; }
die() { log "ERROR: $*"; exit 1; }

# --- Sanity checks --------------------------------------------------
command -v git >/dev/null || die "git is not installed."
[[ -d "$APP_DIR/.git" ]] || die "$APP_DIR is not a git repository."
cd "$APP_DIR"

# --- 1. Pull latest code -------------------------------------------
log "Recording current commit for possible rollback..."
PREV_COMMIT="$(git rev-parse HEAD)"
log "Current commit: ${PREV_COMMIT}"

log "Fetching and pulling latest from origin/${GIT_BRANCH}..."
git fetch origin "$GIT_BRANCH"
git checkout "$GIT_BRANCH"
git reset --hard "origin/${GIT_BRANCH}"      # clean, deterministic deploy
NEW_COMMIT="$(git rev-parse HEAD)"
log "Now at commit: ${NEW_COMMIT}"

if [[ "$PREV_COMMIT" == "$NEW_COMMIT" ]]; then
    log "No new changes — code already up to date. Continuing to restart anyway."
fi

# --- 2. Clear cache -------------------------------------------------
log "Clearing cache directories..."
for dir in "${CACHE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        rm -rf "${dir:?}/"* 2>/dev/null || true
        log "  cleared: $dir"
    fi
done

# --- 3. Restart application ----------------------------------------
log "Restarting application: ${RESTART_CMD}"
eval "$RESTART_CMD" || die "Restart command failed."

# --- 4. Verify health ----------------------------------------------
log "Verifying service health at ${HEALTH_URL}..."
healthy=false
for ((i=1; i<=HEALTH_RETRIES; i++)); do
    if curl -fsS --max-time 5 -o /dev/null "$HEALTH_URL"; then
        healthy=true
        log "Health check PASSED on attempt ${i}."
        break
    fi
    log "  attempt ${i}/${HEALTH_RETRIES} failed; retrying in ${HEALTH_DELAY}s..."
    sleep "$HEALTH_DELAY"
done

if ! $healthy; then
    log "Health check FAILED. Rolling back to ${PREV_COMMIT}..."
    git reset --hard "$PREV_COMMIT"
    eval "$RESTART_CMD" || log "WARN: restart after rollback also failed."
    die "Deploy failed health check; rolled back to previous commit."
fi

log "DEPLOY SUCCESSFUL — running commit ${NEW_COMMIT}."
