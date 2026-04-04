import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { BarChart3, TrendingUp, TrendingDown, Layers, Users } from 'lucide-react';
import { DashboardView } from '@/components/watermelon/e-commerce-dashboard/dashboardView';

const diseaseData = [
  { name: 'Cardiology', cases: 1420 },
  { name: 'Neurology', cases: 890 },
  { name: 'Dermatology', cases: 1100 },
  { name: 'Orthopedics', cases: 540 },
  { name: 'Pediatrics', cases: 1200 },
];

export const Analytics: React.FC = () => {
  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row justify-between mb-8 gap-4">
         <div>
            <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight flex items-center gap-3">
               <span className="p-2 bg-indigo-100 text-indigo-600 rounded-[1.25rem]"><BarChart3 className="h-6 w-6 stroke-[2.5]" /></span>
               Data & Analytics
            </h1>
            <p className="text-slate-500 font-medium text-sm mt-3 ml-[3.25rem]">System usage, disease trends, and core BI metrics</p>
         </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <Stat box="Users" val="45k" trend="+5%" icon={Users} up={true} />
        <Stat box="Avg Consult Time" val="14m" trend="-2m" icon={Activity} up={true} flipGood={true} color="bg-emerald-50 text-emerald-600" />
        <Stat box="AI Resolution Rate" val="86%" trend="+12%" icon={Layers} up={true} color="bg-purple-50 text-purple-600" />
        <Stat box="Patient Attrition" val="2.4%" trend="+0.5%" icon={TrendingDown} up={false} color="bg-rose-50 text-rose-600" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
         <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200/60 h-[400px] flex flex-col">
            <h2 className="text-lg font-bold tracking-tight text-slate-800 mb-6">Most Common Case Types</h2>
            <div className="flex-1 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={diseaseData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} />
                  <Tooltip cursor={{fill: '#f1f5f9'}} contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}} />
                  <Bar dataKey="cases" fill="#4f46e5" radius={[6, 6, 0, 0]} barSize={40} />
                </BarChart>
              </ResponsiveContainer>
            </div>
         </div>
         
         <div className="bg-indigo-900 p-6 rounded-2xl shadow-md border border-indigo-700 h-[400px] text-white flex flex-col relative overflow-hidden">
            <div className="absolute top-0 right-0 w-64 h-64 bg-indigo-500 rounded-full blur-3xl opacity-20 -mr-10 -mt-10"></div>
            <h2 className="text-lg font-bold tracking-tight mb-2 relative z-10">AI Usage Insight</h2>
            <p className="text-indigo-200 text-sm font-medium mb-6 relative z-10">Analysis of MedAssist behavior across sectors</p>
            
            <div className="space-y-4 flex-1 relative z-10">
               <Insight title="Neurology Diagnostics" val="92% Accuracy" desc="AI diagnosis matched human doctor in 92% of cases." />
               <Insight title="ER Response Time" val="< 2.4s" desc="Average latency from emergency prompt to first suggested action." />
               <Insight title="Prescription Flags" val="1,402 Prevented" desc="AI flagged 1.4k conflicting medication prescriptions before issuance." />
            </div>
         </div>
      </div>

      <div className="mt-8">
        <DashboardView />
      </div>
    </div>
  );
};

const Stat: React.FC<any> = ({box, val, trend, icon: Icon, up, flipGood, color = "bg-indigo-50 text-indigo-600"}) => (
  <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-200/60 flex items-center justify-between">
    <div>
      <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">{box}</p>
      <div className="flex items-center gap-3 mt-1">
        <p className="text-3xl font-extrabold text-slate-800 tabular-nums">{val}</p>
        <span className={`text-xs font-bold px-2 py-0.5 rounded-md flex items-center gap-1 ${
          ((up && !flipGood) || (!up && flipGood)) ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'
        }`}>
          {up ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />} {trend}
        </span>
      </div>
    </div>
    <div className={`p-3 rounded-[1.25rem] ${color}`}>
      <Icon className="h-5 w-5 stroke-[2.5]" />
    </div>
  </div>
);

const Insight: React.FC<any> = ({title, val, desc}) => (
  <div className="bg-indigo-800/40 p-4 rounded-xl border border-indigo-500/20 backdrop-blur-sm">
     <div className="flex justify-between items-center mb-1">
       <span className="font-bold text-indigo-100">{title}</span>
       <span className="text-xs font-mono bg-indigo-500/30 text-indigo-200 px-2 py-0.5 rounded font-bold ring-1 ring-indigo-400/30">{val}</span>
     </div>
     <p className="text-xs text-indigo-300 font-medium">{desc}</p>
  </div>
);

const Activity = BarChart3; // Mocking activity icon
