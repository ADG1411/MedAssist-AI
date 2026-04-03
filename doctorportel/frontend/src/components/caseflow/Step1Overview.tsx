import { Shield, Activity, FileText, User, Phone, Mail, AlertTriangle } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState } from '../../types/caseflow';

const fmtCost = (min: number, max: number) =>
  `₹${(min / 1000).toFixed(0)}k – ${(max / 1000).toFixed(0)}k`;

const scoreColor = (s: number) =>
  s >= 76 ? { text: 'text-rose-400', color: '#f43f5e', label: 'High' }
  : s >= 41 ? { text: 'text-amber-400', color: '#f59e0b', label: 'Medium' }
  : { text: 'text-emerald-400', color: '#10b981', label: 'Low' };

/* ── AI Risk Arc Gauge ─────────────────────────────────────────────────────── */
const RiskGauge = ({ score }: { score: number }) => {
  const sc  = scoreColor(score);
  const r   = 50;
  const arc = Math.PI * r;           // semicircle circumference
  const offset = arc * (1 - score / 100);

  return (
    <div className="bg-slate-900 rounded-2xl p-5 flex flex-col h-full min-h-[220px]">
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <span className="text-yellow-400 text-base">⚡</span>
          <span className="text-white font-black text-[14px]">AI Risk</span>
        </div>
        <span className="text-slate-500 text-[11px] bg-slate-800 px-2 py-0.5 rounded">v2.5</span>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center">
        <div className="relative w-36 h-[78px]">
          <svg viewBox="0 0 120 66" className="w-full h-full overflow-visible">
            <path d="M 10 62 A 50 50 0 0 1 110 62"
              fill="none" stroke="#1e293b" strokeWidth="13" strokeLinecap="round" />
            <path d="M 10 62 A 50 50 0 0 1 110 62"
              fill="none" stroke={sc.color} strokeWidth="13" strokeLinecap="round"
              strokeDasharray={arc} strokeDashoffset={offset}
              style={{ transition: 'stroke-dashoffset 0.8s ease' }}
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-end pb-0">
            <span className="font-black text-xl leading-tight" style={{ color: sc.color }}>{sc.label}</span>
            <span className="text-slate-500 text-[9px] font-bold uppercase tracking-widest">Risk Level</span>
          </div>
        </div>
        <p className="font-black text-2xl mt-2" style={{ color: sc.color }}>{score}<span className="text-slate-500 text-[14px] font-bold">/100</span></p>
      </div>
    </div>
  );
};

/* ── Health ID Card ─────────────────────────────────────────────────────────── */
const HealthIDCard = ({ patient }: { patient: CaseFlowState['patient'] }) => (
  <div className="relative bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 rounded-2xl p-5 overflow-hidden col-span-full">
    {/* Shield watermark */}
    <Shield className="absolute right-10 top-1/2 -translate-y-1/2 w-28 h-28 text-white/5 pointer-events-none" />

    {/* Header */}
    <div className="flex items-center justify-between mb-4">
      <div className="flex items-center gap-2.5">
        <div className="w-9 h-9 bg-teal-500 rounded-xl flex items-center justify-center shadow-lg shadow-teal-500/30">
          <Activity className="w-5 h-5 text-white" />
        </div>
        <div>
          <p className="text-white font-black text-[14px] leading-tight">SanjivaniAI</p>
          <p className="text-slate-500 text-[9px] font-bold uppercase tracking-widest">Universal Health ID</p>
        </div>
      </div>
      <div className="flex items-center gap-1.5 bg-teal-500/15 border border-teal-500/30 px-2.5 py-1 rounded-full">
        <span className="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse" />
        <span className="text-teal-400 text-[11px] font-black">ACTIVE</span>
      </div>
    </div>

    {/* Name */}
    <p className="text-slate-500 text-[9px] font-bold uppercase tracking-widest mb-1">Patient Name</p>
    <h2 className="text-white font-black text-3xl md:text-4xl mb-5 tracking-tight">{patient.name}</h2>

    {/* Data row */}
    <div className="flex items-end justify-between flex-wrap gap-4">
      <div className="flex gap-6 flex-wrap">
        {[
          { label: 'ID Number',   value: patient.idNumber  },
          { label: 'Birth Date',  value: patient.birthDate },
          { label: 'Blood',       value: patient.bloodGroup },
        ].map(({ label, value }) => (
          <div key={label}>
            <p className="text-slate-600 text-[9px] font-bold uppercase tracking-widest mb-1">{label}</p>
            <p className="text-white font-black text-[13px]">{value}</p>
          </div>
        ))}
      </div>

      {/* Grid QR mock */}
      <div className="flex items-center gap-2 shrink-0">
        <div className="w-8 h-8 rounded-sm bg-amber-400/90" />
        <div className="w-8 h-8 rounded-sm grid grid-cols-3 gap-0.5 p-1 bg-white/5 border border-white/10">
          {[0,1,2,3,4,5,6,7,8].map(i => (
            <div key={i} className={cn('rounded-[1px]', [0,2,4,6,8].includes(i) ? 'bg-white/70' : 'bg-transparent')} />
          ))}
        </div>
      </div>
    </div>

    {/* Footer */}
    <div className="flex items-center justify-between mt-4 pt-3 border-t border-white/8">
      <p className="text-slate-600 text-[9px] font-semibold">© 2026 SANJIVANI GROUP</p>
      <p className="text-slate-600 text-[9px] font-semibold">ISS: 10/25  EXP: 10/28</p>
    </div>
  </div>
);

