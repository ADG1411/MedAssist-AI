export type SlotDuration = 15 | 30 | 60;

export interface DaySchedule {
  day: string;
  enabled: boolean;
  startTime: string;
  endTime: string;
  breakEnabled: boolean;
  breakStart: string;
  breakEnd: string;
}

export interface WeeklySchedule {
  slotDuration: SlotDuration;
  days: DaySchedule[];
}

export interface GeneratedSlot {
  time: string;
  displayTime: string;
  isBreak: boolean;
  available: boolean;
}

export interface SpecialDayOverride {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  reason: string;
  isHoliday: boolean;
}

export interface ScheduleState {
  weeklySchedule: WeeklySchedule;
  overrides: SpecialDayOverride[];
  saved: boolean;
  lastSaved: string | null;
}
