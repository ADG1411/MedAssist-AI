import { AlertTriangle, Activity, Clock, FileText, ActivitySquare } from 'lucide-react';

export const PatientInfoPanel = () => {
  return (
    <div className="flex flex-col gap-4 h-full bg-slate-50 border-r border-slate-200 p-4 overflow-y-auto w-full md:w-80 shrink-0 custom-scrollbar">
      {/* SECTION 1: Basic Info */}
      <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-12 h-12 bg-brand-blue/10 text-brand-blue rounded-full flex items-center justify-center text-xl font-bold">
            JD
          </div>
          <div>
            <h2 className="text-lg font-bold text-slate-800">John Doe</h2>
            <p className="text-sm text-slate-500">45M • Blood: O+</p>
          </div>
        </div>
        
        <div className="space-y-2">
          <div className="flex items-start gap-2 text-red-600 bg-red-50 p-2 rounded-lg text-sm font-medium">
            <AlertTriangle className="w-4 h-4 mt-0.5 shrink-0" />
            <span>Allergic to Penicillin & Peanuts</span>
          </div>
          <div className="flex items-start gap-2 text-slate-700 bg-slate-50 p-2 rounded-lg text-sm">
            <Activity className="w-4 h-4 mt-0.5 shrink-0 text-brand-blue" />
            <span>Chronic: Type 2 Diabetes, Hypertension</span>
          </div>
        </div>
      </div>

      {/* SECTION 2: Quick Stats */}
      <div className="grid grid-cols-2 gap-2">
        <div className="bg-white p-3 rounded-xl shadow-sm border border-slate-100 text-center">
          <p className="text-xs text-slate-500 font-medium mb-1">Last Visit</p>
          <p className="text-sm font-bold text-slate-800">12 Oct 2023</p>
        </div>
        <div className="bg-white p-3 rounded-xl shadow-sm border border-slate-100 text-center">
          <p className="text-xs text-slate-500 font-medium mb-1">Total Visits</p>
          <p className="text-sm font-bold text-slate-800">14</p>
        </div>
      </div>

      {/* SECTION 3: Timeline */}
      <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100 flex-1">
        <h3 className="font-bold text-slate-800 mb-4 flex items-center gap-2">
          <Clock className="w-4 h-4 text-brand-blue" />
          Patient Timeline
        </h3>
        
        <div className="relative border-l-2 border-slate-100 ml-2 space-y-6 pb-4">
          {/* Timeline Item */}
          <div className="relative pl-4">
            <div className="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-brand-blue ring-4 ring-white" />
            <p className="text-xs font-bold text-slate-400 mb-1">Today, 10:30 AM</p>
            <p className="text-sm font-bold text-slate-800">Report Uploaded</p>
            <div className="flex items-center gap-1 text-xs text-brand-blue font-medium mt-1 bg-brand-blue/10 w-max px-2 py-1 rounded-md cursor-pointer hover:bg-brand-blue/20 transition-colors">
              <FileText className="w-3 h-3" /> Blood_Work_Oct.pdf
            </div>
          </div>
          
          <div className="relative pl-4">
            <div className="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-amber-500 ring-4 ring-white" />
            <p className="text-xs font-bold text-slate-400 mb-1">12 Oct 2023</p>
            <p className="text-sm font-bold text-slate-800">Fever & Cough Consultation</p>
            <p className="text-xs text-slate-600 mt-1 line-clamp-2">Prescribed paracetamol and complete rest for 3 days. Ordered general blood panel.</p>
          </div>

          <div className="relative pl-4">
            <div className="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-slate-300 ring-4 ring-white" />
            <p className="text-xs font-bold text-slate-400 mb-1">AI Highlight</p>
            <p className="text-sm font-bold text-slate-800">BP Rising Trend</p>
            <div className="flex items-center gap-1 text-xs text-slate-500 font-medium mt-1">
              <ActivitySquare className="w-3 h-3 text-amber-500" /> +15% over 6 months
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};