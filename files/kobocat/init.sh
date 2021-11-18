#!/usr/bin/env sh
set -e

echo "Collect static files..."
python manage.py collectstatic --noinput

echo "Copy static files from ${KOBOCAT_SRC_DIR}/ondata/static/ to /static/"
rsync -aq "${KOBOCAT_SRC_DIR}/onadata/static/" "/static/" || true
