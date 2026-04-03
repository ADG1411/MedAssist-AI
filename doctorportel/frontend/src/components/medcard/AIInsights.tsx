import { Brain, TrendingUp, AlertCircle, Activity, Sparkles } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  insights: string[];
  riskLevel?: 'low' | 'moderate' | 'high';
  generatedAt?: string;
}

const RISK_CONFIG = {
  low:      { label: 'Low Risk',      color: 'text-emerald-600', bg: 'bg-emerald-50',  border: 'border-emerald-200', dot: 'bg-emerald-400' },
  moderate: { label: 'Moderate Risk', color: 'text-amber-600',   bg: 'bg-amber-50',    border: 'border-amber-200',   dot: 'bg-amber-400'   },
  high:     { label: 'High Risk',     color: 'text-rose-600',    bg: 'bg-rose-50',     border: 'border-rose-200',    dot: 'bg-rose-400 animate-pulse'    },
};

const INSIGHT_ICONS = [TrendingUp, AlertCircle, Activity, Brain, Sparkles];

const insightColor = (text: string): string => {
  const t = text.toLowerCase();
  if (t.includes('allerg') || t.includes('critical') || t.includes('high priority')) return 'border-l-rose-400';
  if (t.includes('trend') || t.includes('increasing') || t.includes('recurring'))   return 'border-l-amber-400';
  if (t.includes('frequent') || t.includes('repeated'))                              return 'border-l-orange-400';
  return 'border-l-teal-400';
};


export const AIInsights = ({ insights, riskLevel = 'low', generatedAt }: Props) => {
  const risk = RISK_CONFIG[riskLevel];

  return (
    <div className="bg-slate-900 rounded-2xl overflow-hidden shadow-sm">

      {/* Header */}
      <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-700/50">
        <div className="w-9 h-9 bg-gradient-to-br from-teal-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-md shrink-0">
          <Brain className="w-5 h-5 text-white" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-white font-black text-[14px] leading-tight">AI Medical Summary</p>
          <p className="text-slate-400 text-[10px] font-semibold mt-0.5 flex items-center gap-1.5">
            <Sparkles className="w-3 h-3 text-teal-400" />
            SanjivaniAI · Auto-analyzed from visit history
          </p>
        </div>
        <div className={cn('flex items-center gap-1.5 px-2.5 py-1 rounded-full border text-[11px] font-bold shrink-0', risk.bg, risk.border, risk.color)}>
          <span className={cn('w-1.5 h-1.5 rounded-full', risk.dot)} />
          {risk.label}
        </div>
      </div>

      {/* Insights */}
      <div className="px-5 py-4 space-y-2.5">
        {insights.length === 0 ? (
          <p className="text-slate-400 text-[13px] font-medium text-center py-4">
            No AI insights available for this patient yet.
          </p>
        ) : (
          insights.map((insight, i) => {
            const Icon = INSIGHT_ICONS[i % INSIGHT_ICONS.length];
            const leftColor = insightColor(insight);
            return (
              <div key={i}
                className={cn('flex items-start gap-3 rounded-xl px-4 py-3 border-l-4 bg-slate-800/60', leftColor)}>
                <Icon className="w-4 h-4 text-slate-300 shrink-0 mt-0.5" />
                <p className="text-[13px] font-semibold text-slate-200 leading-snug">{insight}</p>
              </div>
            );
          })
        )}
      </div>

      {/* Footer */}
      {generatedAt && (
        <div className="px-5 pb-4">
          <p className="text-[10px] text-slate-500 font-medium">
            Generated: {new Date(generatedAt).toLocaleString('en-IN', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}
          </p>
        </div>
      )}
    </div>
  );
};
