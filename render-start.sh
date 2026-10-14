#!/bin/sh
set -eu

# Render's persistent disk is mounted at /var/data. Seed the disk with the
# bundled, already-populated SQLite database only on first boot. Never replace
# a database that already exists on the persistent disk.
mkdir -p /var/data/uploads
if [ ! -f /var/data/carbon_logistics.db ]; then
  if [ -f /app/backend/carbon_logistics.db ]; then
    cp /app/backend/carbon_logistics.db /var/data/carbon_logistics.db
  else
    echo "ERROR: bundled carbon_logistics.db was not found." >&2
    exit 1
  fi
fi

export DATABASE_URL="sqlite:////var/data/carbon_logistics.db"
export UPLOAD_FOLDER="/var/data/uploads"
export PORT="${PORT:-10000}"

# No destructive seed.py call here: seed.py runs db.drop_all(). The bundled
# database is already populated and must not be reset on deploy/restart.
exec gunicorn --bind "0.0.0.0:${PORT}" --workers 1 --threads 4 --timeout 120 app:app
