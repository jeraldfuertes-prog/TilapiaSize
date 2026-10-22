import psycopg
from psycopg.rows import dict_row

from .config import settings


def get_connection():
    """Create a PostgreSQL connection using DATABASE_URL."""
    return psycopg.connect(
        settings.database_url,
        row_factory=dict_row,
    )


def ping_database() -> bool:
    """Return True when PostgreSQL accepts a simple query."""
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
        return True
    except psycopg.Error:
        return False
