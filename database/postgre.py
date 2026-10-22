"""Development utility for checking the TilapiaSize PostgreSQL connection."""

import os

import psycopg


DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/tilapiasize",
)


def main() -> None:
    try:
        with psycopg.connect(DATABASE_URL) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT version()")
                version = cursor.fetchone()
                print("PostgreSQL connection successful.")
                print(version[0] if version else "Version unavailable.")
    except psycopg.Error as error:
        print(f"PostgreSQL connection failed: {error}")


if __name__ == "__main__":
    main()
