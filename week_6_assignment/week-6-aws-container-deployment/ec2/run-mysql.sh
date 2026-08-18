#!/bin/bash
set -euo pipefail
: "${MYSQL_ROOT_PASSWORD:?Set MYSQL_ROOT_PASSWORD}"; : "${MYSQL_PASSWORD:?Set MYSQL_PASSWORD}"
docker volume create task-tracker-db-data >/dev/null
docker rm -f task-tracker-mysql >/dev/null 2>&1 || true
docker run -d --name task-tracker-mysql --network task-tracker-network -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" -e MYSQL_DATABASE="${MYSQL_DATABASE:-task_tracker}" -e MYSQL_USER="${MYSQL_USER:-task_user}" -e MYSQL_PASSWORD="$MYSQL_PASSWORD" -v task-tracker-db-data:/var/lib/mysql mysql:8
