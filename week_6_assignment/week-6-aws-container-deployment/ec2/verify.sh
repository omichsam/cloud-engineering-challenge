#!/bin/bash
set -euo pipefail
docker ps
docker network inspect task-tracker-network
docker logs --tail 50 task-tracker-mysql
docker logs --tail 50 task-tracker-app
