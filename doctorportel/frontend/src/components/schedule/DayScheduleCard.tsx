import React from 'react';
import { Clock, Coffee, Copy, ChevronDown, ChevronUp } from 'lucide-react';
import type { DaySchedule } from '../../types/schedule';
import { TimeInput } from './TimeInput';
import { cn } from '../../layouts/DashboardLayout';

interface DayScheduleCardProps {
  schedule: DaySchedule;
  onChange: (updated: DaySchedule) => void;
  onCopyToAll: (day: string) => void;
  isExpanded: boolean;
  onToggleExpand: () => void;
}

const DAY_COLORS: Record<string, string> = {
  Monday:    'bg-blue-500',
  Tuesday:   'bg-violet-500',
  Wednesday: 'bg-indigo-500',
  Thursday:  'bg-sky-500',
  Friday:    'bg-teal-500',
  Saturday:  'bg-amber-500',
  Sunday:    'bg-rose-500',
};

const DAY_ABBR: Record<string, string> = {
  Monday: 'MON', Tuesday: 'TUE', Wednesday: 'WED',
  Thursday: 'THU', Friday: 'FRI', Saturday: 'SAT', Sunday: 'SUN',
};

export const DayScheduleCard: React.FC<DayScheduleCardProps> = ({
  schedule,
  onChange,
  onCopyToAll,
  isExpanded,
  onToggleExpand,
}) => {
  const dot = DAY_COLORS[schedule.day] ?? 'bg-slate-400';

  const update = (patch: Partial<DaySchedule>) =>
    onChange({ ...schedule, ...patch });

  const formatDisplay = (t: string) => {
    if (!t) return '--:--';
    const [h, m] = t.split(':').map(Number);
    const ampm = h >= 12 ? 'PM' : 'AM';
    const hh = h % 12 || 12;
    return `${hh}:${String(m).padStart(2, '0')} ${ampm}`;
  };

  return (
    <div
      className={cn(
        'rounded-2xl border transition-all duration-300 overflow-hidden',
        schedule.enabled
          ? 'bg-white border-slate-200 shadow-sm hover:shadow-md'
          : 'bg-slate-50 border-slate-200/60 opacity-75'
      )}
    >
      {/* ── Card Header ── */}
      <div className="flex items-center gap-3 px-4 py-3.5">
        {/* Day badge */}
        <div className={cn('w-12 h-12 rounded-xl flex items-center justify-center shrink-0', dot)}>
          <span className="text-white text-xs font-black tracking-wider">
            {DAY_ABBR[schedule.day]}
          </span>
        </div>

        {/* Day name + status */}
        <div className="flex-1 min-w-0">
          <p className="font-bold text-slate-800 text-[15px]">{schedule.day}</p>
          {schedule.enabled ? (
            <div className="text-xs text-slate-500 font-medium mt-0.5 flex flex-wrap gap-x-3 gap-y-1">
              <span className="flex items-center whitespace-nowrap">
                <Clock className="inline w-3 h-3 mr-1" />
                {formatDisplay(schedule.startTime)} – {formatDisplay(schedule.endTime)}
              </span>
              {schedule.breakEnabled && schedule.breakStart && (
                <span className="text-amber-600 flex items-center whitespace-nowrap">
                  <Coffee className="inline w-3 h-3 mr-1" />
                  Break: {formatDisplay(schedule.breakStart)}–{formatDisplay(schedule.breakEnd)}
                </span>
              )}
            </div>
          ) : (
            <span className="inline-flex items-center gap-1 text-xs font-bold text-rose-500 bg-rose-50 border border-rose-200/60 px-2 py-0.5 rounded-full mt-0.5">
              Holiday
            </span>
          )}
        </div>

        {/* Controls */}
        <div className="flex items-center gap-2 shrink-0">
          {/* Toggle */}
          <button
            onClick={() => update({ enabled: !schedule.enabled })}
            className={cn(
              'relative w-12 h-6 rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-offset-1',
              schedule.enabled
                ? 'bg-indigo-600 focus:ring-indigo-500'
                : 'bg-slate-300 focus:ring-slate-400'
            )}
            aria-label={`Toggle ${schedule.day}`}
          >
            <span
              className={cn(
                'absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform duration-300',
                schedule.enabled ? 'translate-x-6' : 'translate-x-0'
              )}
            />
          </button>

          {/* Expand chevron (only when enabled) */}
          {schedule.enabled && (
            <button
              onClick={onToggleExpand}
              className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
            >
              {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
            </button>
          )}
        </div>
      </div>

      {/* ── Expanded Edit Panel ── */}
      {schedule.enabled && isExpanded && (
        <div className="px-4 pb-4 pt-1 border-t border-slate-100 space-y-4">
          {/* Time row */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TimeInput
              label="Start Time"
              value={schedule.startTime}
              onChange={(v) => update({ startTime: v })}
            />
            <TimeInput
              label="End Time"
              value={schedule.endTime}
              onChange={(v) => update({ endTime: v })}
            />
          </div>

          {/* Break toggle */}
          <div className="flex items-center justify-between py-2 px-3 bg-amber-50 rounded-xl border border-amber-100">
            <div className="flex items-center gap-2">
              <Coffee className="w-4 h-4 text-amber-600" />
              <span className="text-sm font-semibold text-amber-800">Break Time</span>
            </div>
            <button
              onClick={() => update({ breakEnabled: !schedule.breakEnabled })}
              className={cn(
                'relative w-10 h-5 rounded-full transition-colors duration-300',
                schedule.breakEnabled ? 'bg-amber-500' : 'bg-slate-300'
              )}
            >
              <span
                className={cn(
                  'absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform duration-300',
                  schedule.breakEnabled ? 'translate-x-5' : 'translate-x-0'
                )}
              />
            </button>
          </div>

          {/* Break times */}
          {schedule.breakEnabled && (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pl-2 border-l-2 border-amber-300">
              <TimeInput
                label="Break Start"
                value={schedule.breakStart}
                onChange={(v) => update({ breakStart: v })}
              />
              <TimeInput
                label="Break End"
                value={schedule.breakEnd}
                onChange={(v) => update({ breakEnd: v })}
              />
            </div>
          )}

          {/* Copy to all */}
          <button
            onClick={() => onCopyToAll(schedule.day)}
            className="w-full flex items-center justify-center gap-2 text-indigo-600 font-semibold text-sm py-2.5 px-4 rounded-xl border border-indigo-200 bg-indigo-50 hover:bg-indigo-100 transition-colors"
          >
            <Copy className="w-4 h-4" />
            Apply {schedule.day}'s schedule to all days
          </button>
        </div>
      )}
    </div>
  );
};
