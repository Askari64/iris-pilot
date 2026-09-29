-- ==============================================================================
-- 1. SPATIAL INDEXES (GiST)
-- Generalized Search Tree indexes for bounding-box spatial searches.
-- Required for ST_Intersects, ST_Contains, ST_DWithin performance.
-- ==============================================================================

CREATE INDEX idx_core_parcel_geom ON iris_core.parcel USING GIST (geom);
CREATE INDEX idx_core_substation_geom ON iris_core.substation USING GIST (geom);
CREATE INDEX idx_core_peatland_geom ON iris_core.peatland USING GIST (geom);
CREATE INDEX idx_core_screening_layer_geom ON iris_core.screening_layer USING GIST (geom);


-- ==============================================================================
-- 2. RELATIONAL INDEXES (B-Tree)
-- Speeds up country filtering and foreign key joins.
-- ==============================================================================
-- Country filtering (Core contract: country-scoped queries)

CREATE INDEX idx_core_parcel_country ON iris_core.parcel (country_code);
CREATE INDEX idx_core_substation_country ON iris_core.substation (country_code);
CREATE INDEX idx_core_peatland_country ON iris_core.peatland (country_code);
CREATE INDEX idx_core_screening_layer_country ON iris_core.screening_layer (country_code);
CREATE INDEX idx_core_source_run_country ON iris_core.source_run (country_code);


-- Foreign keys on the evidence junction table

CREATE INDEX idx_core_evidence_parcel_id ON iris_core.evidence (parcel_id);
CREATE INDEX idx_core_evidence_source_run_id ON iris_core.evidence (source_run_id);
CREATE INDEX idx_core_evidence_country ON iris_core.evidence (country_code);