Write-Host "Resetting Project IRIS Database..." -ForegroundColor Cyan

# 1. Drop existing schemas
docker exec -i iris-db psql -U postgres -d iris -c "DROP SCHEMA IF EXISTS iris_core CASCADE; DROP SCHEMA IF EXISTS iris_staging CASCADE;"

# 2. Run migrations sequentially
Write-Host "Applying migrations..." -ForegroundColor Yellow
Get-Content migrations/001_create_schemas.sql | docker exec -i iris-db psql -U postgres -d iris
Get-Content migrations/002_create_tables.sql | docker exec -i iris-db psql -U postgres -d iris
Get-Content migrations/003_create_indexes.sql | docker exec -i iris-db psql -U postgres -d iris

# 3. Load seed fixtures
Write-Host "Loading seed fixtures..." -ForegroundColor Yellow
Get-Content seeds/fixtures.sql | docker exec -i iris-db psql -U postgres -d iris

Write-Host "Rebuild complete. Database is fresh and seeded." -ForegroundColor Green