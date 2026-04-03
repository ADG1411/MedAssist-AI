import { Calendar, Download, Share2 } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

interface FiltersBarProps {
  activeFilter: string;
  setActiveFilter: (filter: string) => void;
}

const FILTERS = ['Today', 'This Week', 'This Month', 'Custom Range'];

export const FiltersBar = ({ activeFilter, setActiveFilter }: FiltersBarProps) => (
  <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8 bg-white/50 p-2 rounded-2xl border border-slate-200/50 backdrop-blur-sm">
    <div className="flex bg-white p-1.5 rounded-xl shadow-sm border border-slate-200/50 overflow-x-auto w-full md:w-auto hide-scrollbar">
      {FILTERS.map(filter => (
        <button
          key={filter}
          onClick={() => setActiveFilter(filter)}
          className={cn(
            "px-4 py-2 rounded-lg text-[13px] font-bold transition-all whitespace-nowrap",
            activeFilter === filter 
              ? "bg-brand-blue text-white shadow-md" 
              : "text-slate-600 hover:bg-slate-50"
          )}
        >
          {filter === 'Custom Range' ? (
             <span className="flex items-center gap-2"><Calendar className="w-4 h-4" /> {filter}</span>
          ) : filter}
        </button>
      ))}
    </div>

    <div className="flex gap-2 w-full md:w-auto">
      <button className="flex-1 md:flex-none flex items-center justify-center gap-2 bg-white border border-slate-200 text-slate-700 text-[13px] font-bold px-4 py-2.5 rounded-xl hover:bg-slate-50 hover:border-slate-300 transition-all shadow-sm">
        <Share2 className="w-4 h-4" /> Share
      </button>
      <button className="flex-1 md:flex-none flex items-center justify-center gap-2 bg-slate-800 text-white text-[13px] font-bold px-4 py-2.5 rounded-xl hover:bg-slate-700 transition-all shadow-md shadow-slate-800/10">
        <Download className="w-4 h-4" /> Export PDF
      </button>
    </div>
  </div>
);