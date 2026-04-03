import type { ReactNode } from 'react';

interface ChartCardProps {
  title: string;
  subtitle?: string;
  children: ReactNode;
  action?: ReactNode;
}

export const ChartCard = ({ title, subtitle, children, action }: ChartCardProps) => (
  <div className="bg-white rounded-[1.5rem] p-6 shadow-sm border border-slate-200/60 flex flex-col h-full hover:shadow-md transition-shadow">
    <div className="flex justify-between items-start mb-6">
      <div>
        <h3 className="text-[16px] font-black text-slate-800">{title}</h3>
        {subtitle && <p className="text-[13px] text-slate-500 font-medium mt-1">{subtitle}</p>}
      </div>
      {action && <div>{action}</div>}
    </div>
    <div className="flex-1 w-full min-h-[300px]">
      {children}
    </div>
  </div>
);