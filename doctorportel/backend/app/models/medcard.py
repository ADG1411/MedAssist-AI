from sqlalchemy import Boolean, Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base


class MedCardPatient(Base):
    __tablename__ = "medcard_patients"

    id           = Column(Integer, primary_key=True, index=True)
    name         = Column(String, nullable=False)
    age          = Column(Integer, nullable=False)
    gender       = Column(String, nullable=False)
    phone        = Column(String, nullable=False)
    blood_group  = Column(String, nullable=False)
    allergies    = Column(Text, nullable=True)
    email        = Column(String, nullable=True)
    address      = Column(Text, nullable=True)
    created_at   = Column(DateTime(timezone=True), server_default=func.now())

    records        = relationship("MedicalRecord",  back_populates="patient", cascade="all, delete-orphan")
    family_members = relationship("FamilyMember",   back_populates="patient", cascade="all, delete-orphan")
    qr_tokens      = relationship("QRToken",        back_populates="patient", cascade="all, delete-orphan")
    access_logs    = relationship("AccessLog",      back_populates="patient", cascade="all, delete-orphan")


class MedicalRecord(Base):
    __tablename__ = "medical_records"

    id           = Column(Integer, primary_key=True, index=True)
    patient_id   = Column(Integer, ForeignKey("medcard_patients.id"), nullable=False)
    diagnosis    = Column(String, nullable=False)
    prescription = Column(Text, nullable=True)
    report_url   = Column(String, nullable=True)
    doctor_name  = Column(String, nullable=True)
    notes        = Column(Text, nullable=True)
    created_at   = Column(DateTime(timezone=True), server_default=func.now())

    patient = relationship("MedCardPatient", back_populates="records")


class QRToken(Base):
    __tablename__ = "qr_tokens"

    id         = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("medcard_patients.id"), nullable=False)
    token      = Column(String, unique=True, nullable=False, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    is_used    = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    patient = relationship("MedCardPatient", back_populates="qr_tokens")


class AccessLog(Base):
    __tablename__ = "access_logs"

    id          = Column(Integer, primary_key=True, index=True)
    doctor_id   = Column(Integer, nullable=False)
    doctor_name = Column(String, nullable=True)
    patient_id  = Column(Integer, ForeignKey("medcard_patients.id"), nullable=False)
    access_type = Column(String, default="standard")  # standard | emergency
    timestamp   = Column(DateTime(timezone=True), server_default=func.now())

    patient = relationship("MedCardPatient", back_populates="access_logs")


class FamilyMember(Base):
    __tablename__ = "family_members"

    id         = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("medcard_patients.id"), nullable=False)
    name       = Column(String, nullable=False)
    relation   = Column(String, nullable=False)
    phone      = Column(String, nullable=False)
    is_primary = Column(Boolean, default=False)

    patient = relationship("MedCardPatient", back_populates="family_members")
