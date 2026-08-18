#!/bin/bash
set -euo pipefail
docker rm -f task-tracker-app task-tracker-mysql || true
docker network rm task-tracker-network || true
docker volume rm task-tracker-db-data || true
