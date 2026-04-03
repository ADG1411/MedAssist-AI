import { Clock, Wifi, Building2, Stethoscope, Syringe, AlertTriangle, CreditCard, CheckCircle2, Shield, Eye, FileText } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState } from '../../types/caseflow';

interface Props {
  data: CaseFlowState;
  onChange: (visit: CaseFlowState['visit']) => void;
}

const PURPOSE_META = {
  checkup:   { label: 'Checkup',   icon: Stethoscope,   color: 'text-blue-600',   bg: 'bg-blue-50',   border: 'border-blue-200'   },
  surgery:   { label: 'Surgery',   icon: Syringe,       color: 'text-purple-600', bg: 'bg-purple-50', border: 'border-purple-200' },
  emergency: { label: 'Emergency', icon: AlertTriangle, color: 'text-rose-600',   bg: 'bg-rose-50',   border: 'border-rose-200'   },
};

const PAYMENT_META = {
  pending:   { label: 'Pending',   icon: CreditCard,   color: 'text-amber-600',   bg: 'bg-amber-50',   border: 'border-amber-200'   },
  paid:      { label: 'Paid',      icon: CheckCircle2, color: 'text-emerald-600', bg: 'bg-emerald-50', border: 'border-emerald-200' },
  insurance: { label: 'Insurance', icon: Shield,       color: 'text-blue-600',    bg: 'bg-blue-50',    border: 'border-blue-200'    },
};

const InfoBadge = ({ label, value }: { label: string; value: string }) => (
  <div className="bg-slate-50 rounded-xl p-3.5 border border-slate-100">
    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
    <p className="text-[14px] font-black text-slate-800">{value}</p>
  </div>
);

