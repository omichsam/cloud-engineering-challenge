# Week 4 Docker Lab: Flask + Redis URL Shortener

## Project overview and purpose

LinkLite is a small URL shortener that demonstrates how a web application and database run as separate Docker containers. A user submits a complete HTTP(S) URL, receives a six-character short link, follows that link to the original address, and views its click count.

The lab's purpose is to practise Docker images, containers, Dockerfiles, Compose, port mapping, service-name networking, environment variables, logs, health checks, and persistent volumes.

## Architecture

```text
Browser (http://localhost:5000)
              |
              | host port 5000 -> container port 5000
              v
     flask-app container
              |
              | redis:6379 on private Compose network
              v
        redis container
              |
              v
      redis-data volume
```

The browser only reaches Flask. Redis has no host port because only Flask needs it. Compose provides DNS, so the hostname `redis` resolves to the Redis container.

## Technologies and features

- Python 3.12, Flask, Gunicorn, Redis 7, HTML, and CSS
- Docker and Docker Compose with two services: `flask-app` and `redis`
- Create and validate short URLs (`http://` and `https://` only)
- Redirect and atomically count visits
- Statistics and health endpoints
- Helpful 400, 404, and 503 responses
- Responsive interface and Redis persistence
- Pytest tests backed by an in-memory fake Redis instance

## Project structure

```text
url-shortener/
├── app/
│   ├── static/style.css
│   ├── templates/index.html
│   ├── __init__.py
│   ├── redis_client.py
│   └── routes.py
├── tests/test_app.py
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── requirements-dev.txt
└── README.md
```

## Prerequisites

- Docker Desktop (running) with Docker Compose v2
- Git
- A browser
- Python is needed only to run tests outside Docker

Check the tools:

```bash
docker --version
docker compose version
git --version
```

## Setup and running the application

From this `url-shortener` directory:

```bash
cp .env.example .env
docker compose up --build
```

On PowerShell, use `Copy-Item .env.example .env` instead of `cp` if necessary. Open <http://localhost:5000>. Press `Ctrl+C` for an attached run, or use detached mode:

```bash
docker compose up -d --build
```

Routes:

| Method | Route | Purpose |
|---|---|---|
| GET | `/` | Form and results |
| POST | `/shorten` | Validate and save a URL |
| GET | `/<short_code>` | Count a click and redirect |
| GET | `/stats/<short_code>` | Show destination and clicks |
| GET | `/health` | Confirm Flask can reach Redis |

## Dockerfile explained

| Instruction | Meaning |
|---|---|
| `FROM python:3.12-slim` | Starts with a small official Python image. |
| `ENV ...` | Avoids bytecode files and sends logs directly to Docker. |
| `WORKDIR /app` | Makes `/app` the working directory inside the image. |
| `COPY requirements.txt .` | Copies dependencies separately to benefit from build caching. |
| `RUN pip install ...` | Installs fixed application dependencies without retaining pip's cache. |
| `COPY app ./app` | Adds the application source to the image. |
| `USER appuser` | Runs the service as an unprivileged user. |
| `EXPOSE 5000` | Documents the port used inside the container. |
| `CMD ... gunicorn` | Starts a production-style WSGI server on all container interfaces. |

A Docker **image** is the read-only packaged blueprint built from this Dockerfile. A **container** is a running, isolated instance of that image.

## Docker Compose explained

Compose describes and operates the complete multi-container application in one YAML file.

- `flask-app` is built from the local Dockerfile and maps host port 5000 to container port 5000.
- `redis` uses the official lightweight `redis:7-alpine` image. Its port stays private.
- `depends_on` waits until Redis passes `redis-cli ping` before Flask starts.
- Both services join `url-shortener-network`.
- `redis-data` is mounted at Redis's `/data` directory.
- `appendonly yes` tells Redis to record writes for durable recovery.
- `restart: unless-stopped` restarts a failed service unless it was intentionally stopped.

## Environment variables

`.env.example` documents safe configuration:

```dotenv
REDIS_HOST=redis
REDIS_PORT=6379
FLASK_ENV=production
```

Environment variables keep settings outside application code, allowing configuration to change between environments without rebuilding the image. Compose reads `.env` for `${...}` substitutions. Do not commit `.env`: real environment files can contain passwords, tokens, or other secrets. This project uses non-secret defaults, but follows the safe convention.

## Networking and port mapping

Compose creates a bridge network and DNS records for service names. Flask connects to `redis:6379`; it must not use `localhost`. Inside `flask-app`, `localhost` means the Flask container itself, not the Redis container.

The mapping `5000:5000` means **host port 5000 : container port 5000**. It makes Flask reachable at `localhost:5000`. Redis needs no port mapping because traffic remains on the private Docker network.

Inspect networking:

```bash
docker network ls
docker network inspect url-shortener_url-shortener-network
docker compose exec flask-app python -c "import socket; print(socket.gethostbyname('redis'))"
```

