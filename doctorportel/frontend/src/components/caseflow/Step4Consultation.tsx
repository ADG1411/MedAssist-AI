import { useState } from 'react';
import { Mic, MicOff, VideoOff, PhoneOff, Upload, Wifi, Building2, Play, CheckCircle2, Clock, Users } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState } from '../../types/caseflow';

/* ── Online: Video Call UI ──────────────────────────────────────────────────── */
const OnlineConsultation = ({ patient }: { patient: CaseFlowState['patient'] }) => {
  const [muted,  setMuted]  = useState(false);
  const [camOff, setCamOff] = useState(false);
  const [ended,  setEnded]  = useState(false);
  const timer = '05:24';

  if (ended) {
    return (
      <div className="flex flex-col items-center justify-center py-20 gap-4">
        <div className="w-16 h-16 bg-emerald-100 rounded-2xl flex items-center justify-center">
          <CheckCircle2 className="w-8 h-8 text-emerald-500" />
        </div>
        <p className="font-black text-slate-800 text-xl">Consultation Ended</p>
        <p className="text-slate-500 font-medium text-[13px]">Session with {patient.name} has been saved.</p>
        <button onClick={() => setEnded(false)} className="px-5 py-2.5 bg-slate-800 text-white text-[13px] font-bold rounded-xl hover:bg-slate-700 transition-colors">
          Reconnect
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">
      {/* Video area */}
      <div className="relative bg-slate-900 rounded-2xl overflow-hidden aspect-video md:aspect-[16/7] shadow-xl">
        {/* Patient feed */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-24 h-24 rounded-full bg-teal-500 flex items-center justify-center shadow-2xl">
            <span className="text-white font-black text-3xl">
              {patient.name.split(' ').map(n => n[0]).join('')}
            </span>
          </div>
        </div>

        {/* LIVE badge */}
        <div className="absolute top-4 left-4 flex items-center gap-1.5 bg-black/60 backdrop-blur-md text-white text-[11px] font-bold px-3 py-1.5 rounded-lg border border-white/10">
          <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse" /> LIVE
        </div>

        {/* Wifi status */}
        <div className="absolute top-4 right-4 flex items-center gap-1.5 bg-black/60 backdrop-blur-md text-white text-[11px] font-bold px-3 py-1.5 rounded-lg border border-white/10">
          <Wifi className="w-3.5 h-3.5 text-emerald-400" /> HD · 24ms
        </div>

        {/* Timer */}
        <div className="absolute bottom-16 left-1/2 -translate-x-1/2 bg-black/50 backdrop-blur-md text-white text-[14px] font-black px-4 py-1.5 rounded-xl border border-white/10">
          <Clock className="w-3.5 h-3.5 inline mr-1.5 text-emerald-400" />
          {timer}
        </div>

        {/* Self view PIP */}
        <div className="absolute bottom-4 right-4 w-20 h-28 bg-slate-700 rounded-xl ring-2 ring-white/20 overflow-hidden shadow-xl flex items-center justify-center">
          <span className="text-white font-black text-sm">You</span>
        </div>

        {/* Controls overlay */}
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-3">
          <button onClick={() => setMuted(m => !m)}
            className={cn('p-3 rounded-full backdrop-blur-md border transition-all',
              muted ? 'bg-red-500 border-red-400 text-white' : 'bg-white/10 border-white/15 text-white hover:bg-white/20')}>
            {muted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
          </button>
          <button onClick={() => setCamOff(c => !c)}
            className={cn('p-3 rounded-full backdrop-blur-md border transition-all',
              camOff ? 'bg-red-500 border-red-400 text-white' : 'bg-white/10 border-white/15 text-white hover:bg-white/20')}>
            <VideoOff className="w-5 h-5" />
          </button>
          <button
            className="p-3 bg-white/10 hover:bg-white/20 backdrop-blur-md rounded-full text-white border border-white/15 transition-all">
            <Upload className="w-5 h-5" />
          </button>
          <button onClick={() => setEnded(true)}
            className="p-3 bg-red-500 hover:bg-red-600 rounded-full text-white shadow-lg shadow-red-500/30 transition-all">
            <PhoneOff className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: 'Patient',    value: patient.name,    icon: Users,      color: 'text-blue-500',    bg: 'bg-blue-50'    },
          { label: 'Duration',   value: timer,           icon: Clock,      color: 'text-teal-500',    bg: 'bg-teal-50'    },
          { label: 'Connection', value: 'Stable · HD',   icon: Wifi,       color: 'text-emerald-500', bg: 'bg-emerald-50' },
        ].map(({ label, value, icon: Icon, color, bg }) => (
          <div key={label} className="bg-white rounded-2xl p-4 border border-slate-200 shadow-sm flex items-center gap-3">
            <div className={cn('w-9 h-9 rounded-xl flex items-center justify-center shrink-0', bg)}>
              <Icon className={cn('w-4 h-4', color)} />
            </div>
            <div className="min-w-0">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{label}</p>
              <p className="text-[13px] font-black text-slate-800 truncate">{value}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

/* ── Offline: OPD Consultation ─────────────────────────────────────────────── */
const OfflineConsultation = ({ patient }: { patient: CaseFlowState['patient'] }) => {
  const [started, setStarted] = useState(false);

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">
      {/* OPD Status Card */}
      <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div className="flex items-center gap-4 mb-6">
          <div className="w-14 h-14 bg-indigo-100 rounded-2xl flex items-center justify-center shadow-sm">
            <Building2 className="w-7 h-7 text-indigo-500" />
          </div>
          <div>
            <p className="font-black text-slate-800 text-lg">Offline Consultation</p>
            <p className="text-[13px] text-slate-500 font-medium">Hospital / OPD Visit</p>
          </div>
          <div className="ml-auto">
            <div className={cn('flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[12px] font-bold border',
              started ? 'bg-emerald-50 text-emerald-600 border-emerald-200' : 'bg-amber-50 text-amber-600 border-amber-200')}>
              <span className={cn('w-2 h-2 rounded-full', started ? 'bg-emerald-400 animate-pulse' : 'bg-amber-400')} />
              {started ? 'In Progress' : 'Waiting'}
            </div>
          </div>
        </div>

        {/* Patient info */}
        <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-2xl mb-6">
          <div className="w-12 h-12 rounded-full flex items-center justify-center text-white font-black text-lg shadow-md"
            style={{ backgroundColor: patient.avatarColor }}>
            {patient.name.split(' ').map(n => n[0]).join('')}
          </div>
          <div>
            <p className="font-black text-slate-800 text-[15px]">{patient.name}</p>
            <p className="text-[12px] text-slate-500 font-medium">{patient.age} yrs · {patient.gender} · {patient.bloodGroup}</p>
          </div>
          <div className="ml-auto text-right">
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Procedure</p>
            <p className="text-[12px] font-bold text-slate-700">{patient.procedure}</p>
          </div>
        </div>

        {/* OPD steps */}
        <div className="space-y-3 mb-6">
          {[
            { step: 1, label: 'Patient registered at reception', done: true  },
            { step: 2, label: 'Vitals recorded by nursing staff',  done: started },
            { step: 3, label: 'Patient in OPD waiting area',       done: started },
            { step: 4, label: 'Doctor consultation started',       done: false  },
          ].map(({ step, label, done }) => (
            <div key={step} className="flex items-center gap-3">
              <div className={cn('w-7 h-7 rounded-full flex items-center justify-center text-[11px] font-black shrink-0 border-2',
                done ? 'bg-emerald-500 border-emerald-500 text-white' : 'bg-white border-slate-200 text-slate-400')}>
                {done ? <CheckCircle2 className="w-3.5 h-3.5" /> : step}
              </div>
              <p className={cn('text-[13px] font-medium', done ? 'text-slate-700' : 'text-slate-400')}>{label}</p>
            </div>
          ))}
        </div>

        {!started ? (
          <button
            onClick={() => setStarted(true)}
            className="w-full flex items-center justify-center gap-2 bg-slate-900 hover:bg-slate-800 text-white font-black py-3.5 rounded-2xl transition-all active:scale-[0.99] shadow-lg text-[14px]"
          >
            <Play className="w-5 h-5" /> Start Consultation
          </button>
        ) : (
          <div className="flex items-center gap-3">
            <div className="flex-1 flex items-center gap-2 bg-emerald-50 border border-emerald-200 px-4 py-3 rounded-xl">
              <span className="w-2.5 h-2.5 bg-emerald-400 rounded-full animate-pulse" />
              <span className="text-emerald-700 font-bold text-[13px]">Consultation in progress</span>
            </div>
            <button
              onClick={() => setStarted(false)}
              className="px-4 py-3 bg-red-50 border border-red-200 text-red-600 text-[13px] font-bold rounded-xl hover:bg-red-100 transition-colors"
            >
              End
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

/* ── Step 4 – Consultation Mode ─────────────────────────────────────────────── */
export const Step4Consultation = ({ data }: { data: CaseFlowState }) => {
  const isOnline = data.visit.visitType === 'online';
  return isOnline
    ? <OnlineConsultation patient={data.patient} />
    : <OfflineConsultation patient={data.patient} />;
};
