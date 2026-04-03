"""
QR Token utilities — Fernet symmetric encryption for patient QR tokens.
JWT is used separately for doctor authentication (handled by auth router).
"""

import json
import base64
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional

from cryptography.fernet import Fernet, InvalidToken

# ── Key management ────────────────────────────────────────────────────────────
# In production: load from environment variable / secrets manager.
# The key MUST be 32 url-safe base64-encoded bytes.
_RAW_SECRET = b"medcard_qr_secret_key_32bytes!!!"   # exactly 32 bytes
_FERNET_KEY = base64.urlsafe_b64encode(_RAW_SECRET)
_fernet = Fernet(_FERNET_KEY)


# ── Token payload ─────────────────────────────────────────────────────────────

def create_qr_token(patient_id: int, expires_minutes: int = 10) -> tuple[str, datetime]:
    """
    Create a signed, encrypted QR token embedding patient_id + expiry.
    Returns (encrypted_token_str, expires_at).
    """
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=expires_minutes)
    payload = {
        "patient_id": patient_id,
        "expires_at": expires_at.isoformat(),
        "nonce": secrets.token_hex(8),
    }
    raw = json.dumps(payload).encode()
    token = _fernet.encrypt(raw).decode()
    return token, expires_at


def decrypt_qr_token(token: str) -> Optional[dict]:
    """
    Decrypt and validate a QR token.
    Returns payload dict or raises ValueError on invalid/expired token.
    """
    try:
        raw = _fernet.decrypt(token.encode())
        payload = json.loads(raw)
    except (InvalidToken, json.JSONDecodeError, Exception) as e:
        raise ValueError(f"Invalid QR token: {e}")

    expires_at = datetime.fromisoformat(payload["expires_at"])
    if datetime.now(timezone.utc) > expires_at:
        raise ValueError("QR token has expired")

    return payload


def mask_phone(phone: str) -> str:
    """Return masked phone: keeps last 4 digits, masks rest with *."""
    digits = "".join(c for c in phone if c.isdigit())
    return f"****{digits[-4:]}" if len(digits) >= 4 else "****"
