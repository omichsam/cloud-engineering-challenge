#!/bin/bash
set -euo pipefail
docker rm -f task-tracker-app task-tracker-mysql || true
