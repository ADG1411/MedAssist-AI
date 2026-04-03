import { User, Stethoscope, FlaskConical, FileText, Calendar, TestTube, ArrowRight } from 'lucide-react';
import type { Referral } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

const TYPE_COLORS: Record<string, string> = {
  specialist: 'bg-violet-100 text-violet-700',
  hospital:   'bg-blue-100 text-blue-700',
  lab:        'bg-teal-100 text-teal-700',
  emergency:  'bg-red-100 text-red-700',
};

interface Props {
  referral: Referral;
  onBookLab?:        () => void;
  onBookHospital?:   () => void;
  onBookSpecialist?: () => void;
}

export function ReferralDetails({ referral, onBookLab, onBookHospital, onBookSpecialist }: Props) {
  const expiresDate = new Date(referral.expires_at).toLocaleString('en-IN', {
    day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit',
  });

  return (
    <div className="space-y-4">

      {/* Patient Card */}
      <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-5 text-white">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-12 h-12 rounded-2xl bg-white/15 border border-white/20 flex items-center justify-center font-black text-lg">
            {referral.patient_name.split(' ').map(n => n[0]).join('').slice(0, 2)}
          </div>
          <div>
            <p className="text-[11px] font-semibold opacity-60 uppercase tracking-widest">Patient</p>
            <h3 className="text-lg font-black leading-tight">{referral.patient_name}</h3>
            <p className="text-sm opacity-70">{referral.patient_age} yrs · {referral.patient_gender} · {referral.patient_blood_group}</p>
          </div>
          <span className={cn('ml-auto text-[11px] font-black px-3 py-1 rounded-full capitalize', TYPE_COLORS[referral.type])}>
            {referral.type}
          </span>
        </div>
        <div className="flex items-center gap-2 text-[11px] opacity-60 bg-white/10 rounded-xl px-3 py-2">
          <User className="w-3.5 h-3.5 shrink-0" />
          <span>Referred by <strong className="opacity-90">{referral.doctor_name}</strong> · {referral.doctor_specialization}</span>
        </div>
      </div>

      {/* Diagnosis & Notes */}
      <div className="bg-white rounded-2xl border border-slate-200 p-4 space-y-3 shadow-sm">
        <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
          <Stethoscope className="w-4 h-4 text-slate-400" />
          <p className="text-[12px] font-black text-slate-500 uppercase tracking-wide">Diagnosis</p>
        </div>
        <p className="text-[14px] font-bold text-slate-800 leading-relaxed">{referral.diagnosis}</p>
        {referral.notes && (
          <div className="bg-slate-50 rounded-xl p-3">
            <div className="flex items-center gap-1.5 mb-1.5">
              <FileText className="w-3.5 h-3.5 text-slate-400" />
              <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wide">Doctor Notes</p>
            </div>
            <p className="text-[13px] text-slate-600 leading-relaxed">{referral.notes}</p>
          </div>
        )}
        <div className="bg-amber-50 border border-amber-100 rounded-xl p-3">
          <p className="text-[11px] font-bold text-amber-600 uppercase tracking-wide mb-1">Reason for Referral</p>
          <p className="text-[13px] font-semibold text-amber-800">{referral.reason}</p>
        </div>
      </div>


      {/* Tests */}
      {referral.tests.length > 0 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <FlaskConical className="w-4 h-4 text-teal-500" />
            <p className="text-[12px] font-black text-slate-500 uppercase tracking-wide">Tests Ordered</p>
            <span className="ml-auto bg-teal-100 text-teal-700 text-[10px] font-bold px-2 py-0.5 rounded-full">
              {referral.tests.length} test{referral.tests.length > 1 ? 's' : ''}
            </span>
          </div>
          <div className="space-y-2">
            {referral.tests.map((test, i) => (
              <div key={i} className="flex items-center gap-2.5 bg-teal-50 rounded-xl px-3 py-2.5">
                <TestTube className="w-3.5 h-3.5 text-teal-500 shrink-0" />
                <span className="text-[13px] font-semibold text-teal-700">{test}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Validity */}
      <div className="flex items-center gap-2 bg-slate-100 rounded-xl px-4 py-2.5">
        <Calendar className="w-3.5 h-3.5 text-slate-400 shrink-0" />
        <p className="text-[12px] font-medium text-slate-500">Valid until: <strong className="text-slate-700">{expiresDate}</strong></p>
      </div>

      {/* Action Buttons */}
      <div className="space-y-2.5">
        <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider px-1">Book a Service</p>
        {onBookLab && (
          <button onClick={onBookLab}
            className="w-full flex items-center justify-between bg-teal-500 hover:bg-teal-600 text-white font-bold text-[14px] px-5 py-4 rounded-2xl transition-all active:scale-[0.98] shadow-lg shadow-teal-500/25">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 bg-white/20 rounded-xl flex items-center justify-center">
                <FlaskConical className="w-4 h-4" />
              </div>
              Book Lab Test
            </div>
            <ArrowRight className="w-4 h-4" />
          </button>
        )}
        {onBookHospital && (
          <button onClick={onBookHospital}
            className="w-full flex items-center justify-between bg-blue-500 hover:bg-blue-600 text-white font-bold text-[14px] px-5 py-4 rounded-2xl transition-all active:scale-[0.98] shadow-lg shadow-blue-500/25">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 bg-white/20 rounded-xl flex items-center justify-center">
                <Stethoscope className="w-4 h-4" />
              </div>
              Book Hospital Visit
            </div>
            <ArrowRight className="w-4 h-4" />
          </button>
        )}
        {onBookSpecialist && (
          <button onClick={onBookSpecialist}
            className="w-full flex items-center justify-between bg-violet-500 hover:bg-violet-600 text-white font-bold text-[14px] px-5 py-4 rounded-2xl transition-all active:scale-[0.98] shadow-lg shadow-violet-500/25">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 bg-white/20 rounded-xl flex items-center justify-center">
                <User className="w-4 h-4" />
              </div>
              Book Specialist
            </div>
            <ArrowRight className="w-4 h-4" />
          </button>
        )}
      </div>

    </div>
  );
}
