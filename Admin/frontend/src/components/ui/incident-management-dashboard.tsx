import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import {
  Activity,
  HeartPulse,
  Clock,
  Flame,
} from 'lucide-react';

const incidentData = [
  { name: '00:00', critical: 4, high: 6, medium: 10 },
  { name: '04:00', critical: 2, high: 4, medium: 8 },
  { name: '08:00', critical: 8, high: 12, medium: 20 },
  { name: '12:00', critical: 12, high: 15, medium: 25 },
  { name: '16:00', critical: 9, high: 14, medium: 22 },
  { name: '20:00', critical: 6, high: 9, medium: 15 },
];

const responseTimeData = [
  { time: 'Mon', avg: 4.2 },
  { time: 'Tue', avg: 3.8 },
  { time: 'Wed', avg: 4.5 },
  { time: 'Thu', avg: 3.2 },
  { time: 'Fri', avg: 2.9 },
  { time: 'Sat', avg: 4.8 },
  { time: 'Sun', avg: 5.1 },
];

export const IncidentManagementDashboard = () => {
  return (
    <div className="flex flex-col gap-6 p-6 w-full animate-in fade-in duration-500">
      {/* Header Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-rose-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-sm font-semibold text-slate-500">Active Critical</p>
              <h3 className="text-3xl font-bold text-rose-600 mt-1">12</h3>
            </div>
            <div className="p-2.5 bg-rose-50 text-rose-600 rounded-xl">
              <Flame className="h-5 w-5" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-rose-600 font-bold flex items-center gap-1">
              +4
            </span>
            <span className="text-slate-400 ml-2">from last hour</span>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-sm font-semibold text-slate-500">Avg Response Time</p>
              <h3 className="text-3xl font-bold text-slate-800 mt-1">3.2m</h3>
            </div>
            <div className="p-2.5 bg-blue-50 text-blue-600 rounded-xl">
              <Clock className="h-5 w-5" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-emerald-500 font-bold flex items-center gap-1">
              -0.5m
            </span>
            <span className="text-slate-400 ml-2">improvement</span>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-sm font-semibold text-slate-500">Units Deployed</p>
              <h3 className="text-3xl font-bold text-slate-800 mt-1">48</h3>
            </div>
            <div className="p-2.5 bg-emerald-50 text-emerald-600 rounded-xl">
              <Activity className="h-5 w-5" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-emerald-500 font-bold flex items-center gap-1">
              82%
            </span>
            <span className="text-slate-400 ml-2">fleet utilization</span>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-sm font-semibold text-slate-500">Hospitals Alerted</p>
              <h3 className="text-3xl font-bold text-slate-800 mt-1">6</h3>
            </div>
            <div className="p-2.5 bg-amber-50 text-amber-600 rounded-xl">
              <HeartPulse className="h-5 w-5" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <span className="text-slate-500 font-medium">
              3 Level-1 Trauma Centers
            </span>
          </div>
        </div>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <h3 className="text-lg font-bold text-slate-800 mb-6">Incident Volume by Severity</h3>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={incidentData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} />
                <Tooltip 
                  cursor={{ fill: '#f8fafc' }}
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Bar dataKey="critical" stackId="a" fill="#e11d48" radius={[0, 0, 4, 4]} />
                <Bar dataKey="high" stackId="a" fill="#f59e0b" />
                <Bar dataKey="medium" stackId="a" fill="#3b82f6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <h3 className="text-lg font-bold text-slate-800 mb-6">Avg Response Time (Weekly)</h3>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={responseTimeData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="time" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Line type="monotone" dataKey="avg" stroke="#0d9488" strokeWidth={3} dot={{ r: 4, strokeWidth: 2 }} activeDot={{ r: 6 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
};
