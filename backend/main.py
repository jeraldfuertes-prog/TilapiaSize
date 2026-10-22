from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.auth import router as auth_router
from app.config import settings
from app.database import initialize_database, ping_database


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(
    title=settings.app_name,
    version="0.2.0",
    description="REST API for TilapiaSize automated fish size grading.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_origin_regex=settings.cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)


@app.get("/api/health")
def health_check():
    """Basic service and PostgreSQL connectivity check."""
    database_ok = ping_database()
    return {
        "status": "ok" if database_ok else "degraded",
        "service": settings.app_name,
        "database": "connected" if database_ok else "unavailable",
    }
