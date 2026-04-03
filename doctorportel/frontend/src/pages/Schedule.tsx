import React, { useState, useEffect } from 'react';
import {
  Calendar, Clock, Coffee, Copy, ChevronRight,
  X, CheckCircle2, Zap, Save,
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { scheduleService } from '../services/scheduleService';
import type { WeeklySchedule, DaySchedule, SlotDuration, GeneratedSlot } from '../types/schedule';

// ─── Constants ─────────────────────────────────────────────────────────────────
const DAY_CFG: Record<string, { color: string; border: string; abbr: string }> = {
  Monday:    { color: 'bg-blue-500',   border: 'border-l-blue-500',   abbr: 'MON' },
  Tuesday:   { color: 'bg-violet-500', border: 'border-l-violet-500', abbr: 'TUE' },
  Wednesday: { color: 'bg-indigo-500', border: 'border-l-indigo-500', abbr: 'WED' },
  Thursday:  { color: 'bg-sky-500',    border: 'border-l-sky-500',    abbr: 'THU' },
  Friday:    { color: 'bg-teal-500',   border: 'border-l-teal-500',   abbr: 'FRI' },
  Saturday:  { color: 'bg-amber-500',  border: 'border-l-amber-500',  abbr: 'SAT' },
  Sunday:    { color: 'bg-rose-500',   border: 'border-l-rose-500',   abbr: 'SUN' },
};

const DEFAULT_SCHEDULE: WeeklySchedule = {
  slotDuration: 30,
  days: [
    { day: 'Monday',    enabled: true,  startTime: '09:00', endTime: '18:00', breakEnabled: true,  breakStart: '13:00', breakEnd: '14:00' },
    { day: 'Tuesday',   enabled: true,  startTime: '09:00', endTime: '18:00', breakEnabled: true,  breakStart: '13:00', breakEnd: '14:00' },
    { day: 'Wednesday', enabled: true,  startTime: '09:00', endTime: '18:00', breakEnabled: true,  breakStart: '13:00', breakEnd: '14:00' },
    { day: 'Thursday',  enabled: true,  startTime: '09:00', endTime: '18:00', breakEnabled: true,  breakStart: '13:00', breakEnd: '14:00' },
    { day: 'Friday',    enabled: true,  startTime: '09:00', endTime: '18:00', breakEnabled: true,  breakStart: '13:00', breakEnd: '14:00' },
    { day: 'Saturday',  enabled: true,  startTime: '10:00', endTime: '14:00', breakEnabled: false, breakStart: '',      breakEnd: '' },
    { day: 'Sunday',    enabled: false, startTime: '09:00', endTime: '18:00', breakEnabled: false, breakStart: '',      breakEnd: '' },
  ],
};

// ─── Helpers ────────────────────────────────────────────────────────────────────
const fmtTime = (t: string): string => {
  if (!t) return '--:--';
  const [h, m] = t.split(':').map(Number);
  return `${h % 12 || 12}:${String(m).padStart(2, '0')} ${h >= 12 ? 'PM' : 'AM'}`;
};

const calcHours = (s: string, e: string): string => {
  if (!s || !e) return '';
  const [sh, sm] = s.split(':').map(Number);
  const [eh, em] = e.split(':').map(Number);
  const mins = (eh * 60 + em) - (sh * 60 + sm);
  if (mins <= 0) return '';
  const h = Math.floor(mins / 60), m = mins % 60;
  return m ? `${h}h ${m}m` : `${h}h`;
};

const countSlots = (day: DaySchedule, dur: number): number => {
  if (!day.enabled || !day.startTime || !day.endTime) return 0;
  const [sh, sm] = day.startTime.split(':').map(Number);
  const [eh, em] = day.endTime.split(':').map(Number);
  let total = (eh * 60 + em) - (sh * 60 + sm);
  if (day.breakEnabled && day.breakStart && day.breakEnd) {
    const [bsh, bsm] = day.breakStart.split(':').map(Number);
    const [beh, bem] = day.breakEnd.split(':').map(Number);
    total -= (beh * 60 + bem) - (bsh * 60 + bsm);
  }
  return Math.max(0, Math.floor(total / dur));
};

const buildSlots = (day: DaySchedule, dur: number): GeneratedSlot[] => {
  if (!day.startTime || !day.endTime) return [];
  const [sh, sm] = day.startTime.split(':').map(Number);
  const [eh, em] = day.endTime.split(':').map(Number);
  const bStart = day.breakEnabled && day.breakStart ? day.breakStart.split(':').map(Number) : [0, 0];
  const bEnd   = day.breakEnabled && day.breakEnd   ? day.breakEnd.split(':').map(Number)   : [0, 0];
  const endM   = eh * 60 + em;
  const bStartM = bStart[0] * 60 + bStart[1];
  const bEndM   = bEnd[0]   * 60 + bEnd[1];
  const slots: GeneratedSlot[] = [];
  let cur = sh * 60 + sm;
  while (cur < endM) {
    const h = Math.floor(cur / 60), m = cur % 60;
    const isBreak = day.breakEnabled && day.breakStart && day.breakEnd
      ? cur >= bStartM && cur < bEndM : false;
    slots.push({
      time:        `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`,
      displayTime: `${h % 12 || 12}:${String(m).padStart(2, '0')} ${h >= 12 ? 'PM' : 'AM'}`,
      isBreak, available: !isBreak,
    });
    cur += dur;
  }
  return slots;
};

// ─── Day Detail Modal ───────────────────────────────────────────────────────────
type ModalTab = 'overview' | 'slots' | 'break' | 'copy';

const MODAL_TABS: { id: ModalTab; icon: React.ComponentType<{ className?: string }>; label: string; sub: string }[] = [
  { id: 'overview', icon: Calendar,     label: 'Overview',     sub: 'Hours & Status'  },
  { id: 'slots',    icon: Zap,          label: 'Time Slots',   sub: 'Available Times' },
  { id: 'break',    icon: Coffee,       label: 'Break Time',   sub: 'Rest Settings'   },
  { id: 'copy',     icon: Copy,         label: 'Copy Schedule',sub: 'Apply to Days'   },
];

const DayDetailModal = ({
  day, slotDuration, onClose, onUpdate, onCopyToAll,
}: {
  day: DaySchedule;
  slotDuration: number;
  onClose: () => void;
  onUpdate: (d: DaySchedule) => void;
  onCopyToAll: (src: string) => void;
}) => {
  const [tab, setTab]     = useState<ModalTab>('overview');
  const [local, setLocal] = useState<DaySchedule>({ ...day });
  const cfg     = DAY_CFG[day.day] ?? { color: 'bg-slate-500', border: '', abbr: 'DAY' };
  const slots   = buildSlots(local, slotDuration);
  const avail   = slots.filter(s => s.available);
  const breaks  = slots.filter(s => s.isBreak);
  const upd     = (p: Partial<DaySchedule>) => setLocal(prev => ({ ...prev, ...p }));

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-white rounded-t-3xl sm:rounded-3xl shadow-2xl w-full sm:max-w-[860px] max-h-[92vh] sm:max-h-[90vh] flex flex-col overflow-hidden animate-in slide-in-from-bottom-4 sm:zoom-in-95 duration-200">

        {/* ── Header ── */}
        <div className="flex items-center gap-4 px-6 py-4 border-b border-slate-200 shrink-0">
          <div className={cn('w-12 h-12 rounded-2xl flex items-center justify-center text-white font-black text-[13px] shrink-0', cfg.color)}>
            {cfg.abbr}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <h2 className="font-black text-slate-800 text-[18px]">{day.day}</h2>
              <span className={cn('text-[11px] font-black px-2.5 py-0.5 rounded-full border', local.enabled ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-rose-50 text-rose-700 border-rose-200')}>
                {local.enabled ? 'Working Day' : 'Holiday'}
              </span>
            </div>
            <p className="text-slate-500 text-[13px] font-medium mt-0.5">
              {local.enabled ? `${fmtTime(local.startTime)} – ${fmtTime(local.endTime)} · ${avail.length} slots` : 'No appointments scheduled'}
            </p>
          </div>
          <button
            onClick={() => upd({ enabled: !local.enabled })}
            className={cn('relative w-12 h-6 rounded-full transition-colors duration-300 shrink-0', local.enabled ? 'bg-emerald-500' : 'bg-slate-300')}
          >
            <span className={cn('absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform duration-300', local.enabled ? 'translate-x-6' : 'translate-x-0')} />
          </button>
          <button onClick={onClose} className="w-9 h-9 flex items-center justify-center rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors shrink-0">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* ── Body ── */}
        <div className="flex-1 flex flex-col sm:flex-row overflow-hidden min-h-0">

          {/* Mobile: horizontal tab strip | Desktop: left sidebar */}
          <div className="sm:w-[200px] shrink-0 sm:flex sm:flex-col border-b sm:border-b-0 sm:border-r border-slate-200 bg-slate-50/50 sm:py-3 sm:px-2">
            {/* Mobile horizontal scroll */}
            <div className="flex sm:hidden overflow-x-auto hide-scrollbar gap-1 px-3 py-2">
              {MODAL_TABS.map(({ id, icon: Icon, label }) => (
                <button
                  key={id}
                  onClick={() => setTab(id)}
                  className={cn('flex items-center gap-1.5 px-3 py-2 rounded-xl text-[12px] font-bold whitespace-nowrap transition-all shrink-0 border',
                    tab === id ? 'bg-teal-500 text-white border-teal-500' : 'bg-white text-slate-600 border-slate-200')}
                >
                  <Icon className="w-3.5 h-3.5" />{label}
                </button>
              ))}
            </div>
            {/* Desktop vertical sidebar */}
            <div className="hidden sm:flex sm:flex-col flex-1">
              {MODAL_TABS.map(({ id, icon: Icon, label, sub }) => (
                <button
                  key={id}
                  onClick={() => setTab(id)}
                  className={cn('flex items-center gap-3 px-3 py-3 rounded-xl text-left transition-all mb-0.5', tab === id ? 'bg-teal-50 border border-teal-200' : 'hover:bg-white border border-transparent')}
                >
                  <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center shrink-0', tab === id ? 'bg-teal-500' : 'bg-white border border-slate-200')}>
                    <Icon className={cn('w-4 h-4', tab === id ? 'text-white' : 'text-slate-500')} />
                  </div>
                  <div className="min-w-0">
                    <p className={cn('text-[12px] font-bold leading-tight truncate', tab === id ? 'text-teal-700' : 'text-slate-700')}>{label}</p>
                    <p className="text-[10px] text-slate-400 font-medium truncate">{sub}</p>
                  </div>
                </button>
              ))}
              <div className="mt-auto px-3 py-3">
                <div className="flex items-center gap-2">
                  <span className={cn('w-2 h-2 rounded-full', local.enabled ? 'bg-emerald-400' : 'bg-rose-400')} />
                  <span className="text-[11px] font-bold text-slate-600">{local.enabled ? 'Active' : 'Holiday'}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Main Content */}
          <div className="flex-1 overflow-y-auto p-4 sm:p-5 space-y-4 bg-white">

            {/* ── Overview ── */}
            {tab === 'overview' && (
              <>
                <div className="grid grid-cols-3 gap-3">
                  {[
                    { label: 'Slots',    value: avail.length.toString()                    },
                    { label: 'Per Slot', value: `${slotDuration}m`                         },
                    { label: 'Working',  value: calcHours(local.startTime, local.endTime) || '--' },
                  ].map(({ label, value }) => (
                    <div key={label} className="bg-slate-50 border border-slate-200 rounded-2xl p-4 text-center">
                      <p className="text-[26px] font-black text-slate-800">{value}</p>
                      <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">{label}</p>
                    </div>
                  ))}
                </div>

                <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm">
                  <div className="flex items-center gap-2 mb-4">
                    <div className="w-7 h-7 bg-blue-100 rounded-lg flex items-center justify-center">
                      <Clock className="w-4 h-4 text-blue-600" />
                    </div>
                    <span className="font-black text-slate-800 text-[14px]">Working Hours</span>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    {[
                      { label: 'Start Time', key: 'startTime' as const, val: local.startTime },
                      { label: 'End Time',   key: 'endTime'   as const, val: local.endTime   },
                    ].map(({ label, key, val }) => (
                      <div key={key}>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5">{label}</p>
                        <input
                          type="time" value={val} disabled={!local.enabled}
                          onChange={e => upd({ [key]: e.target.value })}
                          className="w-full border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] font-semibold focus:ring-2 focus:ring-teal-500 focus:border-teal-400 outline-none disabled:bg-slate-50 disabled:text-slate-400 transition-all"
                        />
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}

            {/* ── Slots ── */}
            {tab === 'slots' && (
              avail.length > 0 ? (
                <>
                  <div className="flex items-center gap-3 flex-wrap">
                    <div className="flex items-center gap-2 text-sm text-emerald-700 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-lg font-semibold">
                      <CheckCircle2 className="w-4 h-4" /> {avail.length} Available Slots
                    </div>
                    {breaks.length > 0 && (
                      <div className="flex items-center gap-2 text-sm text-amber-700 bg-amber-50 border border-amber-200 px-3 py-1.5 rounded-lg font-semibold">
                        <Coffee className="w-4 h-4" /> {breaks.length} Break Slots
                      </div>
                    )}
                  </div>
                  <div className="grid grid-cols-4 sm:grid-cols-5 md:grid-cols-6 gap-2.5">
                    {slots.map(s => (
                      <div key={s.time} className={cn(
                        'flex flex-col items-center justify-center py-2.5 px-1 rounded-xl border text-xs font-bold transition-all',
                        s.isBreak
                          ? 'bg-amber-50 border-amber-200 text-amber-600'
                          : 'bg-white border-slate-200 text-slate-700 hover:border-teal-300 hover:bg-teal-50 hover:text-teal-700 cursor-pointer shadow-sm'
                      )}>
                        {s.isBreak
                          ? <Coffee className="w-3.5 h-3.5 mb-1 text-amber-500" />
                          : <div className="w-1.5 h-1.5 rounded-full bg-emerald-400 mb-1" />}
                        <span>{s.displayTime}</span>
                        {s.isBreak && <span className="text-[9px] text-amber-500 font-semibold mt-0.5">BREAK</span>}
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <div className="flex flex-col items-center justify-center py-20 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400">
                  <Zap className="w-10 h-10 mb-3 text-slate-300" />
                  <p className="font-semibold text-slate-500">{local.enabled ? 'Set working hours to see slots' : 'This day is marked as Holiday'}</p>
                </div>
              )
            )}

            {/* ── Break ── */}
            {tab === 'break' && (
              <div className="space-y-4">
                <div className={cn('flex items-center justify-between p-4 rounded-2xl border', local.breakEnabled ? 'bg-amber-50 border-amber-200' : 'bg-slate-50 border-slate-200')}>
                  <div className="flex items-center gap-3">
                    <div className={cn('w-9 h-9 rounded-xl flex items-center justify-center', local.breakEnabled ? 'bg-amber-500' : 'bg-slate-200')}>
                      <Coffee className={cn('w-5 h-5', local.breakEnabled ? 'text-white' : 'text-slate-500')} />
                    </div>
                    <div>
                      <p className="font-bold text-slate-800 text-[14px]">Break Time</p>
                      <p className="text-slate-500 text-[12px] font-medium">{local.breakEnabled ? 'Enabled' : 'No break configured'}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => upd({ breakEnabled: !local.breakEnabled })} disabled={!local.enabled}
                    className={cn('relative w-12 h-6 rounded-full transition-colors duration-300 disabled:opacity-40', local.breakEnabled ? 'bg-amber-500' : 'bg-slate-300')}
                  >
                    <span className={cn('absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform duration-300', local.breakEnabled ? 'translate-x-6' : 'translate-x-0')} />
                  </button>
                </div>
                {local.breakEnabled && (
                  <div className="grid grid-cols-2 gap-4 pl-2 border-l-2 border-amber-300">
                    {[
                      { label: 'Break Start', key: 'breakStart' as const, val: local.breakStart },
                      { label: 'Break End',   key: 'breakEnd'   as const, val: local.breakEnd   },
                    ].map(({ label, key, val }) => (
                      <div key={key}>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5">{label}</p>
                        <input type="time" value={val} onChange={e => upd({ [key]: e.target.value })}
                          className="w-full border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] font-semibold focus:ring-2 focus:ring-amber-500 focus:border-amber-400 outline-none" />
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* ── Copy ── */}
            {tab === 'copy' && (
              <div className="space-y-4">
                <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4">
                  <p className="font-bold text-blue-800 text-[14px] mb-1">Apply {day.day}'s Schedule to All Days</p>
                  <p className="text-blue-600 text-[12px] font-medium">Overwrites working hours and break settings for all other days.</p>
                </div>
                <button
                  onClick={() => { onCopyToAll(day.day); onClose(); }}
                  className="w-full flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-[14px] py-3.5 rounded-2xl shadow-lg shadow-indigo-200 transition-all active:scale-95"
                >
                  <Copy className="w-4 h-4" /> Apply to All Days
                </button>
              </div>
            )}
          </div>
        </div>

        {/* ── Footer ── */}
        <div className="flex items-center justify-between px-6 py-4 border-t border-slate-200 bg-slate-50/50 shrink-0">
          <div className="flex items-center gap-2">
            <span className={cn('w-2.5 h-2.5 rounded-full', local.enabled ? 'bg-emerald-400' : 'bg-rose-400')} />
            <span className="text-[13px] font-bold text-slate-600">{local.enabled ? 'Working Day' : 'Holiday / Off'}</span>
          </div>
          <div className="flex items-center gap-3">
            <button onClick={onClose} className="border border-slate-200 bg-white text-slate-700 text-[13px] font-bold px-4 py-2.5 rounded-xl hover:bg-slate-50 transition-all">
              Cancel
            </button>
            <button
              onClick={() => { onUpdate(local); onClose(); }}
              className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 text-white text-[13px] font-bold px-5 py-2.5 rounded-xl shadow-md shadow-teal-500/20 transition-all active:scale-95"
            >
              <Save className="w-4 h-4" /> Save Changes
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// ─── Day Card ───────────────────────────────────────────────────────────────────
const DayCard = ({ day, slotDuration, onClick }: { day: DaySchedule; slotDuration: number; onClick: () => void }) => {
  const cfg   = DAY_CFG[day.day] ?? { color: 'bg-slate-500', border: 'border-l-slate-300', abbr: 'DAY' };
  const slots = countSlots(day, slotDuration);

  return (
    <div
      onClick={onClick}
      className={cn(
        'bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-lg hover:-translate-y-1 transition-all duration-200 cursor-pointer group border-l-4',
        day.enabled ? cfg.border : 'border-l-slate-300'
      )}
    >
      {/* Top: Badge + Name + Status */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className={cn('w-12 h-12 rounded-2xl flex items-center justify-center text-white font-black text-[13px] shrink-0 shadow-sm', day.enabled ? cfg.color : 'bg-slate-300')}>
            {cfg.abbr}
          </div>
          <div>
            <p className="font-black text-slate-800 text-[15px] leading-tight">{day.day}</p>
            <p className="text-slate-400 text-[12px] font-semibold mt-0.5">{day.enabled ? (calcHours(day.startTime, day.endTime) || '--') : 'Day Off'}</p>
          </div>
        </div>
        <span className={cn('flex items-center gap-1 text-[11px] font-black px-2.5 py-1 rounded-full border', day.enabled ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-rose-50 text-rose-600 border-rose-200')}>
          <span className={cn('w-2 h-2 rounded-full', day.enabled ? 'bg-emerald-500' : 'bg-rose-400')} />
          {day.enabled ? 'Active' : 'Holiday'}
        </span>
      </div>

      {/* Working hours */}
      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Working Hours</p>
      <p className="font-black text-slate-800 text-[15px] mb-4 leading-tight">
        {day.enabled ? `${fmtTime(day.startTime)} – ${fmtTime(day.endTime)}` : 'No Schedule'}
      </p>

      {/* Slots + Break rows */}
      <div className="space-y-2 mb-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5 text-slate-400 text-[12px] font-medium">
            <Zap className="w-3.5 h-3.5" /> Available Slots
          </div>
          <span className="text-teal-600 font-black text-[13px]">{day.enabled ? `${slots} slots` : '—'}</span>
        </div>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5 text-slate-400 text-[12px] font-medium">
            <Coffee className="w-3.5 h-3.5" /> Break Time
          </div>
          <span className="font-bold text-slate-700 text-[13px]">
            {day.enabled && day.breakEnabled && day.breakStart
              ? `${fmtTime(day.breakStart)} – ${fmtTime(day.breakEnd)}`
              : 'None'}
          </span>
        </div>
      </div>

      {/* Footer */}
      <div className="border-t border-slate-100 pt-3 flex items-center justify-between">
        <span className="text-slate-400 text-[11px] font-semibold">{slotDuration} min / slot</span>
        <span className="flex items-center gap-1 text-teal-600 text-[12px] font-black transition-colors group-hover:gap-2">
          Edit Schedule <ChevronRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
        </span>
      </div>
    </div>
  );
};

// ─── Page ───────────────────────────────────────────────────────────────────────
const SchedulePage = () => {
  const [schedule,  setSchedule]  = useState<WeeklySchedule>(DEFAULT_SCHEDULE);
  const [selected,  setSelected]  = useState<DaySchedule | null>(null);
  const [filter,    setFilter]    = useState<'All' | 'Active' | 'Holiday'>('All');
  const [isSaving,  setIsSaving]  = useState(false);
  const [savedAt,   setSavedAt]   = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [slotDur,   setSlotDur]   = useState<SlotDuration>(30);

  const SLOT_OPTIONS: { value: SlotDuration; label: string }[] = [
    { value: 15, label: '15 min' },
    { value: 30, label: '30 min' },
    { value: 60, label: '1 hr'   },
  ];

  useEffect(() => {
    scheduleService.getWeeklySchedule().then(data => {
      if (data) { setSchedule(data); setSlotDur(data.slotDuration); }
      setIsLoading(false);
    });
  }, []);

  const updateDay = (updated: DaySchedule) =>
    setSchedule(prev => ({ ...prev, days: prev.days.map(d => d.day === updated.day ? updated : d) }));

  const copyToAll = (src: string) => {
    const source = schedule.days.find(d => d.day === src);
    if (!source) return;
    setSchedule(prev => ({
      ...prev,
      days: prev.days.map(d => d.day === src ? d : {
        ...d, startTime: source.startTime, endTime: source.endTime,
        breakEnabled: source.breakEnabled, breakStart: source.breakStart, breakEnd: source.breakEnd,
      }),
    }));
  };

  const handleSave = async () => {
    setIsSaving(true);
    await scheduleService.saveWeeklySchedule({ ...schedule, slotDuration: slotDur });
    setIsSaving(false);
    setSavedAt(new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
  };

  const enabledCount = schedule.days.filter(d => d.enabled).length;
  const totalSlots   = schedule.days.reduce((sum, d) => sum + countSlots(d, slotDur), 0);

  const FILTERS = ['All', 'Active', 'Holiday'] as const;
  const displayed = schedule.days.filter(d => {
    if (filter === 'Active')  return d.enabled;
    if (filter === 'Holiday') return !d.enabled;
    return true;
  });

  return (
    <div className="max-w-6xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">

      {/* ── Header ── */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5">
        <div>
          <h1 className="text-[20px] sm:text-[22px] font-black text-slate-800">Weekly Schedule</h1>
          <p className="text-[12px] sm:text-[13px] text-slate-500 font-medium mt-0.5">
            {enabledCount} working days · {totalSlots} total slots this week
          </p>
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          {/* Slot duration picker */}
          <div className="flex items-center gap-1 bg-white border border-slate-200 rounded-xl p-1 shadow-sm">
            {SLOT_OPTIONS.map(({ value, label }) => (
              <button
                key={value}
                onClick={() => setSlotDur(value)}
                className={cn('px-2.5 sm:px-3 py-1.5 rounded-lg text-[11px] sm:text-[12px] font-bold transition-all', slotDur === value ? 'bg-teal-600 text-white shadow-sm' : 'text-slate-500 hover:text-slate-700')}
              >
                {label}
              </button>
            ))}
          </div>
          {/* Save */}
          <button
            onClick={handleSave} disabled={isSaving}
            className={cn('flex items-center gap-1.5 text-[13px] font-bold px-4 py-2.5 rounded-xl shadow-md transition-all active:scale-95 flex-1 sm:flex-none justify-center', isSaving ? 'bg-teal-400 cursor-not-allowed text-white' : 'bg-teal-600 hover:bg-teal-700 text-white shadow-teal-500/20')}
          >
            {isSaving
              ? <><span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Saving…</>
              : <><Save className="w-4 h-4" /> {savedAt ? `Saved ${savedAt}` : 'Save Schedule'}</>
            }
          </button>
        </div>
      </div>

      {/* ── Filter Tabs + Stats ── */}
      <div className="flex items-center gap-2 mb-6 overflow-x-auto hide-scrollbar pb-1">
        {FILTERS.map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={cn('px-4 py-2 rounded-xl text-[13px] font-bold whitespace-nowrap transition-all border',
              filter === f ? 'bg-teal-600 text-white border-teal-600 shadow-sm' : 'bg-white text-slate-500 border-slate-200 hover:border-teal-300 hover:text-teal-600'
            )}
          >
            {f}
            {f !== 'All' && (
              <span className={cn('ml-1.5 text-[10px] font-black px-1.5 py-0.5 rounded-full', filter === f ? 'bg-teal-500 text-white' : 'bg-slate-100 text-slate-500')}>
                {f === 'Active' ? enabledCount : 7 - enabledCount}
              </span>
            )}
          </button>
        ))}
        <div className="ml-auto flex items-center gap-2">
          <div className="flex items-center gap-1.5 bg-white border border-slate-200 rounded-xl px-3 py-1.5 text-[12px] font-bold text-slate-600 shadow-sm whitespace-nowrap">
            <Zap className="w-3.5 h-3.5 text-teal-500" /> {totalSlots} slots / week
          </div>
          <div className="flex items-center gap-1.5 bg-white border border-slate-200 rounded-xl px-3 py-1.5 text-[12px] font-bold text-slate-600 shadow-sm whitespace-nowrap">
            <Clock className="w-3.5 h-3.5 text-blue-500" /> {slotDur} min
          </div>
        </div>
      </div>

      {/* ── Card Grid ── */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
          {Array.from({ length: 7 }).map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-slate-200 p-5 h-52 animate-pulse">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-12 h-12 rounded-2xl bg-slate-100" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-slate-100 rounded-lg w-24" />
                  <div className="h-3 bg-slate-100 rounded-lg w-16" />
                </div>
              </div>
              <div className="space-y-2.5">
                <div className="h-3 bg-slate-100 rounded w-full" />
                <div className="h-3 bg-slate-100 rounded w-3/4" />
                <div className="h-3 bg-slate-100 rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
          {displayed.map(day => (
            <DayCard key={day.day} day={day} slotDuration={slotDur} onClick={() => setSelected(day)} />
          ))}
        </div>
      )}

      {/* ── Day Detail Modal ── */}
      {selected && (
        <DayDetailModal
          day={selected}
          slotDuration={slotDur}
          onClose={() => setSelected(null)}
          onUpdate={updated => { updateDay(updated); setSelected(null); }}
          onCopyToAll={copyToAll}
        />
      )}
    </div>
  );
};

export default SchedulePage;
