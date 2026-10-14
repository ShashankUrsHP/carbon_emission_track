# Build the existing React/Vite frontend, then serve it with the existing Flask app.
FROM node:22-bookworm-slim AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM python:3.11-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/backend \
    DEV_MODE=false \
    AUTO_MIGRATE=false \
    DISABLE_SCHEDULER=false
WORKDIR /app
COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt
COPY backend/ /app/backend/
# Flask's existing catch-all serves this directory and keeps /api routes intact.
COPY --from=frontend-build /app/frontend/dist/ /app/backend/static/
COPY render-start.sh /app/render-start.sh
RUN chmod +x /app/render-start.sh
WORKDIR /app/backend
EXPOSE 10000
CMD ["/app/render-start.sh"]
