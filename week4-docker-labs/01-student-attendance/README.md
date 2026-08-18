# Student Attendance

## Overview and objective
An Express REST API for registering students and recording attendance. MongoDB runs separately so the lab demonstrates service networking and persistent database storage.

## Architecture
`Browser/client -> node-app:3000 -> mongodb:27017 -> mongodb-data volume`

## Features and API
`GET/POST /api/students`, `POST/GET /api/attendance`, and `GET /api/students/:id/attendance`. `GET /` provides a basic landing page.

## Prerequisites and configuration
Install Docker Desktop and Git. Copy `.env.example` to `.env` if local overrides are needed. The application uses `MONGO_HOST=mongodb`, never localhost.

## Run and test
```bash
docker compose up --build
curl http://localhost:3001/api/students
docker compose ps
docker compose logs node-app
docker compose down                 # keeps mongodb-data
docker compose down -v              # removes data
npm test
```

## Docker explanation
The Dockerfile uses a Node image (`FROM`), `/app` (`WORKDIR`), dependency installation (`RUN`), source copy (`COPY`), port documentation (`EXPOSE`), and `CMD`. Compose creates a private network, maps host port `3001` to port `3000`, and mounts `mongodb-data` at MongoDB's data directory. An image is the build blueprint; a container is its running instance.

## Screenshots
Capture: project tree; successful build; `docker compose ps`; API add/list responses; logs; `docker network ls`; `docker volume ls`; and a persistence check after `down` followed by `up`.

## Troubleshooting
If MongoDB connection fails, check `docker compose logs mongodb` and confirm `MONGO_HOST=mongodb`. If port 3001 is busy, change only the host side of the port mapping. If data disappears, confirm `down -v` was not used.
