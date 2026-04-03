import React from 'react';
import { motion } from 'framer-motion';
import type { Patient } from '../types/patient';
import { Star, Activity, CalendarClock, DollarSign, Bell } from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

interface PatientCardProps {
  patient: Patient;
  onClick: (patient: Patient) => void;
  layoutId?: string;
}

const AVATAR_PALETTES = [
  'bg-red-400',    'bg-orange-400', 'bg-emerald-400', 'bg-slate-400',
  'bg-blue-400',   'bg-purple-400', 'bg-pink-400',    'bg-teal-400',
  'bg-amber-400',  'bg-cyan-400',   'bg-violet-400',  'bg-rose-400',
];

const avatarColor = (name: string) => {
  const hash = name.split('').reduce((a, c) => a + c.charCodeAt(0), 0);
  return AVATAR_PALETTES[hash % AVATAR_PALETTES.length];
};

const initials = (name: string) =>
  name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

export const PatientCard: React.FC<PatientCardProps> = ({ patient, onClick, layoutId }) => {
  const isCritical = patient.status === 'Critical';
  const isRecovered = patient.status === 'Recovered';
  const avatarBg = avatarColor(patient.name);
  const ini = initials(patient.name);

  return (
    <motion.div
      layoutId={layoutId}
      onClick={() => onClick(patient)}
      whileHover={{ y: -4, boxShadow: '0 20px 40px rgba(0,0,0,0.10)' }}
      transition={{ type: 'spring', bounce: 0.3, duration: 0.4 }}
      className="bg-white rounded-3xl p-5 shadow-sm border border-slate-200/70 cursor-pointer group flex flex-col h-full relative overflow-hidden"
    >
      {/* Top Section */}
      <div className="flex justify-between items-start mb-5">
        <div className="flex items-center gap-4">
          <div className="relative shrink-0">
            <div className={cn(
              'w-14 h-14 rounded-2xl flex items-center justify-center font-black text-white text-lg shadow-sm select-none',
              avatarBg
            )}>
              {ini}
            </div>
            <div className={cn(
              'absolute -bottom-1.5 -right-1.5 w-4 h-4 rounded-full border-2 border-white',
              isCritical ? 'bg-red-500' : isRecovered ? 'bg-slate-400' : 'bg-emerald-500'
            )} />
          </div>
          <div>
            <h3 className="font-bold text-slate-800 text-lg group-hover:text-brand-blue transition-colors leading-tight">{patient.name}</h3>
            <p className="text-sm text-slate-500 font-medium mt-0.5">{patient.age} yrs • {patient.gender}</p>
          </div>
        </div>
        <button 
          className="text-slate-300 hover:text-yellow-400 transition-colors p-2 rounded-xl hover:bg-yellow-50/50"
          onClick={(e) => { e.stopPropagation(); /* toggle fav logic */ }}
        >
          <Star className={cn("w-5 h-5", patient.isFavorite && "fill-yellow-400 text-yellow-400")} />
        </button>
      </div>

      {/* Tags */}
      <div className="flex flex-wrap gap-2 mb-5">
        <span className={cn(
          "px-3 py-1.5 rounded-xl text-xs font-semibold tracking-wide",
          isCritical ? "bg-red-100 text-red-700" :
          isRecovered ? "bg-slate-100 text-slate-600" : "bg-emerald-100 text-emerald-700"
        )}>
          {patient.status}
        </span>
        {patient.tags.map(tag => (
          <span key={tag} className="px-3 py-1.5 rounded-xl text-xs font-semibold tracking-wide bg-brand-blue/10 text-brand-blue">
            {tag}
          </span>
        ))}
      </div>

      {/* Info Rows */}
      <div className="space-y-2.5 mb-5 flex-1 rounded-2xl">
        <div className="flex items-center text-sm">
           <div className="w-7 h-7 rounded-lg bg-white shadow-sm flex items-center justify-center mr-3 shrink-0">
             <Activity className="w-4 h-4 text-slate-400" />
           </div>
           <span className="text-slate-700 font-medium truncate">{patient.lastDiagnosis}</span>
        </div>
        <div className="flex items-center text-sm">
           <div className="w-7 h-7 rounded-lg bg-white shadow-sm flex items-center justify-center mr-3 shrink-0">
             <CalendarClock className="w-4 h-4 text-slate-400" />
           </div>
           <span className="text-slate-600 font-medium">Last visit: {patient.lastVisit}</span>
        </div>
        <div className="flex items-center text-sm">
           <div className="w-7 h-7 rounded-lg bg-white shadow-sm flex items-center justify-center mr-3 shrink-0">
             <DollarSign className="w-4 h-4 text-slate-400" />
           </div>
           <span className="text-slate-600 font-medium">Fees: ${patient.totalFees}</span>
        </div>
      </div>

      {/* Bottom Action Footer & Risk Bar */}
      <div className="mt-auto pt-2">
        <div className="flex items-center justify-between mb-2">
           <div className="flex-1 mr-4 bg-slate-50 rounded-xl p-3 shadow-inner border border-slate-100/50">
             <div className="flex justify-between text-xs font-bold text-slate-500 mb-2 items-center">
                <span className="flex items-center gap-1.5"><Activity className="w-3.5 h-3.5" /> AI Health Score</span>
                <span className={cn(
                  "px-2 py-0.5 rounded-md text-[11px]",
                  patient.riskScore > 75 ? "bg-red-100 text-red-600" : 
                  patient.riskScore > 40 ? "bg-amber-100 text-amber-600" : "bg-emerald-100 text-emerald-600"
                )}>{patient.riskScore}/100</span>
             </div>
             <div className="w-full bg-slate-200/60 rounded-full h-2 overflow-hidden shadow-inner">
                <div 
                  className={cn("h-full rounded-full transition-all duration-1000 ease-out", 
                    patient.riskScore > 75 ? "bg-gradient-to-r from-red-400 to-red-600" : 
                    patient.riskScore > 40 ? "bg-gradient-to-r from-amber-400 to-amber-500" : "bg-gradient-to-r from-emerald-400 to-emerald-500"
                  )} 
                  style={{ width: `${patient.riskScore}%` }} 
                />
             </div>
           </div>
           
           {patient.nextFollowUp && (
             <div className="relative group cursor-help text-brand-blue bg-blue-50/80 hover:bg-brand-blue hover:text-white transition-colors p-3 rounded-2xl shadow-sm">
               <Bell className="w-5 h-5" />
               <span className="absolute bottom-full right-0 mb-3 w-max px-3 py-2 bg-slate-800 text-white text-xs font-medium rounded-lg shadow-xl opacity-0 group-hover:opacity-100 pointer-events-none transition-all translate-y-2 group-hover:translate-y-0">
                 Follow up: {patient.nextFollowUp}
               </span>
             </div>
           )}
        </div>

        {/* Hover Actions (Visible on larger screens mostly or explicit buttons) */}
        <div className="flex gap-2 pt-3 border-t border-slate-100">
           <button 
             className="flex-1 bg-slate-50 hover:bg-slate-100 text-slate-700 text-xs font-bold py-2 rounded-xl transition-colors"
             onClick={(e) => { e.stopPropagation(); onClick(patient); }}
           >
             View Details
           </button>
           <button 
             className="flex-1 bg-brand-light hover:bg-blue-100 text-brand-blue text-xs font-bold py-2 rounded-xl transition-colors"
             onClick={(e) => { e.stopPropagation(); /* Action */ }}
           >
             Consult
           </button>
        </div>
      </div>

    </motion.div>
  );
};