/* ── Step 1 – Patient Overview ──────────────────────────────────────────────── */
export const Step1Overview = ({ data }: { data: CaseFlowState }) => {
  const { patient } = data;
  const sc = scoreColor(patient.aiScore);

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* Health ID Card */}
      <HealthIDCard patient={patient} />

      {/* Specs + Risk */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">

        {/* Request Specifications */}
        <div className="md:col-span-3 bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-7 h-7 bg-blue-50 rounded-lg flex items-center justify-center">
              <FileText className="w-4 h-4 text-blue-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Request Specifications</span>
          </div>

          <div className="space-y-3">
            <div>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">Surgery Type</p>
              <p className="text-[14px] font-bold text-slate-800">{patient.procedure}</p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { label: 'Urgency Level',      value: patient.urgency,                  cls: '' },
                { label: 'Source',             value: patient.source,                   cls: '' },
                { label: 'Est. Cost',          value: fmtCost(patient.costMin, patient.costMax), cls: 'text-teal-600 font-black' },
                { label: 'AI Priority Score',  value: `${patient.aiScore}/100`,         cls: sc.text + ' font-black' },
              ].map(({ label, value, cls }) => (
                <div key={label}>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">{label}</p>
                  <p className={cn('text-[13px] font-semibold text-slate-700', cls)}>{value}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Risk Gauge */}
        <div className="md:col-span-2">
          <RiskGauge score={patient.aiScore} />
        </div>
      </div>

      {/* Patient Contact + History */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">

        {/* Contact */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-7 h-7 bg-indigo-50 rounded-lg flex items-center justify-center">
              <User className="w-4 h-4 text-indigo-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Patient Contact</span>
          </div>
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <Phone className="w-4 h-4 text-slate-400 shrink-0" />
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Phone</p>
                <p className="text-[13px] font-bold text-slate-700">{patient.phone}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Mail className="w-4 h-4 text-slate-400 shrink-0" />
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Email</p>
                <p className="text-[13px] font-bold text-slate-700 truncate">{patient.email}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Activity className="w-4 h-4 text-slate-400 shrink-0" />
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Age / Gender</p>
                <p className="text-[13px] font-bold text-slate-700">{patient.age} yrs · {patient.gender}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Medical history + allergies */}
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-7 h-7 bg-rose-50 rounded-lg flex items-center justify-center">
              <AlertTriangle className="w-4 h-4 text-rose-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Medical History</span>
          </div>
          <div className="space-y-2 mb-3">
            {patient.medicalHistory.map(h => (
              <div key={h} className="flex items-center gap-2 text-[12px]">
                <span className="w-1.5 h-1.5 rounded-full bg-slate-300 shrink-0" />
                <span className="text-slate-600 font-medium">{h}</span>
              </div>
            ))}
          </div>
          {patient.allergies.length > 0 && (
            <div>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5">Allergies</p>
              <div className="flex flex-wrap gap-1.5">
                {patient.allergies.map(a => (
                  <span key={a} className="text-[11px] font-bold text-rose-600 bg-rose-50 border border-rose-100 px-2 py-0.5 rounded-lg">
                    {a}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
