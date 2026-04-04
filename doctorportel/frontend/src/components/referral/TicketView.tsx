import { CheckCircle2, MapPin, Calendar, Clock, FlaskConical, Stethoscope, User, RefreshCw } from 'lucide-react';
import { ShowQr } from '../ui/show-qr';
import { motion } from 'framer-motion';
import type { Ticket, BookingType } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

const TYPE_CONFIG: Record<BookingType, { label: string; icon: typeof FlaskConical; color: string; bg: string }> = {
  lab:        { label: 'Lab Test',                 icon: FlaskConical, color: 'text-teal-600',   bg: 'bg-teal-500'   },
  hospital:   { label: 'Hospital Visit',           icon: Stethoscope,  color: 'text-blue-600',   bg: 'bg-blue-500'   },
  specialist: { label: 'Specialist Consultation',  icon: User,         color: 'text-violet-600', bg: 'bg-violet-500' },
};

interface Props {
  ticket: Ticket;
  onNewScan?: () => void;
}

export function TicketView({ ticket, onNewScan }: Props) {
  const cfg = TYPE_CONFIG[ticket.booking_type];
  const Icon = cfg.icon;

  const dateStr = new Date(ticket.date).toLocaleDateString('en-IN', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  });

  const statusColors = {
    active:  'bg-emerald-100 text-emerald-700',
    used:    'bg-slate-100 text-slate-500',
    expired: 'bg-red-100 text-red-600',
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ type: 'spring', bounce: 0.2 }}
      className="space-y-4"
    >
      {/* Success Banner */}
      <div className="flex items-center gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl px-4 py-3">
        <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0" />
        <div>
          <p className="text-[13px] font-black text-emerald-800">Booking Confirmed!</p>
          <p className="text-[11px] text-emerald-600">Your appointment is scheduled. Show this QR at the counter.</p>
        </div>
      </div>

      {/* Ticket Card */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xl overflow-hidden">

        {/* Ticket Header */}
        <div className={cn('px-5 py-4 text-white', cfg.bg)}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[10px] font-bold opacity-70 uppercase tracking-widest">Medical Ticket</p>
              <h2 className="text-xl font-black">{cfg.label}</h2>
            </div>
            <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
              <Icon className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-2 flex items-center gap-2">
            <span className={cn('text-[10px] font-black px-2 py-0.5 rounded-full bg-white/20')}>
              #{ticket.id.slice(-6).toUpperCase()}
            </span>
            <span className={cn('text-[10px] font-black px-2 py-0.5 rounded-full', statusColors[ticket.status])}>
              {ticket.status.toUpperCase()}
            </span>
          </div>
        </div>

        {/* Dashed Divider */}
        <div className="flex items-center px-4 py-0">
          <div className="w-5 h-5 rounded-full bg-slate-100 border border-slate-200 -ml-6 shrink-0" />
          <div className="flex-1 border-t-2 border-dashed border-slate-200 mx-2" />
          <div className="w-5 h-5 rounded-full bg-slate-100 border border-slate-200 -mr-6 shrink-0" />
        </div>

        {/* Ticket Body */}
        <div className="px-5 py-4 space-y-3">
          <div>
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Patient</p>
            <p className="text-[15px] font-black text-slate-800">{ticket.patient_name}</p>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="bg-slate-50 rounded-xl p-3">
              <div className="flex items-center gap-1.5 mb-1">
                <Calendar className="w-3.5 h-3.5 text-slate-400" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Date</p>
              </div>
              <p className="text-[13px] font-black text-slate-700">{dateStr}</p>
            </div>
            <div className="bg-slate-50 rounded-xl p-3">
              <div className="flex items-center gap-1.5 mb-1">
                <Clock className="w-3.5 h-3.5 text-slate-400" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Time</p>
              </div>
              <p className="text-[13px] font-black text-slate-700">{ticket.time_slot}</p>
            </div>
          </div>

          <div className="bg-slate-50 rounded-xl p-3">
            <div className="flex items-center gap-1.5 mb-1">
              <MapPin className="w-3.5 h-3.5 text-slate-400" />
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Provider</p>
            </div>
            <p className="text-[13px] font-black text-slate-700">{ticket.provider_name}</p>
            <p className="text-[11px] text-slate-500 mt-0.5">{ticket.provider_address}</p>
          </div>
        </div>

        {/* Dashed Divider */}
        <div className="flex items-center px-4 py-0">
          <div className="w-5 h-5 rounded-full bg-slate-100 border border-slate-200 -ml-6 shrink-0" />
          <div className="flex-1 border-t-2 border-dashed border-slate-200 mx-2" />
          <div className="w-5 h-5 rounded-full bg-slate-100 border border-slate-200 -mr-6 shrink-0" />
        </div>

        {/* QR Code Section */}
        <div className="px-5 py-3 flex flex-col items-center gap-1">
          <ShowQr value={ticket.qr_token} buttonLabel="SCAN AT COUNTER" />
          <p className="text-[10px] font-mono text-slate-300 tracking-widest mt-1">
            {ticket.id.slice(-10).toUpperCase()}
          </p>
        </div>
      </div>

      {/* Instructions */}
      <div className="bg-amber-50 border border-amber-100 rounded-2xl p-4 space-y-1.5">
        <p className="text-[11px] font-black text-amber-700 uppercase tracking-wider">Instructions</p>
        <p className="text-[12px] text-amber-800">• Arrive 10 minutes before your appointment</p>
        <p className="text-[12px] text-amber-800">• Carry a government-issued photo ID</p>
        <p className="text-[12px] text-amber-800">• Show this QR code at the reception desk</p>
        {ticket.booking_type === 'lab' && (
          <p className="text-[12px] text-amber-800">• If blood test: fast for 8–12 hours beforehand</p>
        )}
      </div>

      {onNewScan && (
        <button onClick={onNewScan}
          className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl border-2 border-slate-200 text-slate-600 font-bold text-[14px] hover:bg-slate-50 transition-colors">
          <RefreshCw className="w-4 h-4" />
          Scan Another QR
        </button>
      )}
    </motion.div>
  );
}
