#!/bin/bash
set -euo pipefail
docker network inspect task-tracker-network >/dev/null 2>&1 || docker network create task-tracker-network