The project name is normally the directory name, so Docker prefixes resource names with `url-shortener_`. Confirm the exact name using `docker network ls`.

## Redis volume and persistence

Containers are disposable. Without a volume, removing Redis would remove its stored links. The named `redis-data` volume stores `/data` independently of the container, so ordinary recreation preserves data.

```bash
docker volume ls
docker volume inspect url-shortener_redis-data
```

`docker compose down` removes containers and the network but preserves named volumes. `docker compose down -v` also permanently removes the Compose volumes and therefore the stored URLs.

## Essential Docker commands

```bash
# Build the Flask image
docker compose build

# Start in the background
docker compose up -d

# List all running Docker containers
docker ps

# Show this project's service state
docker compose ps

# Show combined logs, then only Flask logs
docker compose logs
docker compose logs flask-app

# Follow live logs (Ctrl+C stops following, not the containers)
docker compose logs -f flask-app

# Rebuild changed code and start
docker compose up -d --build

# Stop/remove containers and network; keep volume
docker compose down

# Stop/remove containers, network, AND stored data
docker compose down -v

# List Docker networks and volumes
docker network ls
docker volume ls
```

`up -d` creates and starts services in detached/background mode. `down` stops and removes this project's containers and network while keeping the named volume unless `-v` is supplied.

## Testing

### Automated tests

The tests do not require a host Redis installation:

```bash
python -m venv .venv
# Linux/macOS: source .venv/bin/activate
# PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
pytest -v
```

### Manual test 1 – Application loads

Run `docker compose up -d --build`, open <http://localhost:5000>, and confirm the form appears.

### Manual test 2 – Create a short URL

Submit `https://www.example.com/some/very/long/url`. Confirm a short link appears. Also submit `not-a-url` and confirm the validation message.

### Manual test 3 – Redirect

Open the generated short link in a new tab. It should redirect to the original destination.

### Manual test 4 – Click tracking

Visit the short link three times. Return to its **View click statistics** link and refresh; the click count should be three.

### Manual test 5 – Redis connectivity

```bash
curl http://localhost:5000/health
docker compose exec redis redis-cli ping
docker compose exec redis redis-cli KEYS "url:*"
```

The expected health result is `{"status":"healthy"}`, Redis returns `PONG`, and the final command lists saved URL keys.

### Manual test 6 – Persistence

1. Create a short URL and save its code.
2. Run `docker compose down` (without `-v`).
3. Run `docker compose up -d`.
4. Reopen `/stats/<saved-code>` and confirm the record remains.

The Redis container was removed and recreated, but its `/data` came from the preserved named volume. Do not use `down -v` during this test.

## Screenshots

Create a `screenshots/` folder and replace each placeholder below with your own image link, for example `![Docker build](screenshots/02-build.png)`. Do not claim a screenshot until you capture it.

### Screenshot 1 – Project Structure

`[Insert screenshot here]` — Show the expanded `url-shortener` folder in VS Code, including `app`, `tests`, Docker files, environment example, and README.

### Screenshot 2 – Docker Compose Build

`[Insert screenshot here]` — Capture the end of `docker compose build`, including the successfully built `flask-app` image.

### Screenshot 3 – Running Containers

`[Insert screenshot here]` — Capture `docker compose ps` or `docker ps`, showing healthy/running `flask-app` and `redis`, plus Flask's `0.0.0.0:5000->5000/tcp` mapping.

### Screenshot 4 – Application Homepage

`[Insert screenshot here]` — Show the browser at `http://localhost:5000`, with the full LinkLite form and address bar visible.

### Screenshot 5 – URL Successfully Shortened

`[Insert screenshot here]` — Show the submitted long URL and generated localhost short link.

### Screenshot 6 – Redirect Working

`[Insert screenshot here]` — Open the short link and capture the destination page with its final browser address visible.

### Screenshot 7 – Click Statistics

`[Insert screenshot here]` — Show `/stats/<short-code>` with the code, original destination, and a click count greater than zero.

### Screenshot 8 – Docker Logs

`[Insert screenshot here]` — Capture `docker compose logs flask-app` with successful GET/POST requests and no connection errors.

### Screenshot 9 – Docker Network

`[Insert screenshot here]` — Capture `docker network ls` and, ideally, `docker network inspect url-shortener_url-shortener-network` showing both containers attached.

### Screenshot 10 – Docker Volume

`[Insert screenshot here]` — Capture `docker volume ls` showing `url-shortener_redis-data`.

### Screenshot 11 – Persistence Test

`[Insert screenshot here]` — After `down` and `up`, show the saved URL's statistics page and terminal service status together if possible.

## Troubleshooting

### Port 5000 is already in use

- **Cause:** Another program owns host port 5000.
- **Solution:** Stop that program, or change only the Compose mapping to `"5001:5000"` and browse to `localhost:5001`.

### Flask cannot connect to Redis

