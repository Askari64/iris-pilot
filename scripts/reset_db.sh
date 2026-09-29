#!/usr/bin/env bash
set -euo pipefail

echo "Resetting Project IRIS Database..."
docker exec -i iris-db psql -U postgres -d iris -c "DROP SCHEMA IF EXISTS iris_core CASCADE; DROP SCHEMA IF EXISTS iris_staging CASCADE;"

echo "Applying migrations..."
docker exec -i iris-db psql -U postgres -d iris < migrations/001_create_schemas.sql
docker exec -i iris-db psql -U postgres -d iris < migrations/002_create_tables.sql
docker exec -i iris-db psql -U postgres -d iris < migrations/003_create_indexes.sql

echo "Loading seed fixtures..."
docker exec -i iris-db psql -U postgres -d iris < seeds/fixtures.sql

echo "Rebuild complete."