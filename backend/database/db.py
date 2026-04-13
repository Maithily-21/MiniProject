"""
database/db.py - SQLAlchemy database engine and session management
Provides async-compatible synchronous session for FastAPI dependency injection
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator

from core.config import settings

# ─── Engine Configuration ──────────────────────────────────────────────────

# connect_args is SQLite-specific: allows concurrent requests from multiple threads
engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False},
    echo=settings.DEBUG        # Log SQL statements in development
)

# ─── Session Factory ───────────────────────────────────────────────────────

# autocommit=False: we control transactions manually
# autoflush=False: prevent automatic flush before queries (avoids surprises)
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# ─── Base Class ────────────────────────────────────────────────────────────

# All ORM models will inherit from this Base class
Base = declarative_base()


# ─── Dependency ────────────────────────────────────────────────────────────

def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency that provides a database session per request.
    Ensures the session is always closed after the request completes,
    even if an exception is raised.

    Usage:
        @router.get("/example")
        def example(db: Session = Depends(get_db)):
            ...
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """
    Initialize the database and seed a default test user.
    """
    from database import models
    Base.metadata.create_all(bind=engine)
    
    # Seed a default test user (ID 1) for rapid frontend testing
    session = SessionLocal()
    try:
        user = session.query(models.User).filter(models.User.email == "test@provident.ai").first()
        if not user:
            from core.security import hash_password
            test_user = models.User(
                email="test@provident.ai",
                password=hash_password("password"),
                is_active=True
            )
            session.add(test_user)
            print("🌱 Default test user seeded (test@provident.ai)")
            
        # Admin user as requested in screenshot
        admin_user = session.query(models.User).filter(models.User.email == "admin@gmail.com").first()
        if not admin_user:
            from core.security import hash_password
            new_admin = models.User(
                email="admin@gmail.com",
                password=hash_password("password"),
                is_active=True
            )
            session.add(new_admin)
            print("🌱 Admin test user seeded (admin@gmail.com)")
            
        session.commit()
    except Exception as e:
        print(f"⚠️ Could not seed test user: {e}")
        session.rollback()
    finally:
        session.close()
