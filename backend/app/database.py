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


def initialize_database() -> bool:
    """Create the minimum authentication table required by the current API."""
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS users (
                        id BIGSERIAL PRIMARY KEY,
                        name VARCHAR(120) NOT NULL,
                        email VARCHAR(255) NOT NULL UNIQUE,
                        role VARCHAR(40) NOT NULL,
                        password_hash TEXT NOT NULL,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
                    )
                    """
                )
        return True
    except psycopg.Error:
        return False
