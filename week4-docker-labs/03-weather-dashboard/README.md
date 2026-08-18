# Weather Dashboard

## Overview and objective
A two-container dashboard: an Nginx frontend calls a Node/Express API, which is the only component allowed to contact a weather provider.

## Architecture
`Browser -> frontend:80 (host 3000) -> backend:5000 (host 5001) -> Weather API`.

## Features and API
Search a city and display temperature, condition, humidity, and wind. Backend routes: `GET /api/weather?city=Nairobi`, `GET /api/searches`, and `POST /api/searches`.

## Configuration and security
Copy `.env.example` when present and set `WEATHER_API_KEY` only in the backend environment. Never expose a real key in frontend JavaScript or Git.

## Run and inspect
```bash
docker compose up --build
docker compose ps
docker compose logs -f backend
docker compose down
```
Open `http://localhost:3000`; API health can be checked at `http://localhost:5001/api/weather?city=Nairobi`.

## Docker explanation
Each service has its own image and Dockerfile. Compose provides the shared network and startup ordering; port mappings publish only the frontend and API ports. Use service names for container-to-container calls in production deployments.

## Screenshots and troubleshooting
Capture project structure, both builds, `docker compose ps`, dashboard search, API response, logs, and network inspection. For blank results inspect browser developer tools and `docker compose logs backend`; for port conflicts change host ports only.
