import { MapPin, Clock, Activity, Check, X, Heart } from 'lucide-react';
import type { Emergency } from '../../types/emergency';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  emergency: Emergency;
  onAccept: (id: string) => void;
  onReject: (id: string) => void;
}

export const EmergencyCard = ({ emergency, onAccept, onReject }: Props) => {
  const isCritical = emergency.severity === 'Critical';

  return (
    <div className={cn(
      "relative bg-white rounded-2xl p-4 border transition-all animate-in slide-in-from-left-4 duration-300 shadow-sm hover:shadow-md",
      isCritical ? "border-red-300" : "border-slate-200"
    )}>
      {isCritical && (
        <div className="absolute top-0 right-0 p-2">
          <span className="flex h-3 w-3 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
          </span>
        </div>
      )}
      
      <div className="flex justify-between items-start mb-3">
        <div>
          <h3 className="text-slate-800 font-bold text-lg">{emergency.patientName}</h3>
          <p className="text-slate-500 text-xs">{emergency.gender ? `${emergency.age}y, ${emergency.gender}` : 'Unknown Info'}</p>
        </div>
        <div className={cn("px-2 py-1 mr-2 rounded text-[10px] font-bold uppercase", isCritical ? "bg-red-50 text-red-600 border-red-100 border" : "bg-orange-50 text-orange-600 border-orange-100 border")}>
          {emergency.type}
        </div>
      </div>

      <div className="space-y-2 mb-4">
        <div className="flex items-center text-slate-600 text-sm gap-2">        
          <MapPin className="w-4 h-4 text-slate-400" />
          <span className="truncate">{emergency.location} ({emergency.distance})</span>
        </div>
        <div className="flex items-center text-slate-600 text-sm gap-2">        
          <Clock className="w-4 h-4 text-slate-400" />
          <span className={cn(isCritical && "text-red-500 font-bold animate-pulse")}>{emergency.timeSinceAlert} elapsed</span>
        </div>
        {emergency.vitals && (
          <div className="flex items-center gap-3 mt-2 pt-2 border-t border-slate-100">
            <div className="flex items-center gap-1 text-xs text-slate-600"><Heart className="w-3 h-3 text-red-500"/> {emergency.vitals.heartRate}</div>        
            <div className="flex items-center gap-1 text-xs text-slate-600"><Activity className="w-3 h-3 text-cyan-500"/> {emergency.vitals.oxygen}%</div>      
            <div className="flex items-center gap-1 text-xs text-slate-600 px-1 border-l border-slate-200 ml-1 pl-2">BP: {emergency.vitals.bloodPressure}</div> 
          </div>
        )}
      </div>

      <div className="flex gap-2 w-full">
         <button onClick={() => onAccept(emergency.id)} className="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 rounded-xl text-sm font-bold flex justify-center items-center gap-2 transition-colors shadow-sm">
           <Check className="w-4 h-4" /> Accept
         </button>
         <button onClick={() => onReject(emergency.id)} className="flex-1 bg-white hover:bg-slate-50 text-slate-700 py-2 rounded-xl text-sm font-bold flex justify-center items-center gap-2 transition-colors border border-slate-200 shadow-sm">   
           <X className="w-4 h-4" /> Reject
         </button>
      </div>
    </div>
  );
};