import { cn } from '../../layouts/DashboardLayout';
import type { LucideIcon } from 'lucide-react';

interface SummaryCardProps {
  title: string;
  value: string;
  trend: string;
  isPositive: boolean;
  icon: LucideIcon;
  color: string;
  bg: string;
}

export const SummaryCard = ({ title, value, trend, isPositive, icon: Icon, color, bg }: SummaryCardProps) => (
  <div className="bg-white rounded-[1.5rem] p-6 shadow-sm border border-slate-200/60 flex items-center hover:border-brand-blue/30 hover:shadow-md transition-all group">
    <div className={cn("w-14 h-14 rounded-2xl flex items-center justify-center mr-5 transition-transform group-hover:scale-110 shadow-inner", bg, color)}>
      <Icon className="h-6 w-6" />
    </div>
    <div>
      <p className="text-slate-500 text-[13px] font-bold uppercase tracking-wider">{title}</p>
      <h3 className="text-2xl font-black text-slate-800 mt-1 tracking-tight">{value}</h3>
      <p className={cn("text-xs font-bold mt-1.5 flex items-center gap-1 w-fit px-2 py-0.5 rounded-md", isPositive ? "bg-emerald-50 text-emerald-600" : "bg-red-50 text-red-600")}>
        {isPositive ? '↑' : '↓'} {trend}
      </p>
    </div>
  </div>
);