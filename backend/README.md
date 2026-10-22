# TilapiaSize Backend

FastAPI is the REST API layer for TilapiaSize. Flutter communicates with this backend; PostgreSQL is never accessed directly by Flutter.

## Current endpoints

- `GET /api/health` — API and PostgreSQL connectivity
- `POST /api/auth/register` — create a Fish Farmer, Aquaculture Worker, or Fish Vendor account
- `POST /api/auth/login` — authenticate and receive a JWT access token
- `GET /api/auth/me` — return the authenticated user

Passwords are hashed with Argon2 through `pwdlib`. JWT access tokens are signed with the server-side `JWT_SECRET`.

## Local setup

1. Create a PostgreSQL database named `tilapiasize`.
2. From `backend/`, create and activate a virtual environment.
3. Install dependencies:

   `pip install -r requirements.txt`

4. Copy `.env.example` to `.env`.
5. Update `DATABASE_URL` with your PostgreSQL username/password.
6. Replace `JWT_SECRET` with a long random value.
7. Start the API:

   `uvicorn main:app --reload`

The API runs at `http://127.0.0.1:8000` by default. Swagger documentation is available at `http://127.0.0.1:8000/docs`.

The minimum `users` table is created automatically when the API starts and PostgreSQL is reachable.

## Flutter connection

For Flutter Web on the same computer, the default API URL is:

`http://127.0.0.1:8000/api`

You can override it at runtime:

`flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api`

For an Android emulator, use the host mapping instead:

`flutter run -d <device> --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`

Grading/history API endpoints and YOLO inference are separate implementation steps.
