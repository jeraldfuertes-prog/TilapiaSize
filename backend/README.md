# TilapiaSize Backend

This directory contains the FastAPI REST API for TilapiaSize.

## Stack

- Python
- FastAPI
- Uvicorn
- PostgreSQL via psycopg
- Environment-based configuration

## Local setup

1. Create and activate a Python virtual environment.
2. Install dependencies:

   `pip install -r requirements.txt`

3. Copy `.env.example` to `.env` and update `DATABASE_URL`.
4. Create the PostgreSQL database named `tilapiasize` or update the URL for your chosen database.
5. Run the API from the `backend` directory:

   `uvicorn main:app --reload`

6. Open `/api/health` to verify that FastAPI is running and PostgreSQL is reachable.

## Architecture boundary

Flutter clients must communicate with this API over HTTP/HTTPS. Flutter must not contain PostgreSQL credentials or execute raw SQL directly.

Authentication/JWT, grading endpoints, image validation, YOLO inference, and final database tables will be added in later implementation commits based on the approved TilapiaSize requirements.
