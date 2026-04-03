from fastapi import APIRouter, HTTPException, Body
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from pathlib import Path
from datetime import datetime, timedelta
import json, uuid, time

router = APIRouter()

# ── File persistence ──────────────────────────────────────────────────────────
_DIR = Path(__file__).parent

def _load(filename: str) -> list:
    p = _DIR / filename
    if p.exists():
        try:
            with open(p, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return []

def _save(filename: str, data: list) -> None:
    with open(_DIR / filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# ── Token helpers ─────────────────────────────────────────────────────────────

def _gen_referral_token(referral_id: str) -> str:
    expire = int((datetime.utcnow() + timedelta(hours=24)).timestamp() * 1000)
    return f"REFQR::{referral_id}::{expire}"

def _parse_referral_token(token: str) -> str:
    parts = token.strip().split("::")
    if parts[0] != "REFQR" or len(parts) < 2:
        raise HTTPException(status_code=400, detail="Invalid referral QR token.")
    if len(parts) >= 3:
        expire = int(parts[2])
        if int(time.time() * 1000) > expire:
            raise HTTPException(status_code=400, detail="Referral QR has expired.")
    return parts[1]

def _gen_booking_token(booking_id: str) -> str:
    expire = int((datetime.utcnow() + timedelta(days=7)).timestamp() * 1000)
    return f"TICKET::{booking_id}::{expire}"

def _parse_booking_token(token: str) -> str:
    parts = token.strip().split("::")
    if parts[0] != "TICKET" or len(parts) < 2:
        raise HTTPException(status_code=400, detail="Invalid ticket token.")
    if len(parts) >= 3:
        expire = int(parts[2])
        if int(time.time() * 1000) > expire:
            raise HTTPException(status_code=400, detail="Ticket has expired.")
    return parts[1]

# ── AI insight builder ────────────────────────────────────────────────────────
def _build_ai_insight(referral: dict) -> dict:
    diag  = referral.get("diagnosis", "").lower()
    tests = ", ".join(referral.get("tests", [])).lower()
    priority = "medium"
    key_points = []

    if any(w in diag for w in ["emergency", "critical", "severe", "cardiac"]):
        priority = "critical"
    elif any(w in diag for w in ["fever", "infection", "typhoid", "viral"]):
        priority = "high"
    elif any(w in diag for w in ["follow", "monitor", "check"]):
        priority = "low"

    n_tests = len(referral.get("tests", []))
    n_meds  = len(referral.get("medicines", []))
    if n_tests: key_points.append(f"{n_tests} diagnostic test(s) ordered")
    if n_meds:  key_points.append(f"{n_meds} medication(s) prescribed")
    if "blood" in tests:   key_points.append("Blood panel required — fasting may be needed")
    if "culture" in tests: key_points.append("Culture test — results take 48–72 hrs")
    key_points.append(f"Referred by {referral.get('doctor_name','Doctor')} ({referral.get('doctor_specialization','')})")

    action_map = {
        "critical": "Immediate attention required — report to emergency desk first.",
        "high":     "Complete tests today — bring this QR ticket to reception.",
        "medium":   "Schedule within 48 hours. Carry previous reports if available.",
        "low":      "Can be done at your convenience. Carry doctor prescription.",
    }
    return {
        "summary": f"Patient requires {referral.get('type','lab')} services for: {referral.get('diagnosis','')}. {referral.get('reason','')}.",
        "priority": priority,
        "key_points": key_points,
        "recommended_action": action_map[priority],
    }

# ── Pydantic models ───────────────────────────────────────────────────────────

class CreateReferralRequest(BaseModel):
    patient_id: str
    patient_name: str
    patient_age: int
    patient_gender: str
    patient_blood_group: str = "Unknown"
    diagnosis: str
    notes: str = ""
    medicines: List[str] = []
    tests: List[str] = []
    reason: str
    type: str  # lab | hospital | specialist | emergency

class CreateBookingRequest(BaseModel):
    referral_id: str
    type: str
    provider_id: str
    date: str
    time_slot: str

class ScanTokenRequest(BaseModel):
    token: str

class CompleteBookingRequest(BaseModel):
    booking_id: str

# ── Provider data ─────────────────────────────────────────────────────────────
PROVIDERS = [
    {"id":"p1","name":"City Diagnostics Lab",    "type":"lab",       "address":"12 MG Road, Sector 4","rating":4.7,"distance_km":1.2,"available_slots":["09:00 AM","11:00 AM","02:00 PM","04:00 PM"]},
    {"id":"p2","name":"MediLab Plus",            "type":"lab",       "address":"45 Green Park, Block B","rating":4.5,"distance_km":2.8,"available_slots":["08:00 AM","10:00 AM","03:00 PM"]},
    {"id":"p3","name":"Apollo Diagnostics",      "type":"lab",       "address":"78 Nehru Nagar","rating":4.9,"distance_km":4.1,"available_slots":["09:30 AM","12:00 PM","05:00 PM"]},
    {"id":"h1","name":"City General Hospital",   "type":"hospital",  "address":"1 Hospital Road, Civil Lines","rating":4.6,"distance_km":3.0,"available_slots":["10:00 AM","02:00 PM","04:30 PM"]},
    {"id":"h2","name":"LifeCare Medical Centre", "type":"hospital",  "address":"23 Park Avenue","rating":4.4,"distance_km":5.5,"available_slots":["09:00 AM","01:00 PM"]},
    {"id":"s1","name":"Dr. Sharma - Cardiologist","type":"specialist","address":"Sector 6, Medical Hub","rating":4.8,"distance_km":2.0,"available_slots":["11:00 AM","03:00 PM","05:30 PM"]},
    {"id":"s2","name":"Dr. Mehta - Neurologist", "type":"specialist","address":"88 Lake View Complex","rating":4.7,"distance_km":6.2,"available_slots":["10:30 AM","02:30 PM"]},
]

# ── Referral endpoints ────────────────────────────────────────────────────────

@router.post("/create")
def create_referral(req: CreateReferralRequest = Body(...)) -> Dict[str, Any]:
    referrals = _load("referrals.json")
    ref_id = f"ref-{uuid.uuid4().hex[:8]}"
    ref = {
        "id": ref_id,
        "patient_id": req.patient_id,
        "patient_name": req.patient_name,
        "patient_age": req.patient_age,
        "patient_gender": req.patient_gender,
        "patient_blood_group": req.patient_blood_group,
        "doctor_id": "doc-1",
        "doctor_name": "Dr. Anil Kumar",
        "doctor_specialization": "General Physician",
        "diagnosis": req.diagnosis,
        "notes": req.notes,
        "medicines": req.medicines,
        "tests": req.tests,
        "reason": req.reason,
        "type": req.type,
        "created_at": datetime.utcnow().isoformat(),
        "expires_at": (datetime.utcnow() + timedelta(hours=24)).isoformat(),
    }
    referrals.insert(0, ref)
    _save("referrals.json", referrals)
    return ref


@router.post("/generate-qr")
def generate_referral_qr(referral_id: str = Body(..., embed=True)) -> Dict[str, Any]:
    referrals = _load("referrals.json")
    ref = next((r for r in referrals if r["id"] == referral_id), None)
    if not ref:
        raise HTTPException(status_code=404, detail="Referral not found.")
    token = _gen_referral_token(referral_id)
    qr_record = {
        "id": f"qr-{uuid.uuid4().hex[:8]}",
        "referral_id": referral_id,
        "token": token,
        "expires_at": (datetime.utcnow() + timedelta(hours=24)).isoformat(),
    }
    tokens = _load("referral_tokens.json")
    tokens.insert(0, qr_record)
    _save("referral_tokens.json", tokens)
    return qr_record


@router.post("/scan")
def scan_referral_qr(req: ScanTokenRequest) -> Dict[str, Any]:
    referral_id = _parse_referral_token(req.token)
    referrals = _load("referrals.json")
    ref = next((r for r in referrals if r["id"] == referral_id), None)
    if not ref:
        raise HTTPException(status_code=404, detail="Referral not found or expired.")
    return {"referral": ref, "ai_insight": _build_ai_insight(ref)}


@router.get("/list")
def list_referrals() -> List[Dict[str, Any]]:
    return _load("referrals.json")

# ── Provider endpoints ────────────────────────────────────────────────────────

@router.get("/providers")
def get_providers(type: Optional[str] = None) -> List[Dict[str, Any]]:
    if type:
        return [p for p in PROVIDERS if p["type"] == type]
    return PROVIDERS

# ── Booking endpoints ─────────────────────────────────────────────────────────

@router.post("/booking/create")
def create_booking(req: CreateBookingRequest = Body(...)) -> Dict[str, Any]:
    referrals = _load("referrals.json")
    ref = next((r for r in referrals if r["id"] == req.referral_id), None)
    if not ref:
        raise HTTPException(status_code=404, detail="Referral not found.")
    provider = next((p for p in PROVIDERS if p["id"] == req.provider_id), None)
    if not provider:
        raise HTTPException(status_code=404, detail="Provider not found.")

    amount = 850 if req.type == "lab" else 1200 if req.type == "specialist" else 500
    booking_id = f"bk-{uuid.uuid4().hex[:8]}"

    booking = {
        "id": booking_id,
        "referral_id": req.referral_id,
        "type": req.type,
        "provider_id": req.provider_id,
        "provider_name": provider["name"],
        "provider_address": provider["address"],
        "patient_name": ref["patient_name"],
        "date": req.date,
        "time_slot": req.time_slot,
        "status": "confirmed",
        "amount": amount,
        "created_at": datetime.utcnow().isoformat(),
    }
    bookings = _load("bookings.json")
    bookings.insert(0, booking)
    _save("bookings.json", bookings)

    # Generate ticket
    ticket_token = _gen_booking_token(booking_id)
    ticket = {
        "id": f"tk-{uuid.uuid4().hex[:8]}",
        "booking_id": booking_id,
        "patient_name": ref["patient_name"],
        "booking_type": req.type,
        "provider_name": provider["name"],
        "provider_address": provider["address"],
        "date": req.date,
        "time_slot": req.time_slot,
        "qr_token": ticket_token,
        "status": "active",
        "created_at": datetime.utcnow().isoformat(),
    }
    tickets = _load("tickets.json")
    tickets.insert(0, ticket)
    _save("tickets.json", tickets)

    # Record earning (10% commission)
    commission = round(amount * 0.1, 2)
    earning = {
        "id": f"earn-{uuid.uuid4().hex[:8]}",
        "booking_id": booking_id,
        "patient_name": ref["patient_name"],
        "provider_name": provider["name"],
        "booking_type": req.type,
        "total_amount": amount,
        "commission_rate": 10,
        "commission_amount": commission,
        "status": "pending",
        "created_at": datetime.utcnow().isoformat(),
    }
    earnings = _load("earnings.json")
    earnings.insert(0, earning)
    _save("earnings.json", earnings)

    return {"booking": booking, "ticket": ticket}


@router.post("/ticket/scan")
def scan_ticket(req: ScanTokenRequest) -> Dict[str, Any]:
    booking_id = _parse_booking_token(req.token)
    tickets = _load("tickets.json")
    ticket = next((t for t in tickets if t["booking_id"] == booking_id), None)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found.")
    return ticket


@router.post("/booking/complete")
def complete_booking(req: CompleteBookingRequest) -> Dict[str, Any]:
    bookings = _load("bookings.json")
    for b in bookings:
        if b["id"] == req.booking_id:
            b["status"] = "completed"
    _save("bookings.json", bookings)

    tickets = _load("tickets.json")
    for t in tickets:
        if t["booking_id"] == req.booking_id:
            t["status"] = "used"
    _save("tickets.json", tickets)

    earnings = _load("earnings.json")
    for e in earnings:
        if e["booking_id"] == req.booking_id:
            e["status"] = "paid"
    _save("earnings.json", earnings)

    return {"status": "completed", "booking_id": req.booking_id}

# ── Earnings endpoint ─────────────────────────────────────────────────────────

@router.get("/earnings")
def get_earnings() -> Dict[str, Any]:
    earnings = _load("earnings.json")
    bookings = _load("bookings.json")

    total_revenue    = sum(e["total_amount"]    for e in earnings)
    total_commission = sum(e["commission_amount"] for e in earnings)
    pending          = sum(e["commission_amount"] for e in earnings if e["status"] == "pending")
    paid             = sum(e["commission_amount"] for e in earnings if e["status"] == "paid")

    return {
        "total_bookings":     len(bookings),
        "total_revenue":      total_revenue,
        "total_commission":   total_commission,
        "pending_commission": pending,
        "paid_commission":    paid,
        "recent":             earnings[:10],
    }
