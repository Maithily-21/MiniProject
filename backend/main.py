"""
main.py - FastAPI application entry point
Configures middleware, mounts static file serving, registers routers,
and initialises the database on startup.
"""

import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from core.config import settings
from database.db import init_db
from routes.auth     import router as auth_router
from routes.analysis import router as analysis_router


# ─── Lifespan (startup / shutdown) ────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Runs once on startup:
      - Creates SQLite tables if they don't exist
      - Ensures upload/output directories are present
    """
    print(f"DEBUG: 🦷 {settings.APP_NAME} v{settings.APP_VERSION} starting ...")
    init_db()
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    os.makedirs(settings.OUTPUT_DIR, exist_ok=True)
    print("DEBUG: ✅ Database initialised | Storage directories ready")
    yield
    print("🔴 Application shutting down")


# ─── App Instantiation ────────────────────────────────────────────────────────

app = FastAPI(
    title       = settings.APP_NAME,
    version     = settings.APP_VERSION,
    description = (
        "Production-ready REST API for intraoral dental image analysis. "
        "Performs teeth segmentation, alignment scoring, symmetry scoring, "
        "cavity detection and gum disease classification using deep learning."
    ),
    docs_url    = "/docs",
    redoc_url   = "/redoc",
    lifespan    = lifespan,
)


# ─── CORS ─────────────────────────────────────────────────────────────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins     = ["*"],      # Restrict to specific origins in production
    allow_credentials = True,
    allow_methods     = ["*"],
    allow_headers     = ["*"],
)


# ─── Static Files (serve uploaded images and masks) ───────────────────────────

# Accessible at  GET /files/uploads/<filename>
#                GET /files/outputs/<filename>
app.mount(
    "/files",
    StaticFiles(directory="."),     # serves from project root downwards
    name="files",
)


# ─── Routers ──────────────────────────────────────────────────────────────────

app.include_router(auth_router)
app.include_router(analysis_router)


# ─── Health Check ─────────────────────────────────────────────────────────────

@app.get("/", tags=["Health"], summary="Health check")
def root():
    """Returns service status and version info."""
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status":  "running",
        "docs":    "/docs",
    }


@app.get("/health", tags=["Health"], summary="Readiness probe")
def health():
    """Kubernetes / load-balancer readiness endpoint."""
    return {"status": "ok"}


# ─── Global Exception Handler ─────────────────────────────────────────────────

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Catch-all handler so unhandled exceptions return a clean JSON error
    instead of an HTML 500 page.
    """
    return JSONResponse(
        status_code=500,
        content={"detail": f"Internal server error: {str(exc)}"},
    )


# ─── Dev entry point ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host    = "0.0.0.0",
        port    = 8000,
        reload  = settings.DEBUG,
        workers = 1,
    )
