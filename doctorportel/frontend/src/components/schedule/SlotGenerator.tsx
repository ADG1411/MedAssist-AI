import React, { useState } from 'react';
import { Zap, Coffee, CheckCircle2, Clock, ChevronDown } from 'lucide-react';
import type { WeeklySchedule, GeneratedSlot } from '../../types/schedule';
import { cn } from '../../layouts/DashboardLayout';

interface SlotGeneratorProps {
  schedule: WeeklySchedule;
}

function generateSlots(
  startTime: string,
  endTime: string,
  durationMin: number,
  breakStart: string,
  breakEnd: string,
  breakEnabled: boolean
): GeneratedSlot[] {
  if (!startTime || !endTime) return [];

  const [sh, sm] = startTime.split(':').map(Number);
  const [eh, em] = endTime.split(':').map(Number);
  const [bsh, bsm] = breakEnabled && breakStart ? breakStart.split(':').map(Number) : [0, 0];
  const [beh, bem] = breakEnabled && breakEnd   ? breakEnd.split(':').map(Number)   : [0, 0];

  const startMins = sh * 60 + sm;
  const endMins   = eh * 60 + em;
  const bStartM   = bsh * 60 + bsm;
  const bEndM     = beh * 60 + bem;

  const slots: GeneratedSlot[] = [];
  let cur = startMins;

  while (cur < endMins) {
    const h    = Math.floor(cur / 60);
    const m    = cur % 60;
    const ampm = h >= 12 ? 'PM' : 'AM';
    const hh   = h % 12 || 12;
    const isBreak = breakEnabled && breakStart && breakEnd
      ? cur >= bStartM && cur < bEndM
      : false;

    slots.push({
      time:        `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`,
      displayTime: `${hh}:${String(m).padStart(2, '0')} ${ampm}`,
      isBreak,
      available:   !isBreak,
    });

    cur += durationMin;
  }

  return slots;
}

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

export const SlotGenerator: React.FC<SlotGeneratorProps> = ({ schedule }) => {
  const [selectedDay, setSelectedDay] = useState<string>('Monday');
  const [generated, setGenerated]     = useState<GeneratedSlot[] | null>(null);

  const enabledDays = schedule.days.filter((d) => d.enabled);

  const handleGenerate = () => {
    const dayData = schedule.days.find((d) => d.day === selectedDay);
    if (!dayData || !dayData.enabled) {
      setGenerated([]);
      return;
    }
    const slots = generateSlots(
      dayData.startTime,
      dayData.endTime,
      schedule.slotDuration,
      dayData.breakStart,
      dayData.breakEnd,
      dayData.breakEnabled
    );
    setGenerated(slots);
  };

  const handleGenerateAll = () => {
    const dayData = schedule.days.find((d) => d.day === selectedDay);
    if (!dayData || !dayData.enabled) { setGenerated([]); return; }
    const slots = generateSlots(
      dayData.startTime, dayData.endTime, schedule.slotDuration,
      dayData.breakStart, dayData.breakEnd, dayData.breakEnabled
    );
    setGenerated(slots);
  };

  const availableSlots = generated?.filter((s) => s.available) ?? [];
  const breakSlots     = generated?.filter((s) => s.isBreak)   ?? [];

  return (
    <div className="space-y-5">
      {/* Controls */}
      <div className="flex flex-col sm:flex-row gap-3">
        {/* Day selector */}
        <div className="relative flex-1">
          <select
            value={selectedDay}
            onChange={(e) => { setSelectedDay(e.target.value); setGenerated(null); }}
            className="w-full appearance-none border-2 border-slate-200 rounded-xl px-4 py-3 pr-10 text-sm font-semibold text-slate-700 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none cursor-pointer"
          >
            {DAYS.map((d) => {
              const isEnabled = schedule.days.find((sd) => sd.day === d)?.enabled;
              return (
                <option key={d} value={d}>
                  {d} {!isEnabled ? '(Holiday)' : ''}
                </option>
              );
            })}
          </select>
          <ChevronDown className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
        </div>

        {/* Duration badge */}
        <div className="flex items-center gap-2 bg-indigo-50 border border-indigo-200 rounded-xl px-4 py-3">
          <Clock className="w-4 h-4 text-indigo-600" />
          <span className="text-sm font-bold text-indigo-700">{schedule.slotDuration} min slots</span>
        </div>

        {/* Generate button */}
        <button
          onClick={handleGenerate}
          disabled={!enabledDays.length}
          className={cn(
            'flex items-center justify-center gap-2 px-6 py-3 rounded-xl font-bold text-sm text-white transition-all',
            enabledDays.length
              ? 'bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95'
              : 'bg-slate-300 cursor-not-allowed'
          )}
        >
          <Zap className="w-4 h-4" /> Generate Slots
        </button>
      </div>

      {/* Info row */}
      {generated && (
        <div className="flex flex-wrap gap-3">
          <div className="flex items-center gap-2 text-sm text-emerald-700 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-lg font-semibold">
            <CheckCircle2 className="w-4 h-4" />
            {availableSlots.length} Available Slots
          </div>
          {breakSlots.length > 0 && (
            <div className="flex items-center gap-2 text-sm text-amber-700 bg-amber-50 border border-amber-200 px-3 py-1.5 rounded-lg font-semibold">
              <Coffee className="w-4 h-4" />
              {breakSlots.length} Break Slots
            </div>
          )}
          <button
            onClick={handleGenerateAll}
            className="ml-auto text-xs font-bold text-indigo-600 hover:underline"
          >
            Regenerate
          </button>
        </div>
      )}

      {/* Slot grid */}
      {generated === null && (
        <div className="flex flex-col items-center justify-center py-16 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400">
          <Zap className="w-10 h-10 mb-3 text-slate-300" />
          <p className="font-semibold text-slate-500">Select a day and click Generate Slots</p>
          <p className="text-sm mt-1">Slots will be auto-created based on your schedule</p>
        </div>
      )}

      {generated !== null && generated.length === 0 && (
        <div className="flex flex-col items-center justify-center py-16 border-2 border-dashed border-rose-200 rounded-2xl text-rose-400">
          <p className="font-semibold">{selectedDay} is a Holiday</p>
          <p className="text-sm mt-1">Enable this day in your schedule to generate slots</p>
        </div>
      )}

      {generated !== null && generated.length > 0 && (
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-8 gap-2.5">
          {generated.map((slot) => (
            <div
              key={slot.time}
              className={cn(
                'flex flex-col items-center justify-center py-2.5 px-1 rounded-xl border text-xs font-bold transition-all',
                slot.isBreak
                  ? 'bg-amber-50 border-amber-200 text-amber-600'
                  : 'bg-white border-slate-200 text-slate-700 hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 cursor-pointer shadow-sm'
              )}
            >
              {slot.isBreak ? (
                <Coffee className="w-3.5 h-3.5 mb-1 text-amber-500" />
              ) : (
                <div className="w-1.5 h-1.5 rounded-full bg-emerald-400 mb-1" />
              )}
              <span>{slot.displayTime}</span>
              {slot.isBreak && (
                <span className="text-[9px] text-amber-500 font-semibold mt-0.5">BREAK</span>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
