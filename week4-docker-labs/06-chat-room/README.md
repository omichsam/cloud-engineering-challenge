# Chat Room

## Overview and objective
A FastAPI WebSocket room demonstrating real-time messaging, REST inspection endpoints, Redis service integration, and a Compose network.

## Architecture and features
`Browser WebSocket -> chat-api:8000 -> redis:6379`. Connect to `/ws/{username}`; messages broadcast to connected users. REST routes are `GET /api/messages` and `GET /api/users`.

## Configuration
Copy `.env.example` to `.env`; `REDIS_HOST=redis` is the Compose service name and must not be changed to localhost inside the container.

## Run and test
```bash
docker compose up --build
docker compose ps
docker compose logs -f chat-api
docker compose down
docker compose down -v
```
Open a WebSocket client at `ws://localhost:8000/ws/alice` and another at `/ws/bob`; send messages and verify both receive them. Query the REST endpoints with curl.

## Docker and persistence
The Dockerfile installs requirements, copies `app`, exposes 8000, and starts Uvicorn. Compose runs `chat-api` beside Redis and mounts `redis-data`; `down` preserves the volume while `down -v` deletes it.

## Screenshots and troubleshooting
Capture project tree, build, running services, two connected clients, REST history/users, logs, network, and volume. For WebSocket failures check browser console and `docker compose logs chat-api`; for Redis failures verify service health and hostname.
