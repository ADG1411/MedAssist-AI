import React from 'react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { Activity, Stethoscope, HeartPulse, Hospital, ArrowRightCircle } from 'lucide-react';

const data = [
  { name: 'Mon', revenue: 4000 },
  { name: 'Tue', revenue: 8000 },
  { name: 'Wed', revenue: 6000 },
  { name: 'Thu', revenue: 10000 },
  { name: 'Fri', revenue: 9000 },
  { name: 'Sat', revenue: 12000 },
  { name: 'Sun', revenue: 14500 },
];

export const Dashboard: React.FC = () => {
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8 fade-in animate-in fade-in slide-in-from-bottom-2 duration-300">
      <header className="flex justify-between items-end border-b border-slate-200 pb-5">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight">Ecosystem Dashboard</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Real-time pulse of MedAssist platform</p>
        </div>
        <button className="bg-teal-600 hover:bg-teal-700 text-white font-medium px-5 py-2.5 rounded-xl shadow-sm text-sm transition-all focus:ring-4 focus:ring-teal-500/20 active:scale-95">
          Download Report
        </button>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Active Doctors" value="1,241" icon={Stethoscope} trend="+5.2%" color="text-blue-500 bg-blue-50" trendColor="text-emerald-500" />
        <StatCard title="Total Patients" value="45,105" icon={HeartPulse} trend="+12.4%" color="text-teal-500 bg-teal-50" trendColor="text-emerald-500" />
        <StatCard title="Partner Hospitals" value="34" icon={Hospital} trend="+1" color="text-indigo-500 bg-indigo-50" trendColor="text-emerald-500" />
        <StatCard title="Live Consultations" value="18" icon={Activity} alert={true} color="text-rose-500 bg-rose-50" />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <div className="bg-white p-6 pb-2 rounded-2xl shadow-sm ring-1 ring-slate-200/60 xl:col-span-2 flex flex-col h-[400px]">
          <div className="flex justify-between items-center mb-6 px-1">
            <h2 className="text-lg font-bold tracking-tight text-slate-800">Revenue Growth</h2>
            <select className="bg-slate-50 border border-slate-200 text-slate-600 text-sm rounded-lg px-3 py-1.5 focus:ring-teal-500/30">
              <option>Last 7 days</option>
              <option>This Month</option>
            </select>
          </div>
          <div className="flex-1 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0d9488" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#0d9488" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 12}} tickFormatter={(value) => `$${value/1000}k`} />
                <Tooltip 
                   contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                   cursor={{ stroke: '#cbd5e1', strokeWidth: 1, strokeDasharray: '4 4' }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#0d9488" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm ring-1 ring-slate-200/60 h-[400px] flex flex-col">
          <div className="flex justify-between items-center mb-6">
             <h2 className="text-lg font-bold tracking-tight text-slate-800">Critical Cases</h2>
             <span className="bg-rose-100 text-rose-700 text-xs font-bold px-2 py-0.5 rounded-full px-2.5">Real-time</span>
          </div>
          <div className="flex-1 overflow-y-auto pr-2 space-y-4">
             <RecentCase id="#CAS-1109" patient="Mark Williams" severity="Critical" time="2 mins ago" />
             <RecentCase id="#CAS-1108" patient="Sarah Jenkins" severity="High" time="15 mins ago" />
             <RecentCase id="#CAS-1106" patient="David Cho" severity="Medium" time="1 hr ago" />
             <RecentCase id="#CAS-1102" patient="Anna Lee" severity="Resolved" time="3 hrs ago" />
             <RecentCase id="#CAS-1101" patient="Jon Snow" severity="Resolved" time="5 hrs ago" />
          </div>
          <button className="mt-4 w-full flex items-center justify-center gap-2 text-sm text-teal-600 font-semibold py-2 hover:bg-teal-50 rounded-xl transition">
            View All Cases <ArrowRightCircle className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
};

const StatCard: React.FC<any> = ({title, value, icon: Icon, trend, color, trendColor, alert}) => (
  <div className={`relative p-6 rounded-2xl shadow-sm ring-1 bg-white hover:shadow-md transition-shadow group overflow-hidden ${alert ? 'ring-rose-200' : 'ring-slate-200/60'}`}>
    {alert && <div className="absolute top-0 right-0 h-full w-1.5 bg-rose-500 animate-pulse" />}
    <div className="flex justify-between items-start">
      <div>
        <p className="text-sm font-semibold text-slate-500 mb-1">{title}</p>
        <p className="text-3xl font-extrabold text-slate-800 tabular-nums tracking-tight">{value}</p>
        {trend && (
          <p className={`text-xs font-semibold mt-2 flex items-center gap-1 ${trendColor}`}>
            ↑ {trend} <span className="text-slate-400 font-medium">vs last month</span>
          </p>
        )}
        {alert && (
           <p className="text-xs font-bold mt-2 text-rose-500 tracking-wide uppercase flex items-center gap-1.5">
             <span className="relative flex h-2 w-2"><span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span><span className="relative inline-flex rounded-full h-2 w-2 bg-rose-500"></span></span>
             Requires Attention
           </p>
        )}
      </div>
      <div className={`p-3 rounded-[1.25rem] ${color} group-hover:scale-110 transition-transform duration-300 ease-out`}>
        <Icon className="h-6 w-6 stroke-[2.5]" />
      </div>
    </div>
  </div>
);

const RecentCase: React.FC<any> = ({id, patient, severity, time}) => {
  const isCritical = severity === 'Critical';
  const isResolved = severity === 'Resolved';
  
  return (
    <div className="flex items-center justify-between group p-3 -mx-3 rounded-xl hover:bg-slate-50 transition cursor-pointer">
      <div className="flex flex-col">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-slate-900">{id}</span>
          <span className={`text-[10px] uppercase tracking-wider font-extrabold px-2 py-0.5 rounded-full ${
            isCritical ? 'bg-rose-100 text-rose-700' : 
            isResolved ? 'bg-slate-100 text-slate-500' : 'bg-amber-100 text-amber-700'
          }`}>{severity}</span>
        </div>
        <span className="text-sm font-medium text-slate-600 mt-0.5">{patient}</span>
      </div>
      <span className="text-xs font-medium text-slate-400 flex items-center gap-1.5 group-hover:text-teal-600 transition-colors">
        {time}
      </span>
    </div>
  );
};
