-- ==============================================================================
-- PROJECT IRIS: VERIFICATION QUERIES
-- Demonstrates spatial round-trips, GiST index utilization, and screening logic.
-- ==============================================================================

-- 1. SPATIAL ROUND-TRIP: Parcel 1 boundary verification
SELECT 
    id, 
    country_code, 
    source_id, 
    ST_AsText(geom) AS wkt_boundary,
    ST_Area(geom::geography) AS area_sq_meters
FROM iris_core.parcel
WHERE country_code = 'GB' AND source_id = 'PARCEL-GB-01';


-- 2. BESS GRID PROXIMITY SCREENING (Within 1,000 meters)
-- Evaluates parcels within 1km of any substation using geodesic distance
SELECT 
    p.source_id AS parcel_source_id,
    s.source_id AS substation_source_id,
    ROUND(ST_Distance(p.geom::geography, s.geom::geography)::numeric, 2) AS distance_meters,
    CASE 
        WHEN ST_DWithin(p.geom::geography, s.geom::geography, 1000.0) THEN 'VIABLE'
        ELSE 'TOO_FAR'
    END AS grid_feasibility
FROM iris_core.parcel p
JOIN iris_core.substation s 
  ON p.country_code = s.country_code
WHERE p.country_code = 'GB';


-- 3. PEATLAND INTERSECTION SCREENING & ECO-POINT CALCULATION
-- Calculates exact overlap area (m²) and indicative commercial compensation (8 eco-pts/m²)
SELECT 
    p.source_id AS parcel_source_id,
    pt.source_id AS peatland_source_id,
    ROUND(ST_Area(ST_Intersection(p.geom, pt.geom)::geography)::numeric, 2) AS intersection_area_m2,
    ROUND((ST_Area(ST_Intersection(p.geom, pt.geom)::geography) * 8.0)::numeric, 2) AS calculated_eco_points,
    'The 8 eco-points/m² factor is the current commercial baseline, not certified compensation.' AS disclaimer
FROM iris_core.parcel p
JOIN iris_core.peatland pt 
  ON p.country_code = pt.country_code
 AND ST_Intersects(p.geom, pt.geom)
WHERE p.country_code = 'GB';


-- 4. INDEX USAGE DEMONSTRATION (GiST Plan Verification)
-- Demonstrates optimizer selecting the GiST spatial index scan over seq scan
SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT p.id, p.source_id
FROM iris_core.parcel p
WHERE ST_Intersects(
    p.geom,
    ST_SetSRID(ST_MakeBox2D(ST_Point(-1.56, 53.78), ST_Point(-1.53, 53.81)), 4326)
);

SET enable_seqscan = ON;