- **Cause:** Redis is unhealthy, the hostname was changed to `localhost`, or services do not share a network.
- **Solution:** Keep `REDIS_HOST=redis`; run `docker compose ps`, `docker compose logs redis`, and the DNS command in the networking section.

### Redis keeps restarting

- **Cause:** An invalid Redis command, storage problem, or permissions issue.
- **Solution:** Run `docker compose logs redis`; restore `redis-server --appendonly yes` and verify Docker has disk space.

### Docker Compose build fails

- **Cause:** Docker Desktop is stopped, files are missing, or the build cache is stale.
- **Solution:** Verify Docker is running and run `docker compose build --no-cache` after reading the first error in the build output.

### Dependency installation fails

- **Cause:** Network/DNS trouble or an unavailable package version.
- **Solution:** Check connectivity, retry the build, and verify names and versions in `requirements.txt`.

### Flask container exits immediately

- **Cause:** An import, configuration, or startup command failed.
- **Solution:** Run `docker compose ps -a` and `docker compose logs flask-app`; fix the first Python error and rebuild.

### Permission problems

- **Cause:** Docker Desktop lacks access to the project or its own configuration.
- **Solution:** Keep the project in a shared directory, verify Docker Desktop file-sharing settings, and avoid running project files as administrator/root unnecessarily.

### Environment variables are not loading

- **Cause:** `.env` is missing/misnamed or Compose was launched elsewhere.
- **Solution:** Copy `.env.example` to `.env`, run commands from this directory, then check `docker compose config` and recreate with `docker compose up -d --force-recreate`.

### Data disappeared after `docker compose down -v`

- **Cause:** `-v` deliberately deleted the named Redis volume.
- **Solution:** The deleted lab data cannot be recovered unless backed up. Recreate links and use ordinary `docker compose down` next time.

## Docker concepts for presentation

- **Docker:** A platform that packages and runs software consistently in isolated containers.
- **Image:** An immutable blueprint containing application code, runtime, libraries, and startup instructions.
- **Container:** A running instance of an image. It is isolated but shares the host operating-system kernel.
- **Dockerfile:** A repeatable recipe for building an image.
- **Docker Compose:** A way to define and operate multiple related containers as one application.
- **Why two containers:** Flask and Redis have different responsibilities and lifecycles. Separation makes either service easier to replace, update, or scale.
- **Communication:** Compose DNS resolves the service name `redis`; Flask connects to `redis:6379` over their bridge network.
- **Docker network:** A private virtual network that lets containers communicate and discover one another by service name.
- **Why not localhost:** Each container has its own network namespace, so Flask's `localhost` points back to Flask—not Redis.
- **Docker volume:** Docker-managed storage whose lifetime is independent of a container.
- **Why persistence:** Short links and counters must survive Redis container replacement.
- **`5000:5000`:** Forward host port 5000 to Flask's container port 5000.
- **`up -d`:** Create/start all services in the background.
- **`down`:** Stop and remove Compose containers and network, preserving named volumes.
- **`down -v`:** Also delete named volumes and their data.
- **Why exclude `.env`:** Configuration files may contain credentials and environment-specific values that must not be published.

## GitHub submission

Commit `app/`, `tests/`, the Dockerfile, Compose file, requirements files, `.dockerignore`, `.gitignore`, `.env.example`, README, and your own screenshots. Do not commit `.env`, `.venv`, cache files, containers, or Docker images. GitHub stores source files; an optional image registry stores built images.

From a new standalone project directory, the standard commands are:

```bash
git init
git add .
git status
git commit -m "Complete Week 4 Docker URL Shortener Lab"
git branch -M main
git remote add origin <GITHUB_REPOSITORY_URL>
git push -u origin main
```

Because this lab is already inside the Cloud Engineering Challenge repository, normally use the existing repository instead: `git add week_4_assignment`, commit, and push the existing branch. Always inspect `git status` before committing.

### Optional Docker Hub image

```bash
docker build -t <dockerhub-username>/url-shortener:latest .
docker login
docker push <dockerhub-username>/url-shortener:latest
```

This is optional unless the assignment explicitly requires it. A Docker Hub repository may be private if required. Never upload image binary data into the Git repository.

## Conclusion

This lab packages a Flask application as an image, runs it beside Redis with Compose, connects the containers through private service-name networking, publishes only the web port, and preserves database records in a named volume. Together, these choices demonstrate the core containerization workflow without requiring Redis or Python to be installed on the deployment host.

## Submission checklist

- [ ] Application code included
- [ ] Dockerfile included
- [ ] Docker Compose included
- [ ] Redis container working
- [ ] Flask container working
- [ ] Docker network demonstrated
- [ ] Docker volume demonstrated
- [ ] Environment variables demonstrated
- [ ] Application tested
- [ ] Screenshots added
- [ ] README completed
- [ ] `.env` excluded from GitHub
- [ ] Docker images not uploaded to GitHub
- [ ] GitHub repository tested
- [ ] Final submission ready
