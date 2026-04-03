import { Calendar, Pill, Activity, History, Download } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  action?: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  payload?: any;
}

export const AIResponseCard = ({ action, payload }: Props) => {
  if (!action || !payload) return null;

  if (action === 'show_appointments') {
    return (
      <div className="mt-3 bg-white p-3 rounded-xl border border-indigo-100 shadow-sm">
        <div className="flex items-center justify-between mb-3 px-1">
          <span className="text-sm font-bold text-slate-800">Today's Schedule</span>
          <button onClick={() => window.print()} className="flex items-center gap-1.5 text-xs bg-indigo-50 text-indigo-700 hover:bg-indigo-100 px-3 py-1.5 rounded-lg transition-colors font-semibold">
            <Download className="w-3.5 h-3.5" /> Save PDF
          </button>
        </div>
        <div className="space-y-2">
          {payload.map((apt: Record<string, unknown>) => (
            <div key={apt.id as string} className="bg-slate-50 border text-left border-slate-100 rounded-lg p-3 flex items-center gap-3 hover:shadow-sm transition-shadow">
              <div className="bg-white p-2 rounded-md text-indigo-600 shadow-sm border border-slate-100">
                <Calendar className="w-4 h-4" />
              </div>
              <div className="flex-1">
                <p className="font-bold text-slate-800 text-sm">{apt.patient as string}</p>
                <p className="text-xs text-slate-500 font-medium">{apt.time as string}</p>
              </div>
              <span className={cn("text-[11px] font-bold px-2 py-1 rounded-md", apt.status === 'Waiting' ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700', apt.status === 'In Progress' ? 'bg-blue-100 text-blue-700' : '')}>
                {apt.status as string}
              </span>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (action === 'show_critical') {
    return (
      <div className="mt-3 space-y-2">
        {payload.map((pt: Record<string, unknown>) => (
          <div key={pt.id as string} className="bg-white border text-left border-red-200 rounded-xl p-3 flex items-center gap-3 shadow-sm">
            <div className="bg-red-50 p-2 rounded-lg text-red-600 animate-pulse">
              <Activity className="w-5 h-5" />
            </div>
            <div className="flex-1">
              <p className="font-bold text-slate-800 text-sm">{pt.patient as string}</p>
              <p className="text-xs text-red-500 font-medium">{pt.condition as string}</p>
            </div>
            <button className="bg-red-600 text-white text-xs font-bold px-3 py-1.5 rounded-lg hover:bg-red-700">
              View SOS
            </button>
          </div>
        ))}
      </div>
    );
  }

  if (action === 'generate_prescription') {
    return (
      <div className="mt-3 bg-white border border-slate-200 rounded-xl p-4 shadow-sm text-left">
        <div className="flex items-center gap-2 mb-3 pb-3 border-b border-slate-100">
          <Pill className="w-5 h-5 text-indigo-500" />
          <h4 className="font-bold text-slate-800 text-sm">Draft Prescription: {payload.diagnosis}</h4>
        </div>
        <ul className="space-y-3">
          {payload.medicines.map((med: Record<string, unknown>, i: number) => (
            <li key={i} className="flex justify-between items-start">
              <div>
                <p className="text-sm font-bold text-slate-800">{med.name as string}</p>
                <p className="text-xs text-slate-500">{med.dosage as string} â€¢ {med.duration as string}</p>
              </div>
              <span className="bg-indigo-50 text-indigo-700 text-[10px] uppercase font-bold py-0.5 px-2 rounded">
                {med.frequency as string}
              </span>
            </li>
          ))}
        </ul>
        <div className="mt-4 flex gap-2">
          <button className="flex-1 bg-brand-blue text-white text-xs font-bold py-2 rounded-lg hover:bg-blue-600 transition-colors" onClick={() => window.print()}>Download PDF</button>
          <button className="flex-1 bg-slate-100 text-slate-700 text-xs font-bold py-2 rounded-lg hover:bg-slate-200 transition-colors">Edit Prescription</button>
        </div>
      </div>
    );
  }

  if (action === 'show_history') {
    return (
      <div className="mt-3 bg-white border border-slate-200 rounded-xl p-4 shadow-sm text-left">
        <h4 className="font-bold text-slate-800 text-sm mb-3 flex items-center gap-2">
           <History className="w-4 h-4 text-indigo-500" /> {payload.patient as string}'s History
        </h4>
        <div className="space-y-3 relative before:absolute before:inset-0 before:ml-1.5 before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-slate-200 before:to-transparent">
          {payload.history.map((item: Record<string, unknown>, i: number) => (
             <div key={i} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
               <div className="flex items-center justify-center w-3 h-3 rounded-full border-2 border-white bg-slate-300 group-[.is-active]:bg-indigo-500 text-slate-500 group-[.is-active]:text-white shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2"></div>
               <div className="w-[calc(100%-2rem)] md:w-[calc(50%-1.5rem)] p-2 rounded-lg border border-slate-100 bg-slate-50 shadow-sm text-sm">
                  <div className="flex items-center justify-between mb-1">
                     <time className="text-[10px] font-bold text-indigo-500">{item.date as string}</time>
                  </div>
                  <div className="text-slate-700 text-xs font-medium">{item.event as string}</div>
               </div>
             </div>
          ))}
        </div>
      </div>
    );
  }

  return null;
};