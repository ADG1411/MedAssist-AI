import { useState, useCallback } from 'react';
import {
  Clock, Plus, Trash2, Zap, Eye, CalendarDays,
  AlertTriangle, CheckCircle2, X, Copy, ChevronDown, ChevronUp
} from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import { scheduleService } from '../../services/scheduleService';

// ── Types ──────────────────────────────────────────────────────────────────────
type TimeSlot     = { start: string; end: string };
type DaySchedule  = Record<string, TimeSlot[]>;
type SlotDuration = 15 | 30 | 60;

interface Override {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  reason: string;
  isHoliday: boolean;
}

interface GeneratedSlot {
  time: string;
  displayTime: string;
  isBreak: boolean;
  available: boolean;
}

// ── Constants ─────────────────────────────────────────────────────────────────
const DAYS      = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const FULL_DAYS: Record<string, string> = {
  Mon: 'Monday', Tue: 'Tuesday', Wed: 'Wednesday', Thu: 'Thursday',
  Fri: 'Friday', Sat: 'Saturday', Sun: 'Sunday',
};

const INITIAL_SCHEDULE: DaySchedule = {
  Mon: [{ start: '09:00', end: '13:00' }, { start: '14:00', end: '17:00' }],
  Tue: [{ start: '09:00', end: '13:00' }, { start: '14:00', end: '17:00' }],
  Wed: [{ start: '09:00', end: '13:00' }, { start: '14:00', end: '17:00' }],
  Thu: [{ start: '09:00', end: '13:00' }, { start: '14:00', end: '17:00' }],
  Fri: [{ start: '09:00', end: '13:00' }, { start: '14:00', end: '17:00' }],
  Sat: [],
  Sun: [],
};

const SLOT_DURATIONS: { value: SlotDuration; label: string }[] = [
  { value: 15, label: '15 min' },
  { value: 30, label: '30 min' },
  { value: 60, label: '1 hour' },
];

const EMPTY_OVERRIDE = { date: '', startTime: '09:00', endTime: '18:00', reason: '', isHoliday: false };

// ── Slot generation helper ────────────────────────────────────────────────────
function generateSlots(slots: TimeSlot[], duration: number): GeneratedSlot[] {
  const result: GeneratedSlot[] = [];
  for (const slot of slots) {
    if (!slot.start || !slot.end) continue;
    const [sh, sm] = slot.start.split(':').map(Number);
    const [eh, em] = slot.end.split(':').map(Number);
    let cur = sh * 60 + sm;
    const end = eh * 60 + em;
    while (cur < end) {
      const h = Math.floor(cur / 60), m = cur % 60;
      const ampm = h >= 12 ? 'PM' : 'AM';
      result.push({
        time: `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}`,
        displayTime: `${h % 12 || 12}:${String(m).padStart(2,'0')} ${ampm}`,
        isBreak: false,
        available: true,
      });
      cur += duration;
    }
  }
  return result;
}

function fmt(t: string) {
  if (!t) return '--';
  const [h, m] = t.split(':').map(Number);
  return `${h % 12 || 12}:${String(m).padStart(2,'0')} ${h >= 12 ? 'PM' : 'AM'}`;
}

// ── Component ─────────────────────────────────────────────────────────────────
type SectionId = 'schedule' | 'preview' | 'slots' | 'overrides';

