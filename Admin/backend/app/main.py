from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import dashboard, users, ai_control, cases

app = FastAPI(title="MedAssist AI Admin Portal", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(dashboard.router, prefix="/admin/dashboard", tags=["Dashboard"])
app.include_router(users.router, prefix="/admin/users", tags=["Users"])
app.include_router(cases.router, prefix="/admin/cases", tags=["Cases"])
app.include_router(ai_control.router, prefix="/admin/ai", tags=["AI Control"])

@app.get("/admin/health")
async def health_check():
    return {"status": "ok", "message": "Admin portal is running"}
