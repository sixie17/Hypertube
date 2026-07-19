#!/bin/sh
set -e

echo "⏳ Waiting for database to be fully ready..."
until node -e "require('net').connect({host: process.env.POSTGRES_HOST, port: process.env.POSTGRES_PORT}).on('connect', () => process.exit(0)).on('error', () => process.exit(1))"; do
  echo "Database is unavailable - sleeping"
  sleep 1
done

if [ "$NODE_ENV" = "development" ]; then
  echo "Development environment detected..."
  pnpm run build
fi

echo "Database is up! Running TypeORM database migrations..."
pnpm typeorm migration:run -d dist/data-source.js

echo "Migrations complete. Executing application command..."
exec "$@"
