import os

with open("app/api/chat/router.py", "a", encoding="utf-8") as f:
    f.write("""

class ValidateRequest(BaseModel):
    message: str

class ValidateResponse(BaseModel):
    isMedical: str

@router.post("/validate", response_model=ValidateResponse)
async def validate_query(req: ValidateRequest):
    \"\"\"Live typing validation endpoint to check if query is medical.\"\"\"
    if len(req.message.strip()) < 3:
        return ValidateResponse(isMedical="YES") # Allow short inputs during typing

    classification_prompt = (
        "You are a strict classifier.\\n"
        "ONLY answer:\\n"
        "YES -> if question is medical/health related\\n"
        "NO -> if not\\n"
        "No explanation.\\n\\n"
        f"Question: {req.message}"
    )
    is_med_check = await generate_text(classification_prompt)
    if "no" in (is_med_check or "").lower():
        return ValidateResponse(isMedical="NO")
    return ValidateResponse(isMedical="YES")
""")
