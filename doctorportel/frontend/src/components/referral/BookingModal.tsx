import { useState } from 'react';
import { X, MapPin, Star, Clock, Loader2, CheckCircle2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import type { BookingType, Provider } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  bookingType: BookingType;
  providers: Provider[];
  referralId: string;
  onConfirm: (providerId: string, date: string, timeSlot: string) => Promise<void>;
  onClose: () => void;
}

const TYPE_LABEL: Record<BookingType, string> = {
  lab: 'Lab Test', hospital: 'Hospital Visit', specialist: 'Specialist Consultation',
};

const TYPE_COLOR: Record<BookingType, string> = {
  lab: 'bg-teal-500', hospital: 'bg-blue-500', specialist: 'bg-violet-500',
};

function getTodayAndNext6(): string[] {
  const dates: string[] = [];
  for (let i = 0; i < 7; i++) {
    const d = new Date();
    d.setDate(d.getDate() + i);
    dates.push(d.toISOString().split('T')[0]);
  }
  return dates;
}

function formatDate(iso: string): { day: string; date: string; month: string } {
  const d = new Date(iso);
  return {
    day:   d.toLocaleDateString('en-IN', { weekday: 'short' }),
    date:  d.getDate().toString(),
    month: d.toLocaleDateString('en-IN', { month: 'short' }),
  };
}

export function BookingModal({ bookingType, providers, onConfirm, onClose }: Props) {
  const [selectedProvider, setProvider] = useState<Provider | null>(null);
  const [selectedDate,     setDate]     = useState(getTodayAndNext6()[0]);
  const [selectedSlot,     setSlot]     = useState('');
  const [booking, setBooking] = useState(false);
  const dates = getTodayAndNext6();

  const handleConfirm = async () => {
    if (!selectedProvider || !selectedSlot) return;
    setBooking(true);
    try { await onConfirm(selectedProvider.id, selectedDate, selectedSlot); }
    finally { setBooking(false); }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/50 backdrop-blur-sm p-0 sm:p-4"
      onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
      <motion.div
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 40 }}
        transition={{ type: 'spring', damping: 25, stiffness: 300 }}
        className="bg-white rounded-t-3xl sm:rounded-3xl w-full sm:max-w-lg max-h-[92vh] flex flex-col overflow-hidden shadow-2xl"
      >
        {/* Header */}
        <div className={cn('px-5 py-4 text-white flex items-center justify-between shrink-0', TYPE_COLOR[bookingType])}>
          <div>
            <p className="text-[11px] font-bold opacity-70 uppercase tracking-widest">Book Service</p>
            <h3 className="text-lg font-black">{TYPE_LABEL[bookingType]}</h3>
          </div>
          <button onClick={onClose} className="w-8 h-8 bg-white/20 rounded-xl flex items-center justify-center hover:bg-white/30 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-5 space-y-5">

          {/* Step 1 – Choose Provider */}
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">Step 1 · Choose Provider</p>
            <div className="space-y-2">
              {providers.map(p => (
                <button key={p.id} onClick={() => { setProvider(p); setSlot(''); }}
                  className={cn('w-full text-left rounded-2xl border-2 p-3.5 transition-all',
                    selectedProvider?.id === p.id ? 'border-teal-400 bg-teal-50' : 'border-slate-200 bg-white hover:border-slate-300')}>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex-1 min-w-0">
                      <p className="font-black text-slate-800 text-[14px] truncate">{p.name}</p>
                      <div className="flex items-center gap-1.5 mt-0.5">
                        <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
                        <p className="text-[11px] text-slate-500 truncate">{p.address}</p>
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      <div className="flex items-center gap-1 justify-end">
                        <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                        <span className="text-[12px] font-bold text-slate-700">{p.rating}</span>
                      </div>
                      <p className="text-[11px] text-slate-400">{p.distance_km} km</p>
                    </div>
                  </div>
                  {selectedProvider?.id === p.id && (
                    <div className="mt-1 flex items-center gap-1.5">
                      <CheckCircle2 className="w-3.5 h-3.5 text-teal-500" />
                      <span className="text-[11px] font-bold text-teal-600">Selected</span>
                    </div>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Step 2 – Choose Date */}
          <AnimatePresence>
            {selectedProvider && (
              <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>
                <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">Step 2 · Choose Date</p>
                <div className="flex gap-2 overflow-x-auto pb-1">
                  {dates.map(d => {
                    const f = formatDate(d);
                    const isToday = d === getTodayAndNext6()[0];
                    return (
                      <button key={d} onClick={() => { setDate(d); setSlot(''); }}
                        className={cn('flex flex-col items-center rounded-xl border-2 px-3 py-2.5 min-w-[58px] transition-all',
                          selectedDate === d ? 'border-teal-400 bg-teal-50' : 'border-slate-200 bg-white hover:border-slate-300')}>
                        <span className={cn('text-[10px] font-bold', selectedDate === d ? 'text-teal-600' : 'text-slate-400')}>
                          {isToday ? 'Today' : f.day}
                        </span>
                        <span className={cn('text-xl font-black leading-tight', selectedDate === d ? 'text-teal-700' : 'text-slate-700')}>
                          {f.date}
                        </span>
                        <span className={cn('text-[10px]', selectedDate === d ? 'text-teal-500' : 'text-slate-400')}>{f.month}</span>
                      </button>
                    );
                  })}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Step 3 – Choose Time Slot */}
          <AnimatePresence>
            {selectedProvider && selectedDate && (
              <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>
                <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">Step 3 · Choose Time</p>
                <div className="grid grid-cols-3 gap-2">
                  {selectedProvider.available_slots.map(slot => (
                    <button key={slot} onClick={() => setSlot(slot)}
                      className={cn('flex items-center justify-center gap-1.5 rounded-xl border-2 py-2.5 text-[13px] font-bold transition-all',
                        selectedSlot === slot ? 'border-teal-400 bg-teal-50 text-teal-700' : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300')}>
                      <Clock className="w-3 h-3" />
                      {slot}
                    </button>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

        </div>

        {/* Confirm Button */}
        <div className="p-4 border-t border-slate-100 shrink-0">
          <button onClick={handleConfirm}
            disabled={!selectedProvider || !selectedSlot || booking}
            className={cn('w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl font-black text-[15px] text-white transition-all shadow-lg disabled:opacity-40',
              TYPE_COLOR[bookingType], !TYPE_COLOR[bookingType] && 'bg-slate-400')}>
            {booking ? <Loader2 className="w-5 h-5 animate-spin" /> : <CheckCircle2 className="w-5 h-5" />}
            {booking ? 'Booking…' : 'Confirm Booking'}
          </button>
        </div>
      </motion.div>
    </div>
  );
}
