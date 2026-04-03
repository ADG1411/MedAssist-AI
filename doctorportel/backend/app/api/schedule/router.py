from fastapi import APIRouter, Body, HTTPException
from typing import List, Dict, Optional
from datetime import datetime, timedelta, time as dt_time
import uuid

router = APIRouter()

# ──────────────────────────────────────────────
# In-memory mock store (replace with DB later)
# ──────────────────────────────────────────────

MOCK_WEEKLY_SCHEDULE: Dict = {
    "slot_duration": 30,
    "days": [
        {"day": "Monday",    "enabled": True,  "start_time": "09:00", "end_time": "18:00", "break_enabled": True,  "break_start": "13:00", "break_end": "14:00"},
        {"day": "Tuesday",   "enabled": True,  "start_time": "09:00", "end_time": "18:00", "break_enabled": True,  "break_start": "13:00", "break_end": "14:00"},
        {"day": "Wednesday", "enabled": True,  "start_time": "09:00", "end_time": "18:00", "break_enabled": True,  "break_start": "13:00", "break_end": "14:00"},
        {"day": "Thursday",  "enabled": True,  "start_time": "09:00", "end_time": "18:00", "break_enabled": True,  "break_start": "13:00", "break_end": "14:00"},
        {"day": "Friday",    "enabled": True,  "start_time": "09:00", "end_time": "18:00", "break_enabled": True,  "break_start": "13:00", "break_end": "14:00"},
        {"day": "Saturday",  "enabled": True,  "start_time": "10:00", "end_time": "14:00", "break_enabled": False, "break_start": "",      "break_end": ""},
        {"day": "Sunday",    "enabled": False, "start_time": "09:00", "end_time": "18:00", "break_enabled": False, "break_start": "",      "break_end": ""},
    ]
}

MOCK_OVERRIDES: List[Dict] = []


# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

def _parse_time(t: str) -> dt_time:
    h, m = map(int, t.split(":"))
    return dt_time(h, m)


def _generate_slots(start: str, end: str, duration_min: int,
                    break_start: Optional[str], break_end: Optional[str]) -> List[Dict]:
    slots = []
    current = datetime.combine(datetime.today(), _parse_time(start))
    end_dt  = datetime.combine(datetime.today(), _parse_time(end))
    bs = datetime.combine(datetime.today(), _parse_time(break_start)) if break_start else None
    be = datetime.combine(datetime.today(), _parse_time(break_end))   if break_end   else None

    while current < end_dt:
        slot_end = current + timedelta(minutes=duration_min)
        is_break = bool(bs and be and current >= bs and current < be)
        slots.append({
            "time":         current.strftime("%H:%M"),
            "display_time": current.strftime("%I:%M %p").lstrip("0"),
            "is_break":     is_break,
            "available":    not is_break,
        })
        current = slot_end

    return slots


# ──────────────────────────────────────────────
# Weekly Schedule Endpoints
# ──────────────────────────────────────────────

@router.get("/weekly", response_model=Dict)
def get_weekly_schedule():
    """Return the doctor's current weekly availability schedule."""
    return MOCK_WEEKLY_SCHEDULE


@router.post("/weekly", response_model=Dict)
def save_weekly_schedule(schedule: Dict = Body(...)):
    """Persist the doctor's weekly availability schedule."""
    MOCK_WEEKLY_SCHEDULE.clear()
    MOCK_WEEKLY_SCHEDULE.update(schedule)
    return {"message": "Schedule saved successfully", "schedule": MOCK_WEEKLY_SCHEDULE}


# ──────────────────────────────────────────────
# Slot Generation
# ──────────────────────────────────────────────

@router.get("/slots/{day}", response_model=List[Dict])
def get_slots_for_day(day: str):
    """Auto-generate appointment slots for a specific weekday."""
    day_data = next(
        (d for d in MOCK_WEEKLY_SCHEDULE["days"] if d["day"].lower() == day.lower()),
        None
    )
    if not day_data:
        raise HTTPException(status_code=404, detail=f"Day '{day}' not found in schedule")
    if not day_data["enabled"]:
        return []

    duration = MOCK_WEEKLY_SCHEDULE.get("slot_duration", 30)
    break_start = day_data.get("break_start") if day_data.get("break_enabled") else None
    break_end   = day_data.get("break_end")   if day_data.get("break_enabled") else None

    return _generate_slots(
        day_data["start_time"],
        day_data["end_time"],
        duration,
        break_start,
        break_end
    )


@router.get("/slots", response_model=Dict)
def get_all_slots():
    """Auto-generate slots for every enabled weekday."""
    duration = MOCK_WEEKLY_SCHEDULE.get("slot_duration", 30)
    result: Dict[str, List[Dict]] = {}

    for d in MOCK_WEEKLY_SCHEDULE["days"]:
        if not d["enabled"]:
            result[d["day"]] = []
            continue
        break_start = d.get("break_start") if d.get("break_enabled") else None
        break_end   = d.get("break_end")   if d.get("break_enabled") else None
        result[d["day"]] = _generate_slots(
            d["start_time"], d["end_time"], duration, break_start, break_end
        )

    return result


# ──────────────────────────────────────────────
# Special Day Overrides
# ──────────────────────────────────────────────

@router.get("/overrides", response_model=List[Dict])
def get_overrides():
    """Return all special-day overrides (holidays / extended hours)."""
    return MOCK_OVERRIDES


@router.post("/overrides", response_model=Dict)
def add_override(override: Dict = Body(...)):
    """Add a special-day override for a specific calendar date."""
    override["id"] = str(uuid.uuid4())
    MOCK_OVERRIDES.append(override)
    return {"message": "Override added", "override": override}


@router.delete("/overrides/{override_id}", response_model=Dict)
def delete_override(override_id: str):
    """Remove a special-day override by its ID."""
    global MOCK_OVERRIDES
    before = len(MOCK_OVERRIDES)
    MOCK_OVERRIDES = [o for o in MOCK_OVERRIDES if o["id"] != override_id]
    if len(MOCK_OVERRIDES) == before:
        raise HTTPException(status_code=404, detail="Override not found")
    return {"message": "Override deleted"}


# ──────────────────────────────────────────────
# Emergency Slot Override
# ──────────────────────────────────────────────

@router.post("/emergency-slots", response_model=Dict)
def add_emergency_slots(payload: Dict = Body(...)):
    """Temporarily open extra slots for emergency appointments."""
    day   = payload.get("day", "")
    start = payload.get("start_time", "")
    end   = payload.get("end_time", "")
    reason = payload.get("reason", "Emergency")

    if not day or not start or not end:
        raise HTTPException(status_code=400, detail="day, start_time and end_time are required")

    slots = _generate_slots(start, end, MOCK_WEEKLY_SCHEDULE.get("slot_duration", 30), None, None)
    return {
        "message": f"Emergency slots added for {day}",
        "day": day,
        "reason": reason,
        "slots": slots
    }
