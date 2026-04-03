import { Brain, AlertCircle, TrendingUp, Sparkles, Pill, Activity } from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

export const AIInsightPanel = () => {
  return (
    <div className="flex flex-col gap-4 h-full bg-slate-900 border-l border-slate-800 p-4 overflow-y-auto w-full md:w-[320px] lg:w-[380px] shrink-0 custom-scrollbar text-slate-300">
      
      {/* Header */}
      <div className="flex items-center gap-3 pb-4 border-b border-slate-800">
        <div className="w-10 h-10 bg-brand-blue/20 rounded-xl flex items-center justify-center border border-brand-blue/30">
          <Brain className="w-5 h-5 text-brand-light" />
        </div>
        <div>
          <h2 className="text-lg font-bold text-white">AI Intelligence</h2>
          <p className="text-xs text-brand-light/70 font-medium flex items-center gap-1">
            <Sparkles className="w-3 h-3" /> Live analysis active
          </p>
        </div>
      </div>

      {/* SECTION 1: Auto Summary */}
      <div className="space-y-3">
        <h3 className="text-xs font-bold uppercase tracking-widest text-slate-500">Case Summary</h3>
        <div className="bg-slate-800/50 p-4 rounded-2xl border border-slate-700">
          <p className="text-sm leading-relaxed text-slate-300 font-medium">
            Patient presents with elevated blood pressure (150/95) and dizziness. Routine blood panel indicates slightly elevated LDL cholesterol. History of Type 2 Diabetes is well-managed.
          </p>
        </div>
      </div>

      {/* SECTION 2: Risk Prediction */}
      <div className="space-y-3">
        <h3 className="text-xs font-bold uppercase tracking-widest text-slate-500">Risk Assessment</h3>
        <div className="bg-amber-950/30 p-4 rounded-2xl border border-amber-900/50 flex flex-col gap-3">
          <div className="flex justify-between items-start">
            <div className="flex items-center gap-2 text-amber-500">
              <AlertCircle className="w-5 h-5" />
              <span className="font-bold">Moderate Risk</span>
            </div>
            <span className="text-xs font-bold bg-amber-500/10 text-amber-500 px-2 py-1 rounded-md">82% Confidence</span>
          </div>
          <p className="text-xs text-amber-500/80 font-medium">
            Potential for hypertensive crisis if left unmanaged. Strong indicator given concurrent diabetes history.
          </p>
        </div>
      </div>

      {/* SECTION 3: Diagnosis & Suggestions */}
      <div className="space-y-3">
        <h3 className="text-xs font-bold uppercase tracking-widest text-slate-500">Suggested Action Plan</h3>
        <div className="flex flex-col gap-2">
          
          {/* Action 1 */}
          <div className="bg-slate-800/30 p-3 rounded-xl border border-slate-700/50 hover:bg-slate-800 hover:border-brand-blue/30 transition-all cursor-pointer group">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2 text-white font-bold text-sm">
                <Pill className="w-4 h-4 text-brand-light group-hover:text-brand-blue transition-colors" />
                Adjust Medication
              </div>
              <button className="text-xs bg-brand-blue rounded-full px-3 py-1 text-white font-bold opacity-0 group-hover:opacity-100 transition-opacity drop-shadow-md">
                Apply
              </button>
            </div>
            <p className="text-xs text-slate-400">Consider increasing Lisinopril dosage or adding a mild diuretic.</p>
          </div>

          {/* Action 2 */}
          <div className="bg-slate-800/30 p-3 rounded-xl border border-slate-700/50 hover:bg-slate-800 hover:border-brand-blue/30 transition-all cursor-pointer group">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2 text-white font-bold text-sm">
                <Activity className="w-4 h-4 text-brand-light group-hover:text-brand-blue transition-colors" />
                Schedule Tests
              </div>
              <button className="text-xs bg-brand-blue rounded-full px-3 py-1 text-white font-bold opacity-0 group-hover:opacity-100 transition-opacity drop-shadow-md">
                Add to Rx
              </button>
            </div>
            <p className="text-xs text-slate-400">Order ECG and Renal Function Panel to rule out underlying damage.</p>
          </div>

        </div>
      </div>

      {/* Trend Mini Graph (Mock) */}
      <div className="mt-auto pt-4 border-t border-slate-800">
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs font-bold text-slate-400 flex items-center gap-1"><TrendingUp className="w-3 h-3" /> BP Trend</span>
          <span className="text-xs font-bold text-brand-light">Last 6 Months</span>
        </div>
        <div className="h-20 w-full flex items-end justify-between gap-1 px-2">
          {/* Mock Bars */}
          {[40, 45, 55, 60, 50, 80].map((h, i) => (
            <div key={i} className="w-1/6 bg-brand-blue/20 rounded-t-sm relative group">
              <div 
                className={cn("absolute bottom-0 w-full rounded-t-sm transition-all duration-500", h > 70 ? "bg-amber-500" : "bg-brand-blue")}
                style={{ height: `${h}%` }}
              />
            </div>
          ))}
        </div>
      </div>

    </div>
  );
};