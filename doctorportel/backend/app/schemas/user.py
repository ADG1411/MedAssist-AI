from pydantic import BaseModel
from typing import Optional

class UserBase(BaseModel):
    email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    specialization: Optional[str] = None
    role: str = "patient"

class UserCreate(UserBase):
    password: str

class UserUpdate(UserBase):
    password: Optional[str] = None

class UserInDBBase(UserBase):
    id: int
    is_active: bool = True

    class Config:
        from_attributes = True

class User(UserInDBBase):
    pass
