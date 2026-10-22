from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import ping_database

app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="REST API for TilapiaSize automated fish size grading.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health_check():
    """Basic service and PostgreSQL connectivity check."""
    database_ok = ping_database()
    return {
        "status": "ok" if database_ok else "degraded",
        "service": settings.app_name,
        "database": "connected" if database_ok else "unavailable",
    }
