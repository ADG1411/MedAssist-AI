from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

from app.api.auth.router import router as auth_router
from app.api.emergency.router import router as emergency_router
from app.api.doctors.router import router as doctors_router
from app.api.patients.router import router as patients_router
from app.api.chat.router import router as chat_router
from app.api.analytics.router import router as analytics_router
from app.api.prescriptions.router import router as prescriptions_router
from app.api.schedule.router import router as schedule_router
from app.api.profile_ai.router import router as profile_ai_router
from app.api.medcard.router import router as medcard_router
from app.api.referral.router import router as referral_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(auth_router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(emergency_router, prefix=f"{settings.API_V1_STR}/emergency", tags=["emergency"])
app.include_router(doctors_router, prefix=f"{settings.API_V1_STR}/doctors", tags=["doctors"])
app.include_router(patients_router, prefix=f"{settings.API_V1_STR}/patients", tags=["patients"])
app.include_router(chat_router, prefix=f"{settings.API_V1_STR}/chat", tags=["chat"])
app.include_router(analytics_router, prefix=f"{settings.API_V1_STR}/analytics", tags=["analytics"])
app.include_router(prescriptions_router, prefix=f"{settings.API_V1_STR}/prescriptions", tags=["prescriptions"])
app.include_router(schedule_router, prefix=f"{settings.API_V1_STR}/schedule", tags=["schedule"])
app.include_router(profile_ai_router, prefix=f"{settings.API_V1_STR}/profile-ai", tags=["profile-ai"])
app.include_router(medcard_router,    prefix=f"{settings.API_V1_STR}/medcard",   tags=["medcard"])
app.include_router(referral_router,   prefix=f"{settings.API_V1_STR}/referral",  tags=["referral"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Doctor Portal API"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
