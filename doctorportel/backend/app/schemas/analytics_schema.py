from pydantic import BaseModel
from typing import Optional, List


class StatMetric(BaseModel):
    value: str | int | float
    trend: str
    is_positive: bool


class AnalyticsSummary(BaseModel):
    total_patients: StatMetric
    appointments_today: StatMetric
    completed_cases: StatMetric
    monthly_earnings: StatMetric


class VolumeDataPoint(BaseModel):
    name: str
    current: int
    previous: int


class RevenueDataPoint(BaseModel):
    name: str
    Online: int
    Offline: int
    Emergency: int


class AIInsight(BaseModel):
    type: str  # trend | schedule | alert | error
    title: str
    description: str
    action: Optional[str] = None


class AIInsightsResponse(BaseModel):
    insights: List[AIInsight]
