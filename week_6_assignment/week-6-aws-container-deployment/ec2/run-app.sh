#!/bin/bash
set -euo pipefail
: "${DB_PASSWORD:?Set DB_PASSWORD}"
docker rm -f task-tracker-app >/dev/null 2>&1 || true
docker run -d --name task-tracker-app --network task-tracker-network -p 80:80 -e DB_HOST=task-tracker-mysql -e DB_PORT=3306 -e DB_DATABASE="${DB_DATABASE:-task_tracker}" -e DB_USERNAME="${DB_USERNAME:-task_user}" -e DB_PASSWORD="$DB_PASSWORD" omarionya/task-tracker:latest
