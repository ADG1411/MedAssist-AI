import type { Appointment } from '../types/appointment';
import { Video, MapPin, Clock, CheckCircle2, ChevronRight, Zap } from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

interface AppointmentCardProps {
  appointment: Appointment;
  onStart: (apt: Appointment) => void;
  isActive?: boolean;
}

const STATUS_CONFIG: Record<string, { dot: string; pill: string; label: string }> = {
  'Waiting':     { dot: 'bg-amber-400',   pill: 'text-amber-600 bg-amber-50',    label: 'Waiting'     },
  'Pending':     { dot: 'bg-slate-300',   pill: 'text-slate-500 bg-slate-100',   label: 'Pending'     },
  'In Progress': { dot: 'bg-blue-400 animate-pulse', pill: 'text-blue-600 bg-blue-50',   label: 'In Progress' },
  'Completed':   { dot: 'bg-emerald-400', pill: 'text-emerald-600 bg-emerald-50', label: 'Done'        },
};

export const AppointmentCard = ({ appointment, onStart, isActive }: AppointmentCardProps) => {
  const isEmergency = appointment.priority === 'Emergency';
  const isOnline    = appointment.type    === 'online';
  const isCompleted = appointment.status  === 'Completed';
  const sc = STATUS_CONFIG[appointment.status] ?? STATUS_CONFIG['Pending'];
  const timeStr = appointment.timeSlot.split(' - ')[0];

  return (
    <div
      onClick={() => !isCompleted && onStart(appointment)}
      className={cn(
        'group relative overflow-hidden rounded-2xl border transition-all duration-200 select-none',
        !isCompleted && 'cursor-pointer',
        isActive
          ? 'bg-blue-50 border-blue-200 shadow-md shadow-blue-100/60'
          : isEmergency
            ? 'bg-rose-50/60 border-rose-200 hover:border-rose-300 hover:shadow-sm'
            : 'bg-white border-slate-200 hover:border-blue-200 hover:shadow-md hover:-translate-y-0.5'
      )}
    >
      {/* Priority left stripe */}
      <div className={cn(
        'absolute left-0 inset-y-0 w-1 rounded-l-2xl',
        isActive        ? 'bg-blue-500'
        : isEmergency   ? 'bg-rose-500'
        : appointment.isNext ? 'bg-blue-400'
        : 'bg-transparent'
      )} />

      <div className="px-4 py-3.5 pl-5">

        {/* ── Row 1: Avatar · Name · Time ── */}
        <div className="flex items-start gap-3 mb-2.5">
          {/* Round avatar */}
          <div className="relative shrink-0">
            <img
              src={appointment.avatar}
              alt={appointment.patientName}
              className={cn(
                'w-10 h-10 rounded-full object-cover border-2 shadow-sm',
                isActive ? 'border-blue-300' : isEmergency ? 'border-rose-300' : 'border-white'
              )}
            />
            {isEmergency && (
              <span className="absolute -top-0.5 -right-0.5 w-3.5 h-3.5 bg-rose-500 rounded-full border-2 border-white flex items-center justify-center">
                <Zap className="w-2 h-2 text-white fill-white" />
              </span>
            )}
            {isOnline && !isEmergency && (
              <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-emerald-400 rounded-full border-2 border-white" />
            )}
          </div>

          {/* Name + age */}
          <div className="flex-1 min-w-0 pt-0.5">
            <p className={cn(
              'font-black text-[14px] leading-tight truncate',
              isActive ? 'text-blue-700' : isEmergency ? 'text-rose-700' : 'text-slate-800'
            )}>
              {appointment.patientName}
            </p>
            <p className="text-[11px] font-semibold text-slate-400 mt-0.5">
              {appointment.patientAge} yrs
            </p>
          </div>

          {/* Time + delay */}
          <div className="text-right shrink-0 pt-0.5">
            <div className={cn(
              'flex items-center gap-1 text-[11px] font-bold whitespace-nowrap',
              isActive ? 'text-blue-500' : 'text-slate-500'
            )}>
              <Clock className="w-3 h-3" />
              {timeStr}
            </div>
            {appointment.delayMins && (
              <span className="mt-1 inline-block text-[9px] font-black text-orange-600 bg-orange-100 px-1.5 py-0.5 rounded-md">
                +{appointment.delayMins}m
              </span>
            )}
          </div>
        </div>

        {/* ── Row 2: Symptoms ── */}
        <p className={cn(
          'text-[11px] font-medium truncate mb-2.5 pl-0.5',
          isActive ? 'text-blue-500' : 'text-slate-400'
        )}>
          🩺 {appointment.symptoms}
        </p>

        {/* ── Row 3: Type · Status · Chevron ── */}
        <div className="flex items-center gap-2">
          {/* Type */}
          <span className={cn(
            'flex items-center gap-1 text-[10px] font-bold px-2 py-1 rounded-lg',
            isOnline ? 'bg-sky-100 text-sky-600' : 'bg-indigo-50 text-indigo-500'
          )}>
            {isOnline ? <Video className="w-3 h-3" /> : <MapPin className="w-3 h-3" />}
            {isOnline ? 'Video' : appointment.roomNumber}
          </span>

          {/* Status */}
          {isCompleted ? (
            <span className="flex items-center gap-1 text-[10px] font-bold px-2 py-1 rounded-lg bg-emerald-50 text-emerald-600">
              <CheckCircle2 className="w-3 h-3" /> Done
            </span>
          ) : (
            <span className={cn('flex items-center gap-1 text-[10px] font-bold px-2 py-1 rounded-lg', sc.pill)}>
              <span className={cn('w-1.5 h-1.5 rounded-full shrink-0', sc.dot)} />
              {sc.label}
            </span>
          )}

          {/* Chevron */}
          {!isCompleted && (
            <div className={cn(
              'ml-auto w-7 h-7 rounded-xl flex items-center justify-center transition-all shrink-0',
              isActive
                ? 'bg-blue-100 text-blue-500'
                : 'bg-slate-100 text-slate-400 group-hover:bg-blue-50 group-hover:text-blue-500'
            )}>
              <ChevronRight className="w-3.5 h-3.5" />
            </div>
          )}
        </div>

      </div>
    </div>
  );
};