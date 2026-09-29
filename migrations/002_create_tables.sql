-- ==============================================================================
-- PART 1: STAGING TABLES (iris_staging)
-- Raw ingest tables: unconstrained types, no FKs, but country_code is strictly NOT NULL.
-- ==============================================================================

CREATE TABLE iris_staging.parcel (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code TEXT NOT NULL,
    region_code TEXT,
    source_id TEXT,
    source_date TEXT,
    geom GEOMETRY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE iris_staging.substation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code TEXT NOT NULL,
    region_code TEXT,
    source_id TEXT,
    source_date TEXT,
    geom GEOMETRY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE iris_staging.peatland (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code TEXT NOT NULL,
    region_code TEXT,
    source_id TEXT,
    source_date TEXT,
    geom GEOMETRY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE iris_staging.screening_layer (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code TEXT NOT NULL,
    region_code TEXT,
    source_id TEXT,
    layer_name TEXT,
    source_date TEXT,
    geom GEOMETRY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

-- ==============================================================================
-- PART 2: CORE TABLES (iris_core)
-- Canonical production tables: strict types, SRID 4326, country-scoped natural keys.
-- ==============================================================================

-- 1. Pipeline Run Audit
CREATE TABLE iris_core.source_run (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    source_name VARCHAR(128) NOT NULL,
    status VARCHAR(64) NOT NULL,
    executed_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

-- 2. Land Parcels
CREATE TABLE iris_core.parcel (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    region_code VARCHAR(16),
    source_id VARCHAR(128) NOT NULL,
    source_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    geom geometry(MultiPolygon, 4326) NOT NULL,
    UNIQUE (country_code, source_id)
);

-- 3. Electrical Substations
CREATE TABLE iris_core.substation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    region_code VARCHAR(16),
    source_id VARCHAR(128) NOT NULL,
    source_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    geom geometry(Point, 4326) NOT NULL,
    UNIQUE (country_code, source_id)
);

-- 4. Peatland Environmental Areas
CREATE TABLE iris_core.peatland (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    region_code VARCHAR(16),
    source_id VARCHAR(128) NOT NULL,
    source_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    geom geometry(MultiPolygon, 4326) NOT NULL,
    UNIQUE (country_code, source_id)
);

-- 5. Screening Layer
CREATE TABLE iris_core.screening_layer (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    region_code VARCHAR(16),
    source_id VARCHAR(128) NOT NULL,
    layer_name VARCHAR(128) NOT NULL,
    source_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    geom geometry(MultiPolygon, 4326) NOT NULL,
    UNIQUE (country_code, source_id)
);

-- 6. Evidence Junction
CREATE TABLE iris_core.evidence (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    parcel_id BIGINT NOT NULL REFERENCES iris_core.parcel(id) ON DELETE CASCADE,
    source_run_id BIGINT NOT NULL REFERENCES iris_core.source_run(id) ON DELETE CASCADE,
    finding_type VARCHAR(64) NOT NULL,
    intersection_area_m2 NUMERIC(14,2),
    eco_points_factor NUMERIC(8,2) DEFAULT 8.00,
    finding_note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);