export const AvailabilityTab = () => {
  const [activeDay, setActiveDay]         = useState('Mon');
  const [smartBooking, setSmartBooking]   = useState(true);
  const [schedule, setSchedule]           = useState<DaySchedule>(INITIAL_SCHEDULE);
  const [slotDuration, setSlotDuration]   = useState<SlotDuration>(30);
  const [activeSection, setActiveSection] = useState<SectionId>('schedule');
  const [generatedSlots, setGeneratedSlots] = useState<GeneratedSlot[] | null>(null);
  const [genDay, setGenDay]               = useState('Mon');
  const [overrides, setOverrides]         = useState<Override[]>([]);
  const [showOverrideForm, setShowOverrideForm] = useState(false);
  const [overrideForm, setOverrideForm]   = useState(EMPTY_OVERRIDE);
  const [isSaving, setIsSaving]           = useState(false);
  const [savedAt, setSavedAt]             = useState<string | null>(null);
  const [toast, setToast]                 = useState<{ msg: string; type: 'success' | 'error' } | null>(null);

  const showToast = (msg: string, type: 'success' | 'error' = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  // ── Time slot helpers ────────────────────────────────────────────────────────
  const addTimeSlot = () =>
    setSchedule(p => ({ ...p, [activeDay]: [...p[activeDay], { start: '09:00', end: '17:00' }] }));

  const removeTimeSlot = (i: number) =>
    setSchedule(p => ({ ...p, [activeDay]: p[activeDay].filter((_, idx) => idx !== i) }));

  const updateTimeSlot = (i: number, field: 'start' | 'end', val: string) =>
    setSchedule(p => {
      const arr = [...p[activeDay]];
      arr[i] = { ...arr[i], [field]: val };
      return { ...p, [activeDay]: arr };
    });

  // ── Copy to all ──────────────────────────────────────────────────────────────
  const copyToAll = useCallback(() => {
    const src = schedule[activeDay];
    setSchedule(p => Object.fromEntries(DAYS.map(d => [d, d === activeDay ? p[d] : [...src.map(s => ({ ...s }))]
    ])));
    showToast(`${FULL_DAYS[activeDay]}'s schedule applied to all days`);
  }, [activeDay, schedule]);

  // ── Save ─────────────────────────────────────────────────────────────────────
  const handleSave = async () => {
    setIsSaving(true);
    const weeklyPayload = {
      slotDuration,
      days: DAYS.map(d => ({
        day: FULL_DAYS[d],
        enabled: schedule[d].length > 0,
        startTime: schedule[d][0]?.start ?? '09:00',
        endTime: schedule[d][schedule[d].length - 1]?.end ?? '18:00',
        breakEnabled: false,
        breakStart: '',
        breakEnd: '',
      })),
    };
    await scheduleService.saveWeeklySchedule(weeklyPayload);
    setIsSaving(false);
    const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    setSavedAt(now);
    showToast('Schedule saved successfully!');
  };

  // ── Generate slots ───────────────────────────────────────────────────────────
  const handleGenerate = () => {
    const slots = generateSlots(schedule[genDay], slotDuration);
    setGeneratedSlots(slots);
  };

  // ── Overrides ────────────────────────────────────────────────────────────────
  const handleAddOverride = () => {
    if (!overrideForm.date) { showToast('Please select a date', 'error'); return; }
    setOverrides(p => [{ id: crypto.randomUUID(), ...overrideForm }, ...p]);
    setOverrideForm(EMPTY_OVERRIDE);
    setShowOverrideForm(false);
    showToast('Override added!');
  };

  // ── Section tabs ─────────────────────────────────────────────────────────────
  const SECTIONS: { id: SectionId; label: string; icon: typeof Eye }[] = [
    { id: 'schedule',  label: 'Weekly Schedule', icon: CalendarDays },
    { id: 'preview',   label: 'Preview',         icon: Eye          },
    { id: 'slots',     label: 'Generate Slots',  icon: Zap          },
    { id: 'overrides', label: 'Overrides',       icon: AlertTriangle },
  ];

  return (
    <div className="space-y-5">

      {/* ── Section switcher ── */}
      <div className="flex gap-1 p-1 bg-slate-100 rounded-2xl overflow-x-auto hide-scrollbar">
        {SECTIONS.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            onClick={() => setActiveSection(id)}
            className={cn(
              'flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex-1 justify-center',
              activeSection === id ? 'bg-white text-indigo-700 shadow-sm' : 'text-slate-500 hover:text-slate-700'
            )}
          >
            <Icon className="w-3.5 h-3.5" />{label}
          </button>
        ))}
      </div>

      {/* ══════════════════════════════════════════
          SECTION 1 — Weekly Schedule (day tabs)
      ══════════════════════════════════════════ */}
      {activeSection === 'schedule' && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
          {/* Header */}
          <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4 mb-6">
            <div>
              <h3 className="font-bold text-lg text-slate-800">Weekly Schedule</h3>
              <p className="text-sm text-slate-500">Configure your recurring availability for appointments.</p>
            </div>
            <button
              onClick={() => setSmartBooking(p => !p)}
              className={cn(
                'flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold border transition-colors',
                smartBooking
                  ? 'bg-purple-50 border-purple-200 text-purple-700'
                  : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'
              )}
            >
              <Zap className={cn('w-4 h-4', smartBooking ? 'text-purple-500' : 'text-slate-400')} />
              Smart Scheduling: {smartBooking ? 'ON' : 'OFF'}
            </button>
          </div>

          {/* Slot duration */}
          <div className="flex flex-wrap items-center gap-2 mb-5 p-3 bg-slate-50 rounded-xl border border-slate-200">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wide mr-1">Slot Size:</span>
            {SLOT_DURATIONS.map(({ value, label }) => (
              <button
                key={value}
                onClick={() => setSlotDuration(value)}
                className={cn(
                  'px-3 py-1.5 rounded-lg text-xs font-bold border-2 transition-all',
                  slotDuration === value
                    ? 'bg-indigo-600 text-white border-indigo-600 shadow'
                    : 'bg-white text-slate-600 border-slate-200 hover:border-indigo-300'
                )}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Day tabs */}
          <div className="flex gap-2 overflow-x-auto hide-scrollbar pb-2 mb-6">
            {DAYS.map(day => (
              <button
                key={day}
                onClick={() => setActiveDay(day)}
                className={cn(
                  'px-4 py-2 rounded-lg text-sm font-bold min-w-[56px] flex-1 border transition-colors relative',
                  activeDay === day
                    ? 'bg-brand-blue text-white border-brand-blue'
                    : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
                )}
              >
                {day}
                {schedule[day].length === 0 && (
                  <span className="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-rose-400 border border-white" />
                )}
              </button>
            ))}
          </div>

          {/* Time slots */}
          <div className="space-y-3">
            {schedule[activeDay].length === 0 ? (
              <div className="text-center py-6 text-slate-400 text-sm bg-rose-50 rounded-xl border border-rose-100">
                <span className="font-bold text-rose-500">{FULL_DAYS[activeDay]}</span> is a Holiday — no slots configured.
              </div>
            ) : (
              schedule[activeDay].map((slot, index) => (
                <div key={index} className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 group bg-slate-50/50 p-2 sm:p-0 rounded-xl">
                  <div className="flex-1 flex gap-2 items-center">
                    <div className="flex-1 relative">
                      <Clock className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                      <input
                        type="time" value={slot.start}
                        onChange={e => updateTimeSlot(index, 'start', e.target.value)}
                        className="w-full pl-9 pr-3 py-2.5 bg-white sm:bg-slate-50 border border-slate-200 rounded-xl text-sm outline-none focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/10"
                      />
                    </div>
                    <span className="text-slate-400 font-bold shrink-0">–</span>
                    <div className="flex-1 relative">
                      <Clock className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                      <input
                        type="time" value={slot.end}
                        onChange={e => updateTimeSlot(index, 'end', e.target.value)}
                        className="w-full pl-9 pr-3 py-2.5 bg-white sm:bg-slate-50 border border-slate-200 rounded-xl text-sm outline-none focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/10"
                      />
                    </div>
                  </div>
                  <button
                    onClick={() => removeTimeSlot(index)}
                    className="p-2.5 sm:p-2 text-slate-500 bg-white sm:bg-transparent border sm:border-transparent border-slate-200 sm:text-slate-400 hover:text-red-500 hover:bg-red-50 hover:border-red-100 rounded-lg transition-colors flex justify-center items-center shrink-0"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))
            )}

            <button
              onClick={addTimeSlot}
              className="w-full py-2.5 border-2 border-dashed border-slate-200 text-slate-500 hover:border-brand-blue/50 hover:text-brand-blue rounded-xl text-sm font-bold flex items-center justify-center gap-2 transition-colors"
            >
              <Plus className="w-4 h-4" /> Add Time Slot
            </button>
          </div>

          {/* Footer actions */}
          <div className="flex flex-col sm:flex-row gap-3 mt-6 pt-5 border-t border-slate-100">
            <button
              onClick={copyToAll}
              className="flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl border-2 border-indigo-200 bg-indigo-50 text-indigo-700 text-sm font-bold hover:bg-indigo-100 transition-colors"
            >
              <Copy className="w-4 h-4" />
              Apply {FULL_DAYS[activeDay]} to All Days
            </button>
            <button
              onClick={handleSave}
              disabled={isSaving}
              className={cn(
                'flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl text-white text-sm font-bold transition-all',
                isSaving ? 'bg-indigo-400' : 'bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95'
              )}
            >
              {isSaving
                ? <><span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />Saving…</>
                : <><CheckCircle2 className="w-4 h-4" />Save Schedule</>
              }
            </button>
          </div>
          {savedAt && (
            <p className="text-center text-xs text-emerald-600 font-semibold mt-2">
              ✓ Last saved at {savedAt}
            </p>
          )}
        </div>
      )}

      {/* ══════════════════════════════════════════
          SECTION 2 — Preview
      ══════════════════════════════════════════ */}
      {activeSection === 'preview' && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 space-y-4">
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-bold text-lg text-slate-800">Schedule Preview</h3>
            <span className="text-xs font-bold text-indigo-600 bg-indigo-50 border border-indigo-200 px-3 py-1 rounded-full">
              {slotDuration} min slots
            </span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {DAYS.map(day => {
              const slots = schedule[day];
              const isOff = slots.length === 0;
              return (
                <div
                  key={day}
                  className={cn(
                    'rounded-2xl border p-4 transition-all',
                    isOff ? 'bg-rose-50 border-rose-200' : 'bg-white border-slate-200 shadow-sm'
                  )}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-bold text-slate-800">{FULL_DAYS[day]}</span>
                    {isOff ? (
                      <span className="text-xs font-black text-rose-600 bg-rose-100 border border-rose-200 px-2 py-0.5 rounded-full">Holiday</span>
                    ) : (
                      <span className="text-xs font-bold text-emerald-600 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">Open</span>
                    )}
                  </div>
                  {isOff ? (
                    <p className="text-sm text-rose-400">No appointments</p>
                  ) : (
                    <div className="space-y-1">
                      {slots.map((s, i) => (
                        <div key={i} className="flex items-center gap-1.5 text-sm text-slate-600">
                          <Clock className="w-3.5 h-3.5 text-indigo-400 shrink-0" />
                          {fmt(s.start)} – {fmt(s.end)}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="flex gap-3 pt-2">
            <button
              onClick={() => setActiveSection('schedule')}
              className="flex-1 py-2.5 rounded-xl border-2 border-slate-200 text-slate-600 font-bold text-sm hover:bg-slate-50 flex items-center justify-center gap-2"
            >
              <ChevronUp className="w-4 h-4 rotate-[270deg]" /> Edit Schedule
            </button>
            <button
              onClick={handleSave}
              disabled={isSaving}
              className={cn(
                'flex-1 py-2.5 rounded-xl text-white font-bold text-sm transition-all flex items-center justify-center gap-2',
                isSaving ? 'bg-indigo-400' : 'bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95'
              )}
            >
              {isSaving
                ? <><span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />Saving…</>
                : <><CheckCircle2 className="w-4 h-4" />Save Schedule</>
              }
            </button>
          </div>
        </div>
      )}

      {/* ══════════════════════════════════════════
          SECTION 3 — Generate Slots
      ══════════════════════════════════════════ */}
      {activeSection === 'slots' && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 space-y-5">
          <div>
            <h3 className="font-bold text-lg text-slate-800 flex items-center gap-2">
              <Zap className="w-5 h-5 text-indigo-500" /> Slot Generator
            </h3>
            <p className="text-sm text-slate-500 mt-0.5">
              Auto-create {slotDuration}-minute appointment slots for any working day.
            </p>
          </div>

          {/* Controls */}
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="relative flex-1">
              <select
                value={genDay}
                onChange={e => { setGenDay(e.target.value); setGeneratedSlots(null); }}
                className="w-full appearance-none border-2 border-slate-200 rounded-xl px-4 py-3 pr-10 text-sm font-semibold text-slate-700 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none cursor-pointer"
              >
                {DAYS.map(d => (
                  <option key={d} value={d}>
                    {FULL_DAYS[d]}{schedule[d].length === 0 ? ' (Holiday)' : ''}
                  </option>
                ))}
              </select>
              <ChevronDown className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            </div>
            <button
              onClick={handleGenerate}
              className="flex items-center justify-center gap-2 px-6 py-3 rounded-xl font-bold text-sm text-white bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95 transition-all"
            >
              <Zap className="w-4 h-4" /> Generate
            </button>
          </div>

          {/* Slot grid */}
          {generatedSlots === null && (
            <div className="flex flex-col items-center justify-center py-12 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400">
              <Zap className="w-10 h-10 mb-3 text-slate-300" />
              <p className="font-semibold text-slate-500">Select a day and click Generate</p>
            </div>
          )}
          {generatedSlots !== null && generatedSlots.length === 0 && (
            <div className="text-center py-12 border-2 border-dashed border-rose-200 rounded-2xl text-rose-400 font-semibold">
              {FULL_DAYS[genDay]} is a Holiday — enable it first to generate slots.
            </div>
          )}
          {generatedSlots !== null && generatedSlots.length > 0 && (
            <>
              <div className="flex items-center gap-2 text-sm text-emerald-700 bg-emerald-50 border border-emerald-200 px-3 py-2 rounded-xl font-semibold w-fit">
                <CheckCircle2 className="w-4 h-4" />
                {generatedSlots.length} slots · {FULL_DAYS[genDay]}
              </div>
              <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2">
                {generatedSlots.map(slot => (
                  <div
                    key={slot.time}
                    className="flex flex-col items-center justify-center py-2.5 px-1 rounded-xl border bg-white border-slate-200 text-xs font-bold text-slate-700 hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 cursor-pointer shadow-sm transition-all"
                  >
                    <div className="w-1.5 h-1.5 rounded-full bg-emerald-400 mb-1" />
                    {slot.displayTime}
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      )}

      {/* ══════════════════════════════════════════
          SECTION 4 — Special Day Overrides
      ══════════════════════════════════════════ */}
      {activeSection === 'overrides' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-bold text-lg text-slate-800 flex items-center gap-2">
                <CalendarDays className="w-5 h-5 text-indigo-500" /> Special Day Overrides
              </h3>
              <p className="text-sm text-slate-500 mt-0.5">Mark specific dates as holidays or set custom hours.</p>
            </div>
            <button
              onClick={() => setShowOverrideForm(true)}
              className="flex items-center gap-2 bg-indigo-600 text-white text-sm font-bold px-4 py-2.5 rounded-xl hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95 transition-all"
            >
              <Plus className="w-4 h-4" /> Add
            </button>
          </div>

          {/* Add form */}
          {showOverrideForm && (
            <div className="bg-white rounded-2xl border-2 border-indigo-200 p-5 shadow-lg space-y-4">
              <div className="flex items-center justify-between">
                <h4 className="font-bold text-slate-800">New Override</h4>
                <button
                  onClick={() => { setShowOverrideForm(false); setOverrideForm(EMPTY_OVERRIDE); }}
                  className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-bold text-slate-600 uppercase tracking-wide mb-1.5 block">Date</label>
                  <input
                    type="date"
                    value={overrideForm.date}
                    onChange={e => setOverrideForm(p => ({ ...p, date: e.target.value }))}
                    className="w-full border-2 border-slate-200 rounded-xl px-4 py-2.5 text-sm font-semibold focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="text-xs font-bold text-slate-600 uppercase tracking-wide mb-1.5 block">Reason</label>
                  <input
                    type="text"
                    value={overrideForm.reason}
                    onChange={e => setOverrideForm(p => ({ ...p, reason: e.target.value }))}
                    placeholder="e.g. Conference, Emergency…"
                    className="w-full border-2 border-slate-200 rounded-xl px-4 py-2.5 text-sm font-semibold focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none placeholder:text-slate-400"
                  />
                </div>
              </div>

              {/* Holiday toggle */}
              <div className="flex items-center justify-between p-3 bg-rose-50 rounded-xl border border-rose-200">
                <div className="flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-rose-500" />
                  <span className="text-sm font-bold text-rose-800">Mark as Holiday (full day off)</span>
                </div>
                <button
                  onClick={() => setOverrideForm(p => ({ ...p, isHoliday: !p.isHoliday }))}
                  className={cn(
                    'relative w-12 h-6 rounded-full transition-colors',
                    overrideForm.isHoliday ? 'bg-rose-500' : 'bg-slate-300'
                  )}
                >
                  <span className={cn(
                    'absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform',
                    overrideForm.isHoliday ? 'translate-x-6' : 'translate-x-0'
                  )} />
                </button>
              </div>

              {!overrideForm.isHoliday && (
                <div className="grid grid-cols-2 gap-4">
                  {(['startTime', 'endTime'] as const).map(field => (
                    <div key={field}>
                      <label className="text-xs font-bold text-slate-600 uppercase tracking-wide mb-1.5 block">
                        {field === 'startTime' ? 'Start Time' : 'End Time'}
                      </label>
                      <input
                        type="time"
                        value={overrideForm[field]}
                        onChange={e => setOverrideForm(p => ({ ...p, [field]: e.target.value }))}
                        className="w-full border-2 border-slate-200 rounded-xl px-4 py-2.5 text-sm font-semibold focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
                      />
                    </div>
                  ))}
                </div>
              )}

              <div className="flex gap-3">
                <button
                  onClick={() => { setShowOverrideForm(false); setOverrideForm(EMPTY_OVERRIDE); }}
                  className="flex-1 py-2.5 rounded-xl border-2 border-slate-200 text-slate-600 font-bold text-sm hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddOverride}
                  className="flex-1 py-2.5 rounded-xl bg-indigo-600 text-white font-bold text-sm hover:bg-indigo-700 shadow-lg shadow-indigo-200 active:scale-95 transition-all"
                >
                  Add Override
                </button>
              </div>
            </div>
          )}

          {/* Override list */}
          {overrides.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400">
              <CalendarDays className="w-10 h-10 mb-3 text-slate-300" />
              <p className="font-semibold text-slate-500">No overrides yet</p>
              <p className="text-sm mt-1">Add holidays or custom hours for specific dates</p>
            </div>
          ) : (
            <div className="space-y-2.5">
              {overrides.map(o => (
                <div
                  key={o.id}
                  className={cn(
                    'flex items-center gap-4 p-4 rounded-2xl border',
                    o.isHoliday ? 'bg-rose-50 border-rose-200' : 'bg-white border-slate-200 shadow-sm'
                  )}
                >
                  <div className={cn('w-11 h-11 rounded-xl flex items-center justify-center shrink-0', o.isHoliday ? 'bg-rose-500' : 'bg-indigo-600')}>
                    {o.isHoliday ? <AlertTriangle className="w-5 h-5 text-white" /> : <CalendarDays className="w-5 h-5 text-white" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-slate-800">
                      {new Date(o.date + 'T00:00:00').toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric', year: 'numeric' })}
                    </p>
                    <p className="text-sm text-slate-500 font-medium mt-0.5">
                      {o.isHoliday
                        ? <span className="text-rose-600 font-bold">Holiday — No appointments</span>
                        : `${fmt(o.startTime)} – ${fmt(o.endTime)}`
                      }
                      {o.reason && <span className="ml-2 text-slate-400">· {o.reason}</span>}
                    </p>
                  </div>
                  {o.isHoliday && (
                    <span className="text-xs font-black text-rose-600 bg-rose-100 border border-rose-200 px-2.5 py-1 rounded-full hidden sm:block">
                      HOLIDAY
                    </span>
                  )}
                  <button
                    onClick={() => setOverrides(p => p.filter(x => x.id !== o.id))}
                    className="p-2 rounded-lg text-slate-400 hover:text-rose-500 hover:bg-rose-50 transition-colors shrink-0"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* ── Toast ── */}
      {toast && (
        <div className={cn(
          'fixed bottom-24 md:bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-3 px-5 py-3.5 rounded-2xl shadow-xl text-white text-sm font-bold z-50 animate-in slide-in-from-bottom-4 duration-300',
          toast.type === 'success' ? 'bg-emerald-600' : 'bg-rose-600'
        )}>
          {toast.type === 'success' ? <CheckCircle2 className="w-4 h-4" /> : <AlertTriangle className="w-4 h-4" />}
          {toast.msg}
        </div>
      )}
    </div>
  );
};