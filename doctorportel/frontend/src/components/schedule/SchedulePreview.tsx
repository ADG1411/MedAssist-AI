import React from 'react';
import { Clock, Coffee, XCircle, CheckCircle2, Edit3 } from 'lucide-react';
import type { WeeklySchedule } from '../../types/schedule';
import { cn } from '../../layouts/DashboardLayout';

interface SchedulePreviewProps {
  schedule: WeeklySchedule;
  onEdit: () => void;
  onSave: () => void;
  isSaving: boolean;
  savedAt: string | null;
}

const DAY_GRADIENTS: Record<string, string> = {
  Monday:    'from-blue-500 to-blue-600',
  Tuesday:   'from-violet-500 to-violet-600',
  Wednesday: 'from-indigo-500 to-indigo-600',
  Thursday:  'from-sky-500 to-sky-600',
  Friday:    'from-teal-500 to-teal-600',
  Saturday:  'from-amber-500 to-amber-600',
  Sunday:    'from-rose-500 to-rose-600',
};

function formatTime(t: string): string {
  if (!t) return '--';
  const [h, m] = t.split(':').map(Number);
  const ampm = h >= 12 ? 'PM' : 'AM';
  return `${h % 12 || 12}:${String(m).padStart(2, '0')} ${ampm}`;
}

function calcHours(start: string, end: string): string {
  if (!start || !end) return '';
  const [sh, sm] = start.split(':').map(Number);
  const [eh, em] = end.split(':').map(Number);
  const mins = (eh * 60 + em) - (sh * 60 + sm);
  if (mins <= 0) return '';
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  return m ? `${h}h ${m}m` : `${h}h`;
}

export const SchedulePreview: React.FC<SchedulePreviewProps> = ({
  schedule,
  onEdit,
  onSave,
  isSaving,
  savedAt,
}) => {
  const enabledCount = schedule.days.filter((d) => d.enabled).length;

  return (
    <div className="space-y-5">
      {/* Summary bar */}
      <div className="flex flex-wrap gap-3 items-center justify-between p-4 bg-indigo-50 rounded-2xl border border-indigo-100">
        <div className="flex items-center gap-4">
          <div className="text-center">
            <p className="text-2xl font-black text-indigo-700">{enabledCount}</p>
            <p className="text-xs text-indigo-500 font-semibold">Working Days</p>
          </div>
          <div className="w-px h-10 bg-indigo-200" />
          <div className="text-center">
            <p className="text-2xl font-black text-indigo-700">{7 - enabledCount}</p>
            <p className="text-xs text-indigo-500 font-semibold">Holidays</p>
          </div>
          <div className="w-px h-10 bg-indigo-200" />
          <div className="text-center">
            <p className="text-2xl font-black text-indigo-700">{schedule.slotDuration}m</p>
            <p className="text-xs text-indigo-500 font-semibold">Slot Size</p>
          </div>
        </div>
        {savedAt && (
          <div className="flex items-center gap-1.5 text-xs text-emerald-700 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-full font-semibold">
            <CheckCircle2 className="w-3.5 h-3.5" />
            Saved {savedAt}
          </div>
        )}
      </div>

      {/* Day cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
        {schedule.days.map((day) => (
          <div
            key={day.day}
            className={cn(
              'rounded-2xl overflow-hidden border transition-all',
              day.enabled
                ? 'bg-white border-slate-200 shadow-sm'
                : 'bg-rose-50 border-rose-200/70'
            )}
          >
            {/* Color strip header */}
            <div
              className={cn(
                'h-1.5 w-full bg-gradient-to-r',
                day.enabled
                  ? DAY_GRADIENTS[day.day] ?? 'from-slate-400 to-slate-500'
                  : 'from-rose-400 to-rose-500'
              )}
            />

            <div className="px-4 py-3">
              <div className="flex items-center justify-between mb-2">
                <span className="font-bold text-slate-800 text-[15px]">{day.day}</span>
                {day.enabled ? (
                  <span className="text-xs font-bold text-emerald-600 bg-emerald-50 border border-emerald-200/60 px-2 py-0.5 rounded-full">
                    Open
                  </span>
                ) : (
                  <span className="flex items-center gap-1 text-xs font-bold text-rose-600 bg-rose-100 border border-rose-200/60 px-2 py-0.5 rounded-full">
                    <XCircle className="w-3 h-3" /> Holiday
                  </span>
                )}
              </div>

              {day.enabled ? (
                <div className="space-y-1.5">
                  <div className="flex items-center gap-1.5 text-sm text-slate-600 font-medium">
                    <Clock className="w-3.5 h-3.5 text-indigo-500 shrink-0" />
                    <span>{formatTime(day.startTime)} – {formatTime(day.endTime)}</span>
                    {calcHours(day.startTime, day.endTime) && (
                      <span className="ml-auto text-xs text-slate-400 font-semibold">
                        {calcHours(day.startTime, day.endTime)}
                      </span>
                    )}
                  </div>
                  {day.breakEnabled && day.breakStart && (
                    <div className="flex items-center gap-1.5 text-xs text-amber-700 bg-amber-50 px-2.5 py-1.5 rounded-lg font-medium">
                      <Coffee className="w-3 h-3 shrink-0" />
                      Break: {formatTime(day.breakStart)} – {formatTime(day.breakEnd)}
                    </div>
                  )}
                </div>
              ) : (
                <p className="text-sm text-rose-400 font-medium mt-1">No appointments</p>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Action buttons */}
      <div className="flex flex-col sm:flex-row gap-3 pt-2">
        <button
          onClick={onEdit}
          className="flex-1 flex items-center justify-center gap-2 py-3 px-6 rounded-xl border-2 border-slate-200 text-slate-700 font-bold text-sm hover:bg-slate-50 hover:border-slate-300 transition-all"
        >
          <Edit3 className="w-4 h-4" /> Edit Schedule
        </button>
        <button
          onClick={onSave}
          disabled={isSaving}
          className={cn(
            'flex-1 flex items-center justify-center gap-2 py-3 px-6 rounded-xl font-bold text-sm text-white transition-all shadow-lg',
            isSaving
              ? 'bg-indigo-400 cursor-not-allowed'
              : 'bg-indigo-600 hover:bg-indigo-700 shadow-indigo-200 active:scale-95'
          )}
        >
          {isSaving ? (
            <>
              <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
              Saving…
            </>
          ) : (
            <>
              <CheckCircle2 className="w-4 h-4" /> Save Schedule
            </>
          )}
        </button>
      </div>
    </div>
  );
};
