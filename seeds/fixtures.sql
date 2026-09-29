-- ==============================================================================
-- PROJECT IRIS: DETERMINISTIC SEED FIXTURES
-- Covers staging ingest, core canonical entities, and spatial screening scenarios.
-- ==============================================================================

TRUNCATE TABLE iris_core.evidence, iris_core.parcel, iris_core.substation, 
               iris_core.peatland, iris_core.screening_layer, iris_core.source_run CASCADE;
TRUNCATE TABLE iris_staging.parcel, iris_staging.substation, 
               iris_staging.peatland, iris_staging.screening_layer CASCADE;

-- 1. STAGING FIXTURES
INSERT INTO iris_staging.parcel (country_code, region_code, source_id, source_date, geom)
VALUES 
    ('GB', 'YORKS', 'RAW-GB-001', '2024/01/15', ST_GeomFromText('POLYGON((-1.55 53.79, -1.54 53.79, -1.54 53.80, -1.55 53.80, -1.55 53.79))')),
    ('DE', 'BY',    'RAW-DE-001', '15.01.2024', ST_GeomFromText('POLYGON((11.57 48.13, 11.58 48.13, 11.58 48.14, 11.57 48.14, 11.57 48.13))'));

INSERT INTO iris_staging.substation (country_code, region_code, source_id, source_date, geom)
VALUES 
    ('GB', 'YORKS', 'RAW-SUB-001', '2024/01/01', ST_GeomFromText('POINT(-1.545 53.795)'));

INSERT INTO iris_staging.peatland (country_code, region_code, source_id, source_date, geom)
VALUES 
    ('GB', 'YORKS', 'RAW-PEAT-001', '2023/11/20', ST_GeomFromText('POLYGON((-1.542 53.798, -1.538 53.798, -1.538 53.802, -1.542 53.802, -1.542 53.798))'));

INSERT INTO iris_staging.screening_layer (country_code, region_code, source_id, layer_name, source_date, geom)
VALUES 
    ('GB', 'YORKS', 'RAW-SCREEN-001', 'FLOOD_ZONE_3', '2024/02/01', ST_GeomFromText('POLYGON((-1.56 53.78, -1.53 53.78, -1.53 53.785, -1.56 53.785, -1.56 53.78))'));

-- 2. CORE: SOURCE RUNS
INSERT INTO iris_core.source_run (id, country_code, source_name, status, executed_at)
OVERRIDING SYSTEM VALUE
VALUES 
    (1, 'GB', 'UK_OS_OPEN_MAPS', 'SUCCESS', '2026-09-29 10:00:00+00'),
    (2, 'DE', 'DE_BKG_ALK_CADASTRAL', 'SUCCESS', '2026-09-29 10:30:00+00');

-- 3. CORE: SUBSTATIONS
INSERT INTO iris_core.substation (id, country_code, region_code, source_id, source_date, geom)
OVERRIDING SYSTEM VALUE
VALUES 
    (1, 'GB', 'YORKS', 'SUB-GB-01', '2024-01-01', ST_SetSRID(ST_MakePoint(-1.5450, 53.7950), 4326)),
    (2, 'DE', 'BY',    'SUB-DE-01', '2024-01-01', ST_SetSRID(ST_MakePoint(11.5750, 48.1350), 4326));

-- 4. CORE: PEATLAND & SCREENING LAYERS
INSERT INTO iris_core.peatland (id, country_code, region_code, source_id, source_date, geom)
OVERRIDING SYSTEM VALUE
VALUES 
    (1, 'GB', 'YORKS', 'PEAT-GB-01', '2023-06-01', 
     ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((-1.542 53.798, -1.535 53.798, -1.535 53.805, -1.542 53.805, -1.542 53.798))'), 4326)));

INSERT INTO iris_core.screening_layer (id, country_code, region_code, source_id, layer_name, source_date, geom)
OVERRIDING SYSTEM VALUE
VALUES 
    (1, 'GB', 'YORKS', 'SCREEN-GB-01', 'FLOOD_ZONE_3', '2024-01-10', 
     ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((-1.56 53.78, -1.53 53.78, -1.53 53.785, -1.56 53.785, -1.56 53.78))'), 4326)));

-- 5. CORE: PARCELS
INSERT INTO iris_core.parcel (id, country_code, region_code, source_id, source_date, geom)
OVERRIDING SYSTEM VALUE
VALUES 
    (1, 'GB', 'YORKS', 'PARCEL-GB-01', '2024-01-15', 
     ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((-1.550 53.790, -1.540 53.790, -1.540 53.800, -1.550 53.800, -1.550 53.790))'), 4326))),
    (2, 'GB', 'YORKS', 'PARCEL-GB-02', '2024-01-15', 
     ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((-1.450 53.750, -1.440 53.750, -1.440 53.760, -1.450 53.760, -1.450 53.750))'), 4326))),
    (3, 'DE', 'BY',    'PARCEL-GB-01', '2024-01-15', 
     ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((11.570 48.130, 11.580 48.130, 11.580 48.140, 11.570 48.140, 11.570 48.130))'), 4326)));

-- 6. CORE: EVIDENCE
INSERT INTO iris_core.evidence (country_code, parcel_id, source_run_id, finding_type, intersection_area_m2, eco_points_factor, finding_note)
VALUES 
    ('GB', 1, 1, 'PEATLAND_OVERLAP', 24105.80, 8.00, 'Commercial screening baseline: parcel overlaps protected peatland PEAT-GB-01 by 24,105.8 m²'),
    ('GB', 1, 1, 'SUBSTATION_PROXIMITY_OK', NULL, NULL, 'Parcel boundary within 450 meters of Substation SUB-GB-01');

-- ------------------------------------------------------------------------------
-- 7. RESYNC IDENTITY SEQUENCES
-- Dynamically updates the auto-increment counters to the highest existing ID
-- ------------------------------------------------------------------------------
SELECT setval(pg_get_serial_sequence('iris_core.source_run', 'id'), max(id)) FROM iris_core.source_run;
SELECT setval(pg_get_serial_sequence('iris_core.substation', 'id'), max(id)) FROM iris_core.substation;
SELECT setval(pg_get_serial_sequence('iris_core.peatland', 'id'), max(id)) FROM iris_core.peatland;
SELECT setval(pg_get_serial_sequence('iris_core.screening_layer', 'id'), max(id)) FROM iris_core.screening_layer;
SELECT setval(pg_get_serial_sequence('iris_core.parcel', 'id'), max(id)) FROM iris_core.parcel;
SELECT setval(pg_get_serial_sequence('iris_core.evidence', 'id'), max(id)) FROM iris_core.evidence;