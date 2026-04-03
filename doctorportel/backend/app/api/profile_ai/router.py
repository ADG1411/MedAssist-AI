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

def _generate_bio(req: BioRequest) -> str:
    name = req.name or "The Doctor"
    last = name.split()[-1] if name else "Doctor"
    spec = req.specialization or "medicine"
    exp = req.experience_years or 0
    hospital = req.hospital or "a leading medical institution"
    role = req.role or "Consultant"
    degree = req.degree or ""
    success = req.success_rate or ""
    skills = req.skills or []
    tone = (req.tone or "professional").lower()
    lang = (req.language or "english").lower()

    # Hindi output
    if lang == "hindi":
        success_part = f" उनकी सफलता दर {success} है।" if success else ""
        skills_part = (
            f" वे {', '.join(skills)} में विशेषज्ञता रखते हैं।"
            if skills else f" वे उन्नत {spec} उपचार और निवारक देखभाल में विशेषज्ञ हैं।"
        )
        return (
            f"{name} एक अनुभवी {spec} विशेषज्ञ हैं जिनके पास {exp} से अधिक वर्षों "
            f"का नैदानिक अनुभव है।"
            + (f" वे {degree} की उपाधि धारण करते हैं।" if degree else "")
            + f" वे वर्तमान में {hospital} में {role} के रूप में कार्यरत हैं।"
            + success_part
            + " वे रोगी-केंद्रित दृष्टिकोण के लिए जाने जाते हैं।"
            + skills_part
        ).strip()

    degree_part = f" Holding {degree}," if degree else ""
    hospital_part = f"currently serving as {role} at {hospital}"
    success_part = f" with a {success} success rate" if success else ""
    skills_part = (
        f"Areas of expertise include: {', '.join(skills)}."
        if skills else f"Specializing in advanced {spec} treatments and preventive care."
    )

    if tone == "friendly":
        return (
            f"Hi! I'm {name}, a passionate {spec} with over {exp} years of "
            f"experience helping patients live healthier lives."
            + (f" I hold {degree}." if degree else "")
            + f" I'm {hospital_part}{success_part}. I believe in making healthcare "
            f"accessible, comfortable, and personalized for every patient. "
            + skills_part
        ).strip()

    if tone == "short":
        return (
            f"{name} — {spec} specialist with {exp}+ years of experience."
            + (f" {degree_part}" if degree else "")
            + f" {hospital_part.capitalize()}{success_part}. "
            + skills_part
        ).strip()

    if tone == "detailed":
        return (
            f"{name} is a distinguished {spec} with an extensive clinical career "
            f"spanning over {exp} years."
            + (f" {degree_part} they bring exceptional academic and clinical expertise "
               f"to every patient interaction." if degree else "")
            + f" Dr. {last} is {hospital_part}{success_part}. "
            f"Throughout their career, they have demonstrated outstanding proficiency "
            f"in diagnosing and managing complex conditions. Their commitment to "
            f"evidence-based medicine and continuous medical education ensures the "
            f"highest standard of care. {skills_part} Their dedication to research "
            f"and innovation reinforces their standing as a leader in the field."
        ).strip()

    # Professional (default)
    return (
        f"{name} is a highly experienced {spec} with over {exp} years of "
        f"clinical expertise."
        + (f" They hold {degree} and are " if degree else " They are ")
        + f"{hospital_part}{success_part}. "
        f"Known for a patient-centered approach and unwavering commitment to "
        f"excellence, Dr. {last} delivers accurate diagnosis and effective "
        f"treatment. {skills_part}"
    ).strip()


# ── Endpoint ─────────────────────────────────────────────────────────────────

@router.post("/generate-bio", response_model=BioResponse)
async def generate_bio_endpoint(req: BioRequest = Body(...)):
    bio = _generate_bio(req)
    return BioResponse(
        bio=bio,
        tone=req.tone or "professional",
        language=req.language or "english",
    )
