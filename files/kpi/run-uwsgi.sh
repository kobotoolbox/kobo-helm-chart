#!/usr/bin/env sh
set -e

UWSGI_LISTEN="${UWSGI_LISTEN:-128}"
PORT="${PORT:-8000}"

MIN_WORKERS="${MIN_WORKERS:-4}"
INITIAL_WORKERS="${INITIAL_WORKERS:-6}"
MAX_WORKERS="${MAX_WORKERS:-8}"
OVERLOAD_TIME="${OVERLOAD_TIME:-30}"
UWSGI_THREADS=${UWSGI_THREADS:-1}
MAX_REQUESTS="${UWSGI_MAX_REQUESTS:-100000}"
WORKER_RELOAD_MERCY="${UWSGI_WORKER_RELOAD_MERCY:-30}"

echo "Copying static files..."
rsync -aq --delete "${KPI_SRC_DIR}/staticfiles/" "${NGINX_STATIC_DIR}/" || true

echo "Running uwsgi with INITIAL_WORKERS: $INITIAL_WORKERS, MIN_WORKERS: $MIN_WORKERS, MAX_WORKERS: $MAX_WORKERS, OVERLOAD_TIME: $OVERLOAD_TIME, THREADS: $UWSGI_THREADS"

exec uwsgi \
    --module=kobo.wsgi:application \
    --env DJANGO_SETTINGS_MODULE=kobo.settings.prod \
    --master --pidfile=/tmp/project-master.pid \
    --log-x-forwarded-for \
    --log-format-strftime \
    --http-socket=:$PORT \
    --cheaper-algo=busyness \
    --cheaper=$MIN_WORKERS \
    --cheaper-initial=$INITIAL_WORKERS \
    --workers=$MAX_WORKERS \
    --cheaper-overload=$OVERLOAD_TIME \
    --cheaper-step=1 \
    --cheaper-busyness-max=50 \
    --cheaper-busyness-min=25 \
    --cheaper-busyness-multiplier=20 \
    --threads=$UWSGI_THREADS \
    --harakiri=60 \
    --max-requests=$MAX_REQUESTS \
    --worker-reload-mercy=$WORKER_RELOAD_MERCY \
    --die-on-term \
    --enable-threads \
    --single-interpreter \
    --post-buffering \
    --buffer-size=83146 \
    --ignore-sigpipe \
    --ignore-write-errors \
    --listen=$UWSGI_LISTEN

