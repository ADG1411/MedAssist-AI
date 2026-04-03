import { BrainCircuit, AlertTriangle, Lightbulb, Bell, RefreshCw } from 'lucide-react';
import type { AIAnalysisResult } from '../../types/consultation';
import { QuickActions } from './QuickActions';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  patientId: string;
  aiData: AIAnalysisResult | null;
  loading: boolean;
  onRefresh: () => void;
}

const RISK_COLORS = {
  low: 'bg-teal-50 border-teal-200 text-teal-700',
  medium: 'bg-amber-50 border-amber-200 text-amber-700',
  high: 'bg-red-50 border-red-200 text-red-700 animate-pulse',
};

const RISK_BADGE = {
  low: 'bg-teal-500',
  medium: 'bg-amber-500',
  high: 'bg-red-500',
};

export function AIInsightsPanel({ patientId, aiData, loading, onRefresh }: Props) {

  return (
    <div className="h-full flex flex-col bg-slate-50 border-l border-slate-200 relative">
      
      {/* Header */}
      <div className="p-4 border-b border-slate-200 bg-white flex items-center justify-between shadow-sm shrink-0">
        <h2 className="text-sm font-black text-slate-800 uppercase tracking-wider flex items-center gap-2">
          <BrainCircuit className="w-4 h-4 text-indigo-500" />
          MedAssist AI 
        </h2>
        
        {aiData && (
          <span className="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-widest bg-slate-100 pl-1.5 pr-2 py-0.5 rounded-full border border-slate-200">
            <span className={cn("w-2 h-2 rounded-full", RISK_BADGE[aiData.risk_level])} />
            Risk: {aiData.risk_level}
          </span>
        )}
      </div>

      {/* Intelligence Content */}
      <div className="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-5">
        
        {loading && !aiData ? (
          <div className="flex flex-col items-center justify-center py-10 opacity-60">
            <RefreshCw className="w-6 h-6 text-indigo-500 animate-spin mb-3" />
            <p className="text-xs font-bold text-slate-500 tracking-widest uppercase">Analyzing Patient Context...</p>
          </div>
        ) : aiData ? (
          <>
            {/* Real-time Summary */}
            <div className="bg-white rounded-2xl p-4 border border-slate-200 shadow-sm relative overflow-hidden group">
              <div className="absolute top-0 left-0 w-1 h-full bg-indigo-500" />
              <div className="flex justify-between items-start mb-2">
                <h4 className="text-[11px] font-black text-slate-400 uppercase tracking-widest flex items-center gap-1.5">
                  <BrainCircuit className="w-3.5 h-3.5 text-indigo-400" /> Executive Summary
                </h4>
                <button onClick={onRefresh} className="opacity-0 group-hover:opacity-100 transition-opacity p-1 hover:bg-slate-100 rounded text-slate-400">
                  <RefreshCw className="w-3 h-3" />
                </button>
              </div>
              <p className="text-[13px] font-medium text-slate-700 leading-relaxed">
                {aiData.summary}
              </p>
            </div>

            {/* Smart Alerts */}
            {aiData.alerts.length > 0 && (
              <div>
                <h4 className="text-[11px] font-black text-slate-400 uppercase tracking-widest flex items-center gap-1.5 mb-2 px-1">
                  <Bell className="w-3.5 h-3.5" /> Smart Alerts
                </h4>
                <div className="space-y-2">
                  {aiData.alerts.map((alert, i) => (
                    <div key={i} className={cn("p-3 rounded-xl border flex gap-2.5", aiData.risk_level === 'high' ? RISK_COLORS.high : 'bg-rose-50 border-rose-200 text-rose-700')}>
                      <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5 opacity-80" />
                      <p className="text-[12px] font-bold leading-tight">{alert}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* AI Suggestions */}
            <div>
              <h4 className="text-[11px] font-black text-slate-400 uppercase tracking-widest flex items-center gap-1.5 mb-2 px-1">
                <Lightbulb className="w-3.5 h-3.5" /> AI Suggestions
              </h4>
              <div className="space-y-2">
                {aiData.suggestions.map((sug, i) => (
                  <div key={i} className="bg-indigo-50 border border-indigo-100 rounded-xl p-3 flex gap-2.5 shadow-sm">
                    <div className="w-4 h-4 rounded-full bg-indigo-200 text-indigo-700 flex items-center justify-center shrink-0 mt-0.5 text-[10px] font-black">
                      {i + 1}
                    </div>
                    <p className="text-[13px] font-semibold text-indigo-900 leading-tight">{sug}</p>
                  </div>
                ))}
              </div>
            </div>
            
            {/* Pattern Detection */}
            <div className="bg-white rounded-2xl p-4 border border-slate-200 shadow-sm">
               <h4 className="text-[11px] font-black text-slate-400 uppercase tracking-widest mb-2">
                 Pattern Detection
               </h4>
               <div className="flex gap-2 items-center bg-slate-50 p-2 rounded-lg border border-slate-100">
                 <div className="w-2 h-2 rounded-full bg-amber-500 animate-pulse shrink-0" />
                 <p className="text-[11px] font-bold text-slate-600">Possible chronic condition trend detected.</p>
               </div>
            </div>
            
          </>
        ) : null}
      </div>

      <QuickActions patientId={patientId} />
    </div>
  );
}
