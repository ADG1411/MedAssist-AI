export interface AnalyticsSummary {
  total_patients: { value: string | number; trend: string; is_positive: boolean };
  appointments_today: { value: string | number; trend: string; is_positive: boolean };
  completed_cases: { value: string | number; trend: string; is_positive: boolean };
  monthly_earnings: { value: string | number; trend: string; is_positive: boolean };
}

export interface VolumeData {
  name: string;
  current: number;
  previous: number;
}

export interface RevenueData {
  name: string;
  Online: number;
  Offline: number;
  Emergency: number;
}

export interface AIInsight {
  type: 'trend' | 'schedule' | 'alert' | 'error';
  title: string;
  description: string;
  action: string | null;
}

const BASE = '/api/v1/analytics';

export async function getAnalyticsSummary(period: string): Promise<AnalyticsSummary> {
  const res = await fetch(`${BASE}/summary?period=${encodeURIComponent(period)}`);
  if (!res.ok) throw new Error('Failed to fetch summary');
  return res.json();
}

export async function getPatientGrowth(period: string): Promise<VolumeData[]> {
  const res = await fetch(`${BASE}/charts/patient-growth?period=${encodeURIComponent(period)}`);
  if (!res.ok) throw new Error('Failed to fetch patient growth');
  const data = await res.json();
  return data.data;
}

export async function getRevenueBreakdown(period: string): Promise<RevenueData[]> {
  const res = await fetch(`${BASE}/charts/revenue?period=${encodeURIComponent(period)}`);
  if (!res.ok) throw new Error('Failed to fetch revenue breakdown');
  const data = await res.json();
  return data.data;
}

export async function getAIInsights(period: string): Promise<AIInsight[]> {
  try {
    const res = await fetch(`${BASE}/ai-insights?period=${encodeURIComponent(period)}`);
    if (!res.ok) throw new Error('Failed to fetch AI insights');
    const data = await res.json();
    return data.insights || [];
  } catch (err) {
    console.error('getAIInsights error:', err);
    return [
      {
        type: 'error',
        title: 'AI Offline',
        description: 'Unable to connect to AI service.',
        action: null
      }
    ];
  }
}
