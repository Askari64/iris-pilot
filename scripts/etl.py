import psycopg

# Connection string to your local Docker container
DB_URI = "dbname=iris user=postgres password=postgres host=localhost port=5432"

def run_etl_pipeline():
    """Promotes all spatial entities from staging to core, applying spatial and type fixes."""
    
    with psycopg.connect(DB_URI) as conn:
        with conn.cursor() as cur:
            print("Starting ELT Pipeline...")
            
            # 1. Promote Parcels (Polygons)
            cur.execute("""
                INSERT INTO iris_core.parcel (country_code, region_code, source_id, source_date, geom)
                SELECT 
                    country_code, region_code, source_id,
                    CASE WHEN source_date LIKE '%.%' THEN TO_DATE(source_date, 'DD.MM.YYYY') ELSE TO_DATE(source_date, 'YYYY/MM/DD') END,
                    ST_Multi(ST_SetSRID(geom, 4326))
                FROM iris_staging.parcel
                WHERE country_code IS NOT NULL
                ON CONFLICT (country_code, source_id) DO UPDATE SET source_date = EXCLUDED.source_date, geom = EXCLUDED.geom;
            """)
            print(f"Processed {cur.rowcount} parcels.")

            # 2. Promote Substations (Points - no ST_Multi required)
            cur.execute("""
                INSERT INTO iris_core.substation (country_code, region_code, source_id, source_date, geom)
                SELECT 
                    country_code, region_code, source_id,
                    CASE WHEN source_date LIKE '%.%' THEN TO_DATE(source_date, 'DD.MM.YYYY') ELSE TO_DATE(source_date, 'YYYY/MM/DD') END,
                    ST_SetSRID(geom, 4326)
                FROM iris_staging.substation
                WHERE country_code IS NOT NULL
                ON CONFLICT (country_code, source_id) DO UPDATE SET source_date = EXCLUDED.source_date, geom = EXCLUDED.geom;
            """)
            print(f"Processed {cur.rowcount} substations.")

            # 3. Promote Peatlands (Polygons)
            cur.execute("""
                INSERT INTO iris_core.peatland (country_code, region_code, source_id, source_date, geom)
                SELECT 
                    country_code, region_code, source_id,
                    CASE WHEN source_date LIKE '%.%' THEN TO_DATE(source_date, 'DD.MM.YYYY') ELSE TO_DATE(source_date, 'YYYY/MM/DD') END,
                    ST_Multi(ST_SetSRID(geom, 4326))
                FROM iris_staging.peatland
                WHERE country_code IS NOT NULL
                ON CONFLICT (country_code, source_id) DO UPDATE SET source_date = EXCLUDED.source_date, geom = EXCLUDED.geom;
            """)
            print(f"Processed {cur.rowcount} peatlands.")

            # 4. Promote Screening Layers (Polygons - compound unique key includes layer_name)
            cur.execute("""
                INSERT INTO iris_core.screening_layer (country_code, region_code, source_id, layer_name, source_date, geom)
                SELECT 
                    country_code, region_code, source_id, layer_name,
                    CASE WHEN source_date LIKE '%.%' THEN TO_DATE(source_date, 'DD.MM.YYYY') ELSE TO_DATE(source_date, 'YYYY/MM/DD') END,
                    ST_Multi(ST_SetSRID(geom, 4326))
                FROM iris_staging.screening_layer
                WHERE country_code IS NOT NULL
                ON CONFLICT (country_code, source_id) DO UPDATE SET source_date = EXCLUDED.source_date, geom = EXCLUDED.geom;
            """)
            print(f"Processed {cur.rowcount} screening layers.")

            # Commit the transaction
            conn.commit()
            print("ETL complete! All staging data successfully promoted to core.")

if __name__ == "__main__":
    run_etl_pipeline()