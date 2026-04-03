import { Zap, Stethoscope, Droplets, Link2, CalendarPlus } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

export function QuickActions({ patientId }: { patientId: string }) {
  const actions = [
    { icon: Stethoscope, label: 'Write Prescription', color: 'bg-indigo-500 text-white shadow-indigo-500/20' },
    { icon: Droplets,    label: 'Order Lab Test',     color: 'bg-teal-500 text-white shadow-teal-500/20' },
    { icon: Link2,       label: 'Generate Referral',  color: 'bg-violet-500 text-white shadow-violet-500/20' },
    { icon: CalendarPlus,label: 'Schedule Follow-up', color: 'bg-slate-800 text-white shadow-slate-800/20' }
  ];

  return (
    <div className="bg-white border-t border-slate-200 p-4 shrink-0">
      <div className="flex items-center gap-2 mb-3">
        <Zap className="w-4 h-4 text-amber-500" />
        <h4 className="text-[11px] font-black tracking-widest uppercase text-slate-500">Quick Actions</h4>
      </div>
      
      <div className="grid grid-cols-2 gap-2">
        {actions.map((action, i) => {
          const Icon = action.icon;
          return (
            <button key={i} onClick={() => alert(`${action.label} placeholder for ${patientId}`)}
              className={cn("flex flex-col items-center justify-center gap-2 p-3 rounded-xl transition-all hover:-translate-y-0.5 shadow-lg active:scale-95", action.color)}>
              <Icon className="w-5 h-5 mb-1" />
              <span className="text-[11px] font-bold text-center leading-tight">{action.label}</span>
            </button>
          )
        })}
      </div>
    </div>
  );
}
