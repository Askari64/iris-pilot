import pytest
import psycopg
from psycopg.errors import UniqueViolation, NotNullViolation

DB_URI = "dbname=iris user=postgres password=postgres host=localhost port=5432"

DUMMY_MULTIPOLYGON = "ST_Multi(ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))', 4326))"

@pytest.fixture(scope="module")
def db_cursor():
    """Sets up a database connection for the tests to use."""
    with psycopg.connect(DB_URI, autocommit=True) as conn:
        with conn.cursor() as cur:
            yield cur

def test_srid_is_strictly_4326(db_cursor):
    """Verifies that PostGIS is strictly enforcing GPS coordinates (SRID 4326)."""
    db_cursor.execute("SELECT Find_SRID('iris_core', 'parcel', 'geom');")
    srid = db_cursor.fetchone()[0]
    assert srid == 4326, f"Expected SRID 4326, but got {srid}"

def test_country_code_not_null_constraint(db_cursor):
    """Verifies the database rejects records missing a country_code."""
    with pytest.raises(NotNullViolation):
        db_cursor.execute(f"""
            INSERT INTO iris_core.parcel (country_code, source_id, source_date, geom)
            VALUES (NULL, 'TEST-ID-999', '2024-01-01', {DUMMY_MULTIPOLYGON});
        """)

def test_compound_unique_constraint(db_cursor):
    """Verifies the (country_code, source_id) rule blocks duplicate IDs within the same country."""
    with pytest.raises(UniqueViolation):
        db_cursor.execute(f"""
            INSERT INTO iris_core.parcel (country_code, source_id, source_date, geom)
            VALUES ('GB', 'PARCEL-GB-01', '2024-01-01', {DUMMY_MULTIPOLYGON});
        """)

def test_spatial_distance_calculation(db_cursor):
    """Verifies that PostGIS ST_Distance math matches verification metrics."""
    db_cursor.execute("""
        SELECT ROUND(ST_Distance(p.geom::geography, s.geom::geography)::numeric, 2)
        FROM iris_core.parcel p
        JOIN iris_core.substation s ON p.country_code = s.country_code
        WHERE p.source_id = 'PARCEL-GB-02' AND s.source_id = 'SUB-GB-01';
    """)
    distance = float(db_cursor.fetchone()[0])
    assert distance == 7375.55