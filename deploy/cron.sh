#!/bin/sh
# Hit one of the API's /internal/* cron routes from inside the api container.
# Coolify scheduled tasks call this (the self-hosted stand-in for the crons in
# apps/api/vercel.json). Usage: cron.sh /internal/sync/mailboxes
set -eu
exec curl -fsS -m 300 -H "Authorization: Bearer ${CRON_SECRET}" "http://127.0.0.1:${PORT:-3001}$1"
