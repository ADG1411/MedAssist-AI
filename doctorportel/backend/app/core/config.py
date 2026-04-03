from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Union
from pydantic import AnyHttpUrl, validator

class Settings(BaseSettings):
    PROJECT_NAME: str = "Doctor Portal API"
    API_V1_STR: str = "/api/v1"
    
    SECRET_KEY: str = "supersecretkey_please_change_in_production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days
    
    # Database / Supabase
    DATABASE_URI: str = "postgresql://postgres:[YOUR-PASSWORD]@[YOUR-SUPABASE-PROJECT].supabase.co:5432/postgres"
    SUPABASE_URL: str | None = None
    SUPABASE_KEY: str | None = None
    
    # Redis
    REDIS_URL: str = "redis://redis:6379/0"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:5173", "http://localhost:3000"]
    
    model_config = SettingsConfigDict(case_sensitive=True, env_file=".env")

settings = Settings()
