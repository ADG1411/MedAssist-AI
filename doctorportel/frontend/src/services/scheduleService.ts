import type { WeeklySchedule, GeneratedSlot, SpecialDayOverride } from '../types/schedule';

const API_BASE = 'http://localhost:8000/api/v1/schedule';

export const scheduleService = {
  async getWeeklySchedule(): Promise<WeeklySchedule | null> {
    try {
      const res = await fetch(`${API_BASE}/weekly`);
      if (!res.ok) throw new Error('Failed to fetch schedule');
      const data = await res.json();
      return {
        slotDuration: data.slot_duration,
        days: data.days.map((d: any) => ({
          day: d.day,
          enabled: d.enabled,
          startTime: d.start_time,
          endTime: d.end_time,
          breakEnabled: d.break_enabled,
          breakStart: d.break_start || '',
          breakEnd: d.break_end || '',
        })),
      };
    } catch {
      return null;
    }
  },

  async saveWeeklySchedule(schedule: WeeklySchedule): Promise<boolean> {
    try {
      const payload = {
        slot_duration: schedule.slotDuration,
        days: schedule.days.map((d) => ({
          day: d.day,
          enabled: d.enabled,
          start_time: d.startTime,
          end_time: d.endTime,
          break_enabled: d.breakEnabled,
          break_start: d.breakStart || '',
          break_end: d.breakEnd || '',
        })),
      };
      const res = await fetch(`${API_BASE}/weekly`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      return res.ok;
    } catch {
      return false;
    }
  },

  async getAllSlots(): Promise<Record<string, GeneratedSlot[]> | null> {
    try {
      const res = await fetch(`${API_BASE}/slots`);
      if (!res.ok) throw new Error('Failed to fetch slots');
      const data = await res.json();
      const mapped: Record<string, GeneratedSlot[]> = {};
      for (const [day, slots] of Object.entries(data)) {
        mapped[day] = (slots as any[]).map((s) => ({
          time: s.time,
          displayTime: s.display_time,
          isBreak: s.is_break,
          available: s.available,
        }));
      }
      return mapped;
    } catch {
      return null;
    }
  },

  async getSlotsForDay(day: string): Promise<GeneratedSlot[]> {
    try {
      const res = await fetch(`${API_BASE}/slots/${day}`);
      if (!res.ok) return [];
      const data = await res.json();
      return (data as any[]).map((s) => ({
        time: s.time,
        displayTime: s.display_time,
        isBreak: s.is_break,
        available: s.available,
      }));
    } catch {
      return [];
    }
  },

  async getOverrides(): Promise<SpecialDayOverride[]> {
    try {
      const res = await fetch(`${API_BASE}/overrides`);
      if (!res.ok) return [];
      return await res.json();
    } catch {
      return [];
    }
  },

  async addOverride(override: Omit<SpecialDayOverride, 'id'>): Promise<SpecialDayOverride | null> {
    try {
      const res = await fetch(`${API_BASE}/overrides`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(override),
      });
      if (!res.ok) return null;
      const data = await res.json();
      return data.override;
    } catch {
      return null;
    }
  },

  async deleteOverride(id: string): Promise<boolean> {
    try {
      const res = await fetch(`${API_BASE}/overrides/${id}`, { method: 'DELETE' });
      return res.ok;
    } catch {
      return false;
    }
  },
};
