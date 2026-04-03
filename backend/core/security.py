"""
core/security.py - JWT token creation, verification, and password hashing
Handles all authentication and authorization logic
"""

from datetime import datetime, timedelta
from typing import Optional, Union

from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from core.config import settings

# ─── Password Hashing ────────────────────────────────────────────────────────

# bcrypt context for hashing and verifying passwords
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plaintext password against its bcrypt hash."""
    return pwd_context.verify(plain_password, hashed_password)


# ─── JWT Token Handling ───────────────────────────────────────────────────────

# OAuth2 scheme: expects Bearer token in Authorization header
# Set auto_error=False to allow guest access (token can be None)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login", auto_error=False)


def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    Create a signed JWT access token.

    Args:
        data: Payload dict (typically contains 'sub': user_id as string)
        expires_delta: Optional custom token lifetime

    Returns:
        Encoded JWT string
    """
    to_encode = data.copy()

    # Set expiration time
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Decode and validate a JWT token.

    Returns:
        Decoded payload dict or None if invalid/expired
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        return None


# ─── FastAPI Dependency ───────────────────────────────────────────────────────

def get_current_user_id(token: Optional[str] = Depends(oauth2_scheme)) -> int:
    """
    FastAPI dependency that extracts and validates the current user's ID.
    DEVELOPMENT OVERRIDE: Returns user_id 1 if token is missing or invalid,
    as requested for initial dashboard testing.
    """
    if token is None:
        return 1  # Default guest user ID

    payload = decode_access_token(token)
    if payload is None:
        return 1

    # 'sub' field stores user_id as string
    user_id_str: Optional[str] = payload.get("sub")
    if user_id_str is None:
        return 1

    try:
        return int(user_id_str)
    except (ValueError, TypeError):
        return 1
