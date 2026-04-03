import { User, Activity, Clock, FileText, Pill, ShieldAlert } from 'lucide-react';
import type { FullConsultationSummary } from '../../types/consultation';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  data: FullConsultationSummary;
}

export function QRPassportPanel({ data }: Props) {
  const { patient, timeline, prescriptions, vitals, reports } = data;

  return (
    <div className="h-full flex flex-col bg-slate-50 border-r border-slate-200 overflow-y-auto custom-scrollbar">
      {/* Header */}
      <div className="p-4 border-b border-slate-200 bg-white sticky top-0 z-10 flex items-center justify-between">
        <h2 className="text-sm font-black text-slate-800 uppercase tracking-wider flex items-center gap-2">
          <User className="w-4 h-4 text-slate-400" />
          Patient Passport
        </h2>
        <span className="bg-slate-100 text-slate-600 text-[10px] font-bold px-2 py-0.5 rounded-full">
          ID: {patient.id}
        </span>
      </div>

      <div className="p-4 space-y-5">
        
        {/* Basic Info */}
        <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-200">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-2xl bg-indigo-50 border border-indigo-100 text-indigo-700 flex items-center justify-center font-black text-lg">
              {patient.name.split(' ').map(n => n[0]).join('').slice(0, 2)}
            </div>
            <div>
              <h3 className="text-base font-black text-slate-800 leading-tight">{patient.name}</h3>
              <p className="text-xs font-semibold text-slate-500">{patient.age} yrs · {patient.gender} · {patient.blood_group}</p>
            </div>
          </div>

          {(patient.allergies.length > 0 || patient.family_history) && (
            <div className="space-y-2 mt-3 pt-3 border-t border-slate-100">
              {patient.allergies.length > 0 && (
                <div className="flex flex-wrap gap-1.5">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1 mr-1">Allergies:</span>
                  {patient.allergies.map(a => (
                    <span key={a} className="bg-red-50 text-red-600 text-[11px] font-bold px-2 py-0.5 rounded-md flex items-center gap-1 border border-red-100">
                      <ShieldAlert className="w-3 h-3" />
                      {a}
                    </span>
                  ))}
                </div>
              )}
              {patient.family_history && (
                <p className="text-[11px] font-medium text-slate-600 bg-slate-50 p-2 rounded-lg border border-slate-100">
                  <span className="font-bold text-slate-700">Family Hx:</span> {patient.family_history}
                </p>
              )}
            </div>
          )}
        </div>

        {/* Vitals */}
        <div>
          <h4 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 flex items-center gap-1.5 px-1">
            <Activity className="w-3.5 h-3.5" /> Recent Vitals
          </h4>
          <div className="grid grid-cols-2 gap-2">
            {vitals[0] && (
              <>
                <div className={cn("p-2.5 rounded-xl border", vitals[0].warnings?.includes('bp') ? 'bg-amber-50 border-amber-200' : 'bg-white border-slate-200')}>
                  <p className="text-[10px] font-bold text-slate-400 uppercase">Blood Pressure</p>
                  <p className={cn("text-sm font-black", vitals[0].warnings?.includes('bp') ? 'text-amber-700' : 'text-slate-700')}>{vitals[0].bp}</p>
                </div>
                <div className="p-2.5 rounded-xl bg-white border border-slate-200">
                  <p className="text-[10px] font-bold text-slate-400 uppercase">Heart Rate</p>
                  <p className="text-sm font-black text-slate-700">{vitals[0].hr}</p>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Timeline */}
        <div>
          <h4 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3 flex items-center gap-1.5 px-1">
            <Clock className="w-3.5 h-3.5" /> Medical Timeline
          </h4>
          <div className="space-y-3 relative before:absolute before:inset-0 before:ml-[11px] before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-slate-200 before:to-transparent">
            {timeline.slice(0, 3).map((event, i) => (
              <div key={i} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                <div className="flex items-center justify-center w-6 h-6 rounded-full border-2 border-white bg-indigo-100 text-indigo-500 shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 absolute left-0 md:left-1/2 -translate-x-[11px]">
                  <div className="w-2 h-2 bg-indigo-500 rounded-full"></div>
                </div>
                <div className="w-[calc(100%-2rem)] md:w-[calc(50%-1.5rem)] bg-white p-3 rounded-xl border border-slate-200 shadow-sm ml-8 md:ml-0">
                  <div className="flex justify-between items-start mb-1">
                    <p className="text-[10px] font-bold text-indigo-500">{new Date(event.date).toLocaleDateString(undefined, { month: 'short', year: 'numeric' })}</p>
                    <span className="text-[9px] font-black uppercase text-slate-400 bg-slate-100 px-1.5 rounded">{event.type}</span>
                  </div>
                  <h5 className="text-[12px] font-black text-slate-800 leading-tight">{event.title}</h5>
                  <p className="text-[11px] font-medium text-slate-500 mt-1">{event.diagnosis}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Prescriptions */}
        <div>
          <h4 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 flex items-center gap-1.5 px-1">
            <Pill className="w-3.5 h-3.5" /> Last Prescriptions
          </h4>
          <div className="space-y-2">
            {prescriptions.map((rx, i) => (
              <div key={i} className="bg-white p-2.5 rounded-xl border border-slate-200 flex justify-between items-center shadow-sm">
                <div>
                  <p className="text-[12px] font-bold text-slate-800">{rx.name}</p>
                  <p className="text-[10px] font-semibold text-slate-500">{rx.dosage}</p>
                </div>
                <span className="text-[10px] font-bold text-indigo-600 bg-indigo-50 px-2 py-1 rounded-md">{rx.duration}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Uploaded Reports */}
        <div>
          <h4 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 flex items-center gap-1.5 px-1">
            <FileText className="w-3.5 h-3.5" /> Recent Reports
          </h4>
          <div className="grid grid-cols-1 gap-2">
            {reports.map((r, i) => (
              <button key={i} className="flex items-center gap-3 bg-white p-2.5 rounded-xl border border-slate-200 hover:border-indigo-300 transition-colors shadow-sm text-left">
                <div className="w-8 h-8 rounded-lg bg-red-50 text-red-500 flex items-center justify-center shrink-0">
                  <FileText className="w-4 h-4" />
                </div>
                <div>
                  <p className="text-[12px] font-bold text-slate-800 leading-tight">{r.name}</p>
                  <p className="text-[10px] font-semibold text-slate-500">{new Date(r.date).toLocaleDateString()}</p>
                </div>
              </button>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}
