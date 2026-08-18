# Notes Keeper

## Overview and objective
A beginner-friendly Flask note manager demonstrating a single application container with SQLite persistence.

## Architecture and features
`Browser -> flask-app:5000 -> /data/notes.db -> notes-data volume`. Add, list, search, view, and delete notes using the responsive HTML form.

## Setup
Prerequisites: Docker Desktop and a browser. `.env.example` documents `DATABASE_PATH=/data/notes.db`; copy it to `.env` only for local configuration.

## Run, test, and Docker commands
```bash
docker compose up --build
docker compose ps
docker compose logs -f flask-app
docker compose down
docker compose down -v
```
Open `http://localhost:5000`. Test each add/search/view/delete flow manually or add pytest tests under `tests/`.

## Docker and persistence
`FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, and `CMD` build and start Flask. Compose maps `5000:5000` and mounts the named `notes-data` volume. `down` preserves the database; `down -v` deletes it. Images are immutable build artifacts, while containers are running instances.

## Screenshots
Capture the project tree, build output, running container, homepage, a created note, search result, logs, volume listing, and the same note after restart.

## Troubleshooting
Check `docker compose logs flask-app` for startup errors. If the port is busy, change the host port. If notes vanish, recreate without `-v` and verify the volume with `docker volume ls`.
