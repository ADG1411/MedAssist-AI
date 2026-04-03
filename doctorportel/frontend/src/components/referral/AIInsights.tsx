import { Sparkles, AlertTriangle, AlertCircle, Info, CheckCircle2, ChevronRight } from 'lucide-react';
import type { AIInsight } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

const PRIORITY_CONFIG = {
  critical: { label: 'CRITICAL',  bg: 'bg-red-50',     border: 'border-red-200',     icon: AlertTriangle, iconColor: 'text-red-500',     badge: 'bg-red-500 text-white',    bar: 'bg-red-500' },
  high:     { label: 'HIGH',      bg: 'bg-orange-50',  border: 'border-orange-200',  icon: AlertCircle,   iconColor: 'text-orange-500',  badge: 'bg-orange-500 text-white', bar: 'bg-orange-500' },
  medium:   { label: 'MEDIUM',    bg: 'bg-amber-50',   border: 'border-amber-200',   icon: Info,          iconColor: 'text-amber-500',   badge: 'bg-amber-500 text-white',  bar: 'bg-amber-400' },
  low:      { label: 'LOW',       bg: 'bg-emerald-50', border: 'border-emerald-200', icon: CheckCircle2,  iconColor: 'text-emerald-500', badge: 'bg-emerald-500 text-white',bar: 'bg-emerald-400' },
};

interface Props { insight: AIInsight; }

export function AIInsights({ insight }: Props) {
  const cfg = PRIORITY_CONFIG[insight.priority];
  const Icon = cfg.icon;

  return (
    <div className={cn('rounded-2xl border p-5 space-y-4', cfg.bg, cfg.border)}>
      {/* Header */}
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 bg-white rounded-xl flex items-center justify-center shadow-sm">
            <Sparkles className="w-4 h-4 text-indigo-500" />
          </div>
          <div>
            <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">AI Health Summary</p>
            <p className="text-[13px] font-black text-slate-800">Patient Insights</p>
          </div>
        </div>
        <span className={cn('text-[10px] font-black px-2.5 py-1 rounded-full tracking-widest', cfg.badge)}>
          {cfg.label} PRIORITY
        </span>
      </div>

      {/* Summary */}
      <div className="bg-white/80 rounded-xl p-3.5 border border-white">
        <div className="flex gap-2.5">
          <Icon className={cn('w-4 h-4 mt-0.5 shrink-0', cfg.iconColor)} />
          <p className="text-[13px] font-semibold text-slate-700 leading-relaxed">{insight.summary}</p>
        </div>
      </div>

      {/* Key Points */}
      <div className="space-y-2">
        <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wide">Key Points</p>
        {insight.key_points.map((point, i) => (
          <div key={i} className="flex items-start gap-2 bg-white/60 rounded-lg px-3 py-2">
            <ChevronRight className="w-3.5 h-3.5 mt-0.5 shrink-0 text-slate-400" />
            <p className="text-[12px] font-medium text-slate-700">{point}</p>
          </div>
        ))}
      </div>

      {/* Recommended Action */}
      <div className="bg-white rounded-xl p-3.5 border border-slate-200">
        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Recommended Action</p>
        <p className="text-[13px] font-bold text-slate-800">{insight.recommended_action}</p>
      </div>
    </div>
  );
}
