# Book Library

## Overview and objective
Spring Boot library API backed by PostgreSQL. It demonstrates a Java image, a database container, Compose networking, and persistent relational data.

## Architecture and model
`Client -> java-app:8080 -> postgres:5432 -> postgres-data volume`. Books contain `id`, `title`, `author`, `isbn`, `category`, `available`, and `borrowedBy`.

## API
Use `/api/books` to list/create books. Extend with GET-by-id, search, borrow, return, update, and delete routes as the practical exercise grows.

## Configuration
Compose sets `SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library_db`. Example credentials are for demonstration only; production systems must use secret management.

## Build, run, and inspect
```bash
mvn clean package
docker compose up --build
curl http://localhost:8080/api/books
docker compose ps
docker compose logs java-app
docker compose down
docker compose down -v
```

## Docker explanation
The multi-stage Dockerfile compiles with Maven, copies the JAR into a smaller JRE image, exposes 8080, and starts with `java -jar`. Compose connects `java-app` to `postgres` by service name and preserves data in `postgres-data`.

## Screenshots and troubleshooting
Capture Maven packaging, image build, containers, API calls, logs, network, volume, and persistence after restart. Check PostgreSQL logs and credentials first when startup fails; never replace the database hostname with localhost.
