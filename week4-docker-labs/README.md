# Week 4 Docker Containerization Labs

## Week summary

Six independently runnable applications demonstrate Dockerfiles, images, containers, Compose services, private networking, environment variables, port mappings, logs, tests, and persistent volumes. Start in one lab directory so its ports and volumes remain isolated from the others.
| Lab | Application | Technology | Containers |
|---|---|---|---|
| 1 | Student Attendance | Node.js + MongoDB | node-app, mongodb |
| 2 | Notes Keeper | Flask + SQLite | flask-app |
| 3 | Weather Dashboard | Frontend + Node.js | frontend, backend |
| 4 | URL Shortener | Flask + Redis | flask-app, redis |
| 5 | Book Library | Spring Boot + PostgreSQL | java-app, postgres |
| 6 | Chat Room | FastAPI + Redis | chat-api, redis |

Run `docker compose up --build` inside any lab directory. Use `docker compose ps`, `docker compose logs`, and `docker compose down`; `down -v` deletes named-volume data. Multi-container applications use Compose service names, never localhost, for database connections. Do not commit `.env`, secrets, generated dependencies, or images.

## Lab documentation

- [Student Attendance](01-student-attendance/README.md)
- [Notes Keeper](02-notes-keeper/README.md)
- [Weather Dashboard](03-weather-dashboard/README.md)
- [URL Shortener](04-url-shortener/README.md)
- [Book Library](05-book-library/README.md)
- [Chat Room](06-chat-room/README.md)

Each README documents the objective, architecture, features, prerequisites, environment variables, Dockerfile and Compose concepts, networking, volumes, testing, troubleshooting, and screenshot evidence to capture.

## Verification summary

| Application | Build/run | URL or endpoint | Volume |
|---|---|---|---|
| Attendance | `docker compose up --build` | `http://localhost:3001` | `mongodb-data` |
| Notes | `docker compose up --build` | `http://localhost:5000` | `notes-data` |
| Weather | `docker compose up --build` | `http://localhost:3000` | backend demo storage |
| URL Shortener | `docker compose up --build` | `http://localhost:5000` | `redis-data` |
| Book Library | `mvn clean package; docker compose up --build` | `http://localhost:8080` | `postgres-data` |
| Chat Room | `docker compose up --build` | `ws://localhost:8000/ws/alice` | `redis-data` |
