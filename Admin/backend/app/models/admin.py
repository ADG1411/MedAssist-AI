from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()

class AdminUser(Base):
    __tablename__ = "admin_users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String, default="admin") # e.g. superadmin, moderator
    is_active = Column(Boolean, default=True)

class RevenueLog(Base):
    __tablename__ = "revenue_logs"
    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float)
    transaction_date = Column(DateTime, default=datetime.datetime.utcnow)
    source = Column(String) # booking, lab, pharmacy

class SystemAuditLog(Base):
    __tablename__ = "audit_logs"
    id = Column(Integer, primary_key=True, index=True)
    admin_id = Column(Integer)
    action = Column(String)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    details = Column(String)
