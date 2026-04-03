from fastapi import APIRouter, Body
from pydantic import BaseModel
from typing import Optional, List

router = APIRouter()


# ── Request / Response Models ────────────────────────────────────────────────

class BioRequest(BaseModel):
    name: str
    degree: Optional[str] = ""
    specialization: Optional[str] = ""
    experience_years: Optional[int] = 0
    success_rate: Optional[str] = ""
    hospital: Optional[str] = ""
    role: Optional[str] = ""
    skills: Optional[List[str]] = []
    tone: Optional[str] = "professional"
    language: Optional[str] = "english"


class BioResponse(BaseModel):
    bio: str
    tone: str
    language: str


# ── Bio Generation Logic ─────────────────────────────────────────────────────

from app.services.ai_service import generate_text

async def _generate_bio_ai(req: BioRequest) -> str:
    system_prompt = (
        "You are an expert medical copywriter. Your task is to write a professional "
        "and compelling doctor biography based on the provided details. "
        f"The tone should be {req.tone or 'professional'} and the language must be {req.language or 'English'}. "
        "Ensure the bio highlights their expertise, experience, and commitment to patient care. "
        "Return ONLY the bio text, without greeting, quotation marks, or extra explanations."
    )
    
    prompt = (
        f"Name: {req.name or 'The Doctor'}\n"
        f"Degree: {req.degree or ''}\n"
        f"Specialization: {req.specialization or ''}\n"
        f"Experience: {req.experience_years or 0} years\n"
        f"Success Rate: {req.success_rate or ''}\n"
        f"Hospital/Clinic: {req.hospital or ''}\n"
        f"Role: {req.role or ''}\n"
        f"Skills/Expertise: {', '.join(req.skills) if req.skills else 'None specified'}"
    )
    
    return await generate_text(prompt, system_prompt)

# ── Endpoint ─────────────────────────────────────────────────────────────────

@router.post("/generate-bio", response_model=BioResponse)
async def generate_bio_endpoint(req: BioRequest = Body(...)):
    bio = await _generate_bio_ai(req)
    return BioResponse(
        bio=bio,
        tone=req.tone or "professional",
        language=req.language or "english",
    )
