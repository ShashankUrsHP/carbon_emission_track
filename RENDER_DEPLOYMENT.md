# CarbonTrack — Render-only deployment

This deployment serves the existing React/Vite frontend and Flask API from one Render Docker web service. It uses the already-seeded SQLite database on a Render persistent disk, so no second backend host or external database is required.

## Deploy

1. Push the contents of this project folder to a GitHub repository (keep `Dockerfile`, `render.yaml`, `.dockerignore`, and `render-start.sh` at repository root).
2. In Render, choose **New + → Blueprint**, connect the repository, and apply `render.yaml`.
3. This blueprint uses a **Starter web service with a 2 GB persistent disk**. A persistent disk is required to retain the SQLite database and uploaded documents between deploys/restarts; do not downgrade to a plan that does not support persistent disks.
4. Add the real values for `GOOGLE_MAPS_API_KEY`, `GOOGLE_ROUTES_API_KEY`, `GOOGLE_PLACES_API_KEY`, and `OPENWEATHER_API_KEY` in the Render environment. Keep API keys restricted to the required APIs.
5. Wait for the Docker build and health check at `/api/health`, then test login, admin/driver pages, trips, maps, reports, chat, and document upload.

## Database and seed data

The ZIP includes `backend/carbon_logistics.db`, which is already seeded. On the first boot only, `render-start.sh` copies it to `/var/data/carbon_logistics.db`. Subsequent boots and deploys do **not** overwrite that persistent database. Do not run `backend/seed.py` against the live database: that script calls `db.drop_all()` and would erase existing data.

The initial demo credentials are documented in `backend/seed.py` and are not suitable for a public production deployment. Change passwords immediately or replace demo accounts before sharing the URL publicly. Rotate any credentials or API keys that may have been present in a previously shared `.env` file.

## Important constraints

- This is a single-instance SQLite deployment. The persistent disk is attached to one service instance; do not scale to multiple instances or workers. Gunicorn is deliberately configured with one worker.
- Scheduled jobs run in the web process. They may stop during restarts/deploys and should not be treated as a durable job queue. The app's daily retraining/report jobs run in the same process.
- Uploaded documents are stored on the persistent disk through `UPLOAD_FOLDER`.
- Render builds the frontend in Docker and Flask serves the compiled SPA from `backend/static`, keeping the existing same-origin `/api/v1` calls and avoiding production CORS configuration.
- This scaffold does not claim a successful cloud deployment. Build/runtime verification and the functional smoke tests above must pass before considering the public URL production-ready.
