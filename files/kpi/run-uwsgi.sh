#!/usr/bin/env sh
set -e

LISTEN="${UWSGI_LISTEN:-256}"
PORT="${PORT:-8000}"
CHEAPER_OVERLOAD="${UWSGI_CHEAPER_OVERLOAD:-30}"
MAX_REQUESTS="${UWSGI_MAX_REQUESTS:-2048}"
RELOAD_ON_RSS="${UWSGI_RELOAD_ON_RSS:-512}"
WORKER_RELOAD_MERCY="${UWSGI_WORKER_RELOAD_MERCY:-60}"
HARAKIRI="${UWSGI_HARAKIRI:-60}"
WORKERS="${UWSGI_WORKERS:-2}"
BUFFER_SIZE="${UWSGI_BUFFER_SIZE:-32768}"

echo "Copying static files..."
rsync -aq --delete "${KPI_SRC_DIR}/staticfiles/" "${NGINX_STATIC_DIR}/" || true

exec uwsgi \
    --module=kobo.wsgi:application \
    --env DJANGO_SETTINGS_MODULE=kobo.settings.prod \
    --master \
    --pidfile=/tmp/project-master.pid \
    --log-x-forwarded-for \
    --log-format-strftime \
    --http-socket=:$PORT \
    --cheaper-algo=busyness \
    --workers=$WORKERS \
    --cheaper-overload=$CHEAPER_OVERLOAD \
    --cheaper-step=1 \
    --cheaper-busyness-max=50 \
    --cheaper-busyness-min=25 \
    --cheaper-busyness-multiplier=20 \
    --harakiri=$HARAKIRI \
    --max-requests=$MAX_REQUESTS \
    --die-on-term \
    --enable-threads \
    --single-interpreter \
    --post-buffering \
    --buffer-size=$BUFFER_SIZE \
    --ignore-sigpipe \
    --ignore-write-errors \
    --disable-write-exception \
    --listen=$LISTEN