export const Step2VisitDetails = ({ data }: Props) => {
  const { visit, patient } = data;

  const purpose   = PURPOSE_META[visit.purpose]      ?? PURPOSE_META.checkup;
  const payment   = PAYMENT_META[visit.paymentStatus] ?? PAYMENT_META.pending;
  const PaymentIcon = payment.icon;
  const VisitIcon   = visit.visitType === 'online' ? Wifi : Building2;

  const todayStr = new Date().toLocaleDateString('en-IN', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  });

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* Read-only notice */}
      <div className="flex items-center gap-2.5 bg-blue-50 border border-blue-100 rounded-2xl px-4 py-3">
        <Eye className="w-4 h-4 text-blue-500 shrink-0" />
        <p className="text-[12px] font-semibold text-blue-600">
          Visit details are pre-filled from the case record. Only the doctor can view this information.
        </p>
      </div>

      {/* Row 1 — Time + Visit Type */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">

        {/* Appointment Time */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-7 h-7 bg-blue-50 rounded-lg flex items-center justify-center">
              <Clock className="w-4 h-4 text-blue-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Appointment Time</span>
          </div>
          <p className="text-4xl font-black text-slate-800 tracking-tight mb-2">
            {visit.appointmentTime || '—'}
          </p>
          <p className="text-[12px] text-slate-400 font-medium">Today · {todayStr}</p>
        </div>

        {/* Visit Type */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <p className="font-black text-slate-800 text-[14px] mb-4">Visit Type</p>
          <div className="grid grid-cols-2 gap-3">
            {([
              { id: 'online',  label: 'Online',  Icon: Wifi,      desc: 'Video consultation'  },
              { id: 'offline', label: 'Offline', Icon: Building2, desc: 'Hospital / OPD visit' },
            ] as const).map(({ id, label, Icon, desc }) => {
              const active = visit.visitType === id;
              return (
                <div key={id} className={cn(
                  'flex flex-col items-center gap-2 p-4 rounded-2xl border-2',
                  active ? 'border-teal-500 bg-teal-50' : 'border-slate-100 bg-slate-50 opacity-40'
                )}>
                  <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center', active ? 'bg-teal-500' : 'bg-slate-200')}>
                    <Icon className={cn('w-5 h-5', active ? 'text-white' : 'text-slate-400')} />
                  </div>
                  <p className={cn('text-[13px] font-black', active ? 'text-teal-700' : 'text-slate-400')}>{label}</p>
                  <p className="text-[10px] text-slate-400 font-medium text-center">{desc}</p>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Row 2 — Purpose */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
        <p className="font-black text-slate-800 text-[14px] mb-4">Purpose of Visit</p>
        <div className="grid grid-cols-3 gap-3">
          {(['checkup', 'surgery', 'emergency'] as const).map(key => {
            const meta   = PURPOSE_META[key];
            const Icon   = meta.icon;
            const active = visit.purpose === key;
            return (
              <div key={key} className={cn(
                'flex flex-col items-center gap-2 p-4 rounded-2xl border-2',
                active ? cn(meta.bg, meta.border) : 'border-slate-100 bg-slate-50 opacity-40'
              )}>
                <Icon className={cn('w-6 h-6', active ? meta.color : 'text-slate-300')} />
                <span className={cn('text-[12px] font-black', active ? meta.color : 'text-slate-400')}>{meta.label}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Row 3 — Summary grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <InfoBadge label="Visit Mode"    value={visit.visitType === 'online' ? 'Online (Video)' : 'Offline (OPD)'} />
        <InfoBadge label="Purpose"       value={purpose.label} />
        <InfoBadge label="Patient"       value={`${patient.age} yrs · ${patient.gender}`} />
        <InfoBadge label="Procedure"     value={patient.procedure} />
      </div>

      {/* Row 4 — Payment Status */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
        <p className="font-black text-slate-800 text-[14px] mb-4">Payment Status</p>
        <div className="flex items-center gap-3 flex-wrap">
          {(['pending', 'paid', 'insurance'] as const).map(key => {
            const meta   = PAYMENT_META[key];
            const Icon   = meta.icon;
            const active = visit.paymentStatus === key;
            return (
              <div key={key} className={cn(
                'flex items-center gap-2 px-4 py-2.5 rounded-xl border-2 text-[13px] font-bold',
                active ? cn(meta.bg, meta.border, meta.color) : 'border-slate-100 bg-slate-50 text-slate-300'
              )}>
                <Icon className="w-4 h-4" />
                {meta.label}
              </div>
            );
          })}
        </div>
      </div>

      {/* Row 5 — Visit Notes (read-only) */}
      {visit.notes ? (
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-7 h-7 bg-amber-50 rounded-lg flex items-center justify-center">
              <FileText className="w-4 h-4 text-amber-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Visit Notes</span>
          </div>
          <p className="text-[13px] font-medium text-slate-600 bg-slate-50 rounded-xl p-4 border border-slate-100 leading-relaxed">
            {visit.notes}
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl p-5 border border-dashed border-slate-200 text-center">
          <p className="text-[12px] font-medium text-slate-400">No additional visit notes on record</p>
        </div>
      )}

      {/* Cost info */}
      <div className={cn(
        'flex items-center justify-between px-5 py-4 rounded-2xl border',
        'bg-gradient-to-r from-teal-50 to-blue-50 border-teal-100'
      )}>
        <div className="flex items-center gap-3">
          <VisitIcon className="w-5 h-5 text-teal-500" />
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Estimated Cost</p>
            <p className="text-[15px] font-black text-teal-700">
              ₹{(patient.costMin / 1000).toFixed(0)}k – {(patient.costMax / 1000).toFixed(0)}k
            </p>
          </div>
        </div>
        <div className="text-right">
          <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Urgency</p>
          <p className="text-[14px] font-black text-slate-700">{patient.urgency}</p>
        </div>
        <div className={cn('flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-[12px] font-bold', payment.bg, payment.border, payment.color)}>
          <PaymentIcon className="w-3.5 h-3.5" />
          {payment.label}
        </div>
      </div>
    </div>
  );
};
