#!/bin/bash
# Startup wrapper — runs on every container start.
# Calls the original PostgreSQL entrypoint in background,
# waits until ready, executes startup.sql, then keeps PG in foreground.
set -e

# Run original entrypoint in background (handles initdb if needed)
/usr/local/bin/docker-entrypoint.sh "$@" &
PG_PID=$!

# Wait until PostgreSQL is accepting connections
until pg_isready -U "${POSTGRES_USER:-postgres}" > /dev/null 2>&1; do
  sleep 1
done

# Execute startup SQL (idempotent—use IF NOT EXISTS in your scripts)
if [ -f /startup/startup.sql ]; then
  psql -U "${POSTGRES_USER:-postgres}" -f /startup/startup.sql
fi

# Bring PostgreSQL back to foreground
wait $PG_PID
