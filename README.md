# Project IRIS: Geospatial Database Pilot

A production-grade PostGIS database and ELT pipeline designed to evaluate candidate land parcels for renewable energy sites based on strict spatial constraints (grid proximity, flood zones, and protected habitats).

## Tech Stack
* **Database**: PostgreSQL 16 + PostGIS 3.4
* **Pipeline**: Python 3.13 (`psycopg3`)
* **Testing**: `pytest`
* **Infrastructure**: Docker / Docker Compose

## Project Structure
* `/migrations/`: SQL scripts to initialize the `iris_staging` and `iris_core` schemas, tables, and constraints.
* `/seeds/`: Deterministic test data (`fixtures.sql`) mapping out real-world coordinates in the UK and Germany.
* `/scripts/`: PowerShell automation for database resets (`reset_db.ps1`) and Python ELT logic (`etl.py`).
* `/tests/`: Automated unit tests (`test_correctness.py`) verifying spatial constraints and database integrity.
* `verify_queries.sql`: Manual spatial queries demonstrating GiST index usage, distance calculations, and polygon intersections.

## Quick Start

### 1. Start the Database Infrastructure
Ensure Docker Desktop is running, then spin up the PostGIS container:
```powershell
docker-compose up -d
```

### 2. Initialize the Python Environment
Create a virtual environment and install the required dependencies:

**Windows (PowerShell):**
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

**macOS/Linux:**
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Build and Seed the Database
Run the automated reset script to tear down existing schemas, apply migrations, build GiST indexes, and load the raw staging fixtures:

**Windows (PowerShell):**
```powershell
.\scripts\reset_db.ps1
```

**macOS/Linux:**
```bash
bash scripts/reset_db.sh
```

### 4. Run the ELT Pipeline
Execute the data loader to promote the raw data from `iris_staging` to `iris_core`. This script safely standardizes European date formats, enforces SRID locks, and uses idempotency (`ON CONFLICT DO UPDATE`) to prevent duplication:
```powershell
python scripts/etl.py
```

### 5. Verify Constraints
Run the test suite to programmatically verify that PostGIS is strictly enforcing MultiPolygon types, SRID 4326, and compound unique constraints:
```powershell
pytest tests/test_correctness.py -v
```

### 6. Manual Spatial Verification
To execute the manual verification queries demonstrating GiST index usage, distance calculations, and polygon intersections:

**Windows (PowerShell):**
```powershell
Get-Content scripts\verify_queries.sql | docker exec -i iris-db psql -U postgres -d iris
```

**macOS/Linux**
```bash
docker exec -i iris-db psql -U postgres -d iris < verify_queries.sql
```

*(Note: The database volumes will persist locally so your data isn't lost on restart. To completely wipe the volume for a fresh start, use `docker-compose down -v`)*