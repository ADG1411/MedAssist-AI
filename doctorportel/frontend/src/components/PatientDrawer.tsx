import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { Patient } from '../types/patient';
import { X, Phone, Mail, FileText, Pill, FileClock, Activity, Maximize2, DollarSign, Download, CheckCircle2 } from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

interface PatientDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  patient: Patient | null;
}

export const PatientDrawer: React.FC<PatientDrawerProps> = ({ isOpen, onClose, patient }) => {
  if (!patient && isOpen) return null;

  return (
    <AnimatePresence>
      {isOpen && patient && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-[100]"
          />

          {/* Drawer Panel */}
          <motion.div
            initial={{ x: '100%', boxShadow: '-20px 0 25px -5px rgba(0, 0, 0, 0.1)' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed inset-y-0 right-0 z-[110] w-full max-w-md bg-[#F9FBFF] overflow-y-auto flex flex-col shadow-2xl pb-10"
          >
            {/* Header / Profile Summary */}
            <div className="sticky top-0 bg-white z-20 border-b border-slate-100 px-6 py-5 flex items-center justify-between">
               <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                 Patient Details
               </h2>
               <div className="flex gap-2">
                  <button className="p-2 text-slate-400 hover:bg-slate-100 rounded-full transition-colors">
                     <Maximize2 className="w-5 h-5" />
                  </button>
                  <button 
                    onClick={onClose}
                    className="p-2 text-slate-400 hover:bg-red-50 hover:text-red-500 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
               </div>
            </div>

            <div className="p-6 space-y-6">
              
              {/* SECTION 1: Basic Info */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100 flex items-start gap-4 relative overflow-hidden">
                 <div className="absolute top-0 right-0 w-24 h-24 bg-brand-light rounded-bl-full opacity-50 pointer-events-none" />
                 
                 <img src={patient.avatar} alt={patient.name} className="w-16 h-16 rounded-2xl object-cover shadow-sm border border-slate-50 relative z-10" />
                 <div className="relative z-10">
                    <div className="flex items-center gap-2">
                       <h3 className="text-xl font-bold text-slate-800">{patient.name}</h3>
                       {patient.status === 'Critical' && (
                         <span className="w-2.5 h-2.5 bg-red-500 rounded-full animate-pulse" />
                       )}
                    </div>
                    <p className="text-sm font-medium text-slate-500 mb-1">{patient.age} years • {patient.gender} {patient.blood_group ? `• ${patient.blood_group}` : ''}</p>
                    {(patient.allergies?.length || patient.chronic_conditions?.length) ? (
                      <div className="flex flex-wrap gap-1.5 mb-3">
                        {patient.allergies?.map((a: string) => (
                           <span key={a} className="text-[10px] font-bold px-1.5 py-0.5 bg-red-50 text-red-600 rounded">Allergy: {a}</span>
                        ))}
                        {patient.chronic_conditions?.map((c: string) => (
                           <span key={c} className="text-[10px] font-bold px-1.5 py-0.5 bg-amber-50 text-amber-600 rounded">{c}</span>
                        ))}
                      </div>
                    ) : <div className="mb-3" />}
                    
                    <div className="flex gap-4">
                       <button className="flex items-center text-xs font-bold text-brand-blue bg-brand-light hover:bg-blue-100 px-3 py-1.5 rounded-lg transition-colors">
                         <Phone className="w-3.5 h-3.5 mr-1.5" /> Call
                       </button>
                       <button className="flex items-center text-xs font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-lg transition-colors">
                         <Mail className="w-3.5 h-3.5 mr-1.5" /> Message
                       </button>
                    </div>
                 </div>
              </div>

              {/* SECTION 7: Health Trends Placeholder */}
              <div className="bg-gradient-to-br from-slate-900 to-slate-800 rounded-2xl p-5 shadow-sm text-white">
                 <div className="flex justify-between items-center mb-4">
                    <h4 className="font-bold flex items-center text-sm text-slate-100">
                      <Activity className="w-4 h-4 mr-2 text-brand-blue" />
                      Health Metrics
                    </h4>
                    <span className="text-xs font-bold bg-white/10 px-2 py-1 rounded text-slate-300">Last 30 Days</span>
                 </div>
                 {/* Graph placeholder */}
                 <div className="h-24 flex items-end justify-between gap-2 border-b border-white/10 pb-2 relative">
                    {/* Fake SVG Graph Line */}
                    <svg className="absolute inset-0 w-full h-full" preserveAspectRatio="none" viewBox="0 0 100 100">
                      <path d="M0,80 L20,60 L40,70 L60,30 L80,50 L100,10" stroke="rgba(255,255,255,0.2)" strokeWidth="2" fill="none" vectorEffect="non-scaling-stroke" />
                      <path d="M0,80 L20,60 L40,70 L60,30 L80,50 L100,10 L100,100 L0,100 Z" fill="url(#grad)" opacity="0.1" />
                      <defs>
                        <linearGradient id="grad" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor="#3b82f6" />
                          <stop offset="100%" stopColor="transparent" />
                        </linearGradient>
                      </defs>
                    </svg>
                    {/* Fake Bars representing BP ranges */}
                    {[40, 60, 45, 80, 50, 75, 60].map((val, i) => (
                      <div key={i} className="w-full bg-brand-blue/30 rounded-t-sm" style={{ height: `${val}%` }} />
                    ))}
                 </div>
                 <div className="flex justify-between text-[10px] font-medium text-slate-400 mt-2">
                   <span>BP: 120/80 (Avg)</span>
                   <span>Sugar: 95 mg/dL</span>
                 </div>
              </div>

              {/* Grid sections for mini-modules */}
              <div className="grid grid-cols-2 gap-4">
                 {/* SECTION 4: Prescriptions */}
                 <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100">
                   <h4 className="font-bold text-sm text-slate-800 mb-3 flex items-center">
                     <Pill className="w-4 h-4 mr-2 text-purple-500" /> Prescriptions
                   </h4>
                   <div className="space-y-2">
                     <div className="text-xs bg-slate-50 p-2 rounded-lg border border-slate-100 flex justify-between items-center group cursor-pointer hover:bg-purple-50 hover:border-purple-100 transition-colors">
                        <span className="font-semibold text-slate-700">Metformin 500mg</span>
                        <Download className="w-3.5 h-3.5 text-slate-400 group-hover:text-purple-600" />
                     </div>
                     <button className="w-full text-[11px] font-bold text-slate-500 hover:text-brand-blue mt-1">View All</button>
                   </div>
                 </div>

                 {/* SECTION 3: Reports */}
                 <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100">
                   <h4 className="font-bold text-sm text-slate-800 mb-3 flex items-center">
                     <FileText className="w-4 h-4 mr-2 text-amber-500" /> Recent Reports
                   </h4>
                   <div className="space-y-2">
                     <div className="text-xs bg-slate-50 p-2 rounded-lg border border-slate-100 flex justify-between items-center group cursor-pointer hover:bg-amber-50 hover:border-amber-100 transition-colors">
                        <span className="font-semibold text-slate-700">Blood Test.pdf</span>
                        <Download className="w-3.5 h-3.5 text-slate-400 group-hover:text-amber-600" />
                     </div>
                     <button className="w-full text-[11px] font-bold text-slate-500 hover:text-brand-blue mt-1">View All</button>
                   </div>
                 </div>
              </div>

              {/* SECTION 2: Medical History (Timeline) */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
                 <h4 className="font-bold text-sm text-slate-800 mb-4 flex items-center">
                   <FileClock className="w-4 h-4 mr-2 text-brand-blue" /> Case History
                 </h4>
                 <div className="relative pl-3 space-y-4 border-l-2 border-slate-100">
                   <div className="relative">
                      <div className="absolute -left-[17px] top-1 w-3 h-3 bg-white border-2 border-brand-blue rounded-full" />
                      <p className="text-xs font-bold text-slate-800">Visit - {patient.lastDiagnosis}</p>
                      <p className="text-[11px] text-slate-500 mt-0.5">{patient.lastVisit}</p>
                   </div>
                   <div className="relative">
                      <div className="absolute -left-[17px] top-1 w-3 h-3 bg-white border-2 border-slate-300 rounded-full" />
                      <p className="text-xs font-bold text-slate-600">Initial Consultation</p>
                      <p className="text-[11px] text-slate-400 mt-0.5">2023-08-10</p>
                   </div>
                 </div>
              </div>

              {/* SECTION 6: Billing */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-100">
                 <h4 className="font-bold text-sm text-slate-800 mb-4 flex items-center">
                   <DollarSign className="w-4 h-4 mr-2 text-emerald-500" /> Billing Summary
                 </h4>
                 
                 <div className="flex gap-4">
                    <div className="flex-1 bg-slate-50 p-3 rounded-xl border border-slate-100">
                       <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1">Total Paid</p>
                       <p className="text-lg font-bold text-slate-800">${patient.totalFees}</p>
                    </div>
                    <div className={cn(
                      "flex-1 p-3 rounded-xl border",
                      patient.pendingAmount > 0 ? "bg-red-50 border-red-100" : "bg-emerald-50 border-emerald-100"
                    )}>
                       <p className="text-[11px] font-bold uppercase tracking-wider mb-1 flex items-center justify-between">
                         <span className={patient.pendingAmount > 0 ? "text-red-500" : "text-emerald-600"}>Pending</span>
                         {patient.pendingAmount === 0 && <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />}
                       </p>
                       <p className={cn("text-lg font-bold", patient.pendingAmount > 0 ? "text-red-700" : "text-emerald-700")}>
                         ${patient.pendingAmount}
                       </p>
                    </div>
                 </div>

                 {patient.pendingAmount > 0 && (
                   <button className="mt-4 w-full bg-slate-900 hover:bg-slate-800 text-white font-bold text-sm py-3 rounded-xl transition-colors">
                     Generate Invoice Reminder
                   </button>
                 )}
              </div>

            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};