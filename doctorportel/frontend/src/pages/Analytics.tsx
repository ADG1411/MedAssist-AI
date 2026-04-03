import { useState, useRef, useEffect } from 'react';
import {
  Users, CheckCircle2, DollarSign, Clock, Star, AlertCircle,
  Calendar, Share2, Download, TrendingUp, TrendingDown,
  Check, Sparkles, AlertTriangle, ChevronDown, X, Activity, Loader2,
} from 'lucide-react';
import { getEarnings } from '../services/referralService';
import type { EarningsSummary, Earning } from '../types/referral';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell, Legend,
} from 'recharts';
import { cn } from '../layouts/DashboardLayout';

// ── Period-aware mock data ──────────────────────────────────────────────────

type Period = 'Today' | 'This Week' | 'This Month';

const PERIOD_DATA: Record<Period, {
  stats: { patients: S; appts: S; cases: S; earnings: S };
  volumeData: { name: string; current: number; previous: number }[];
  earningsData: { name: string; Online: number; Offline: number; Emergency: number }[];
  growthBadge: string;
}> = {
  'Today': {
    stats: {
      patients: { value: '48',     trend: '6 new today',        positive: true  },
      appts:    { value: '12',     trend: '3 walk-ins',         positive: true  },
      cases:    { value: '9',      trend: '2 pending',          positive: false },
      earnings: { value: '$3,200', trend: '8% vs yesterday',    positive: true  },
    },
    volumeData: [
      { name: '8 am',  current: 4,  previous: 3  },
      { name: '10 am', current: 8,  previous: 6  },
      { name: '12 pm', current: 12, previous: 9  },
      { name: '2 pm',  current: 14, previous: 11 },
      { name: '4 pm',  current: 10, previous: 8  },
      { name: '6 pm',  current: 6,  previous: 7  },
    ],
    earningsData: [
      { name: '8–10am',  Online: 400, Offline: 800,  Emergency: 0   },
      { name: '10–12pm', Online: 600, Offline: 1000, Emergency: 200 },
      { name: '12–2pm',  Online: 500, Offline: 900,  Emergency: 0   },
      { name: '2–4pm',   Online: 700, Offline: 800,  Emergency: 300 },
      { name: '4–6pm',   Online: 300, Offline: 600,  Emergency: 0   },
    ],
    growthBadge: 'Growth +8%',
  },
  'This Week': {
    stats: {
      patients: { value: '312',     trend: '12% from last wk',  positive: true  },
      appts:    { value: '48',      trend: '8 walk-ins',        positive: true  },
      cases:    { value: '86',      trend: '3% drop',           positive: false },
      earnings: { value: '$18,400', trend: '15% increase',      positive: true  },
    },
    volumeData: [
      { name: 'Mon', current: 45, previous: 38 },
      { name: 'Tue', current: 52, previous: 42 },
      { name: 'Wed', current: 48, previous: 45 },
      { name: 'Thu', current: 61, previous: 50 },
      { name: 'Fri', current: 59, previous: 55 },
      { name: 'Sat', current: 35, previous: 30 },
      { name: 'Sun', current: 20, previous: 25 },
    ],
    earningsData: [
      { name: 'Mon', Online: 2000, Offline: 3500, Emergency: 500 },
      { name: 'Tue', Online: 2200, Offline: 3800, Emergency: 300 },
      { name: 'Wed', Online: 1800, Offline: 3200, Emergency: 800 },
      { name: 'Thu', Online: 2500, Offline: 4000, Emergency: 600 },
      { name: 'Fri', Online: 2300, Offline: 3600, Emergency: 400 },
      { name: 'Sat', Online: 1200, Offline: 2000, Emergency: 200 },
      { name: 'Sun', Online: 600,  Offline: 1000, Emergency: 0   },
    ],
    growthBadge: 'Growth +15%',
  },
  'This Month': {
    stats: {
      patients: { value: '1,284',   trend: '12% from last wk',  positive: true  },
      appts:    { value: '342',     trend: '28 walk-ins',       positive: true  },
      cases:    { value: '342',     trend: '3% drop',           positive: false },
      earnings: { value: '$42,500', trend: '18% increase',      positive: true  },
    },
    volumeData: [
      { name: 'Week 1', current: 290, previous: 240 },
      { name: 'Week 2', current: 320, previous: 280 },
      { name: 'Week 3', current: 340, previous: 295 },
      { name: 'Week 4', current: 334, previous: 305 },
    ],
    earningsData: [
      { name: 'Week 1', Online: 8000,  Offline: 14000, Emergency: 2500 },
      { name: 'Week 2', Online: 9000,  Offline: 15000, Emergency: 1800 },
      { name: 'Week 3', Online: 10000, Offline: 16000, Emergency: 3200 },
      { name: 'Week 4', Online: 9500,  Offline: 15500, Emergency: 2800 },
    ],
    growthBadge: 'Growth +12%',
  },
};

interface S { value: string; trend: string; positive: boolean }

const DISEASE_DISTRIBUTION = [
  { name: 'Diabetes',     value: 35 },
  { name: 'Hypertension', value: 25 },
  { name: 'Cardiology',   value: 20 },
  { name: 'General',      value: 15 },
  { name: 'Respiratory',  value: 5  },
];
const PIE_COLORS = ['#3b82f6', '#8b5cf6', '#ec4899', '#10b981', '#f59e0b'];

// ── Sub-components ──────────────────────────────────────────────────────────

const StatCard = ({ title, stat, icon: Icon, color, bg }:
  { title: string; stat: S; icon: React.ElementType; color: string; bg: string }) => (
  <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200/60 hover:shadow-md hover:border-slate-300 transition-all group">
    <div className="flex items-start justify-between mb-3">
      <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">{title}</p>
      <div className={cn('w-9 h-9 rounded-xl flex items-center justify-center shadow-sm', bg, color)}>
        <Icon className="w-4 h-4" />
      </div>
    </div>
    <p className="text-3xl font-black text-slate-800 tracking-tight mb-2">{stat.value}</p>
    <span className={cn(
      'inline-flex items-center gap-1 text-[11px] font-bold px-2 py-0.5 rounded-lg',
      stat.positive ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-600',
    )}>
      {stat.positive ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
      {stat.positive ? '↑' : '↓'} {stat.trend}
    </span>
  </div>
);

// ── Main Page ──────────────────────────────────────────────────────────────

export default function Analytics() {
  const [period, setPeriod] = useState<Period>('This Month');
  const [showCustom, setShowCustom] = useState(false);
  const [customFrom, setCustomFrom] = useState('');
  const [customTo, setCustomTo] = useState('');
  const [shareMsg, setShareMsg] = useState('');
  const [exportMsg, setExportMsg] = useState('');
  const printRef = useRef<HTMLDivElement>(null);

  const data = PERIOD_DATA[period];

  const [earningsData, setEarningsData] = useState<EarningsSummary | null>(null);
  const [earningsLoading, setEarningsLoading] = useState(true);

  useEffect(() => {
    getEarnings().then(setEarningsData).finally(() => setEarningsLoading(false));
  }, []);

  const TYPE_COLOR: Record<string, string> = { lab: 'bg-teal-100 text-teal-700', hospital: 'bg-blue-100 text-blue-700', specialist: 'bg-violet-100 text-violet-700' };

  const handleShare = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setShareMsg('Link copied!');
    } catch {
      setShareMsg('Copied!');
    }
    setTimeout(() => setShareMsg(''), 2500);
  };

  const handleExport = () => {
    setExportMsg('Preparing PDF…');
    setTimeout(() => {
      window.print();
      setExportMsg('');
    }, 500);
  };

  const PERIODS: Period[] = ['Today', 'This Week', 'This Month'];

  return (
    <div ref={printRef} className="max-w-[1600px] mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20 print:p-4">

      {/* ── Header ── */}
      <div className="flex flex-col gap-3 mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl sm:text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Analytics</h1>
            <p className="text-xs sm:text-sm text-slate-500 font-medium mt-0.5">Data-driven insights for your practice</p>
          </div>
          {/* Export + Share - compact on mobile */}
          <div className="flex items-center gap-2 shrink-0">
            <button onClick={handleShare} className="flex items-center gap-1.5 bg-white border border-slate-200 text-slate-700 text-[12px] sm:text-[13px] font-bold px-3 sm:px-4 py-2 sm:py-2.5 rounded-xl hover:bg-slate-50 transition-all shadow-sm">
              {shareMsg ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Share2 className="w-3.5 h-3.5" />}
              <span className="hidden sm:inline">{shareMsg || 'Share'}</span>
            </button>
            <button onClick={handleExport} className="flex items-center gap-1.5 bg-slate-800 hover:bg-slate-700 text-white text-[12px] sm:text-[13px] font-bold px-3 sm:px-4 py-2 sm:py-2.5 rounded-xl transition-all shadow-sm">
              <Download className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">{exportMsg || 'Export PDF'}</span>
            </button>
          </div>
        </div>
        {/* Period tabs - scrollable on mobile */}
        <div className="flex items-center gap-2 overflow-x-auto hide-scrollbar pb-0.5">
          <div className="flex bg-white border border-slate-200 rounded-xl p-1 shadow-sm gap-1 shrink-0">
            {PERIODS.map(p => (
              <button
                key={p}
                onClick={() => { setPeriod(p); setShowCustom(false); }}
                className={cn(
                  'px-3 sm:px-3.5 py-1.5 sm:py-2 rounded-lg text-[12px] sm:text-[13px] font-bold transition-all whitespace-nowrap',
                  period === p && !showCustom ? 'bg-brand-blue text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50',
                )}
              >{p}</button>
            ))}
            <button
              onClick={() => setShowCustom(v => !v)}
              className={cn(
                'flex items-center gap-1.5 px-3 sm:px-3.5 py-1.5 sm:py-2 rounded-lg text-[12px] sm:text-[13px] font-bold transition-all whitespace-nowrap',
                showCustom ? 'bg-brand-blue text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50',
              )}
            >
              <Calendar className="w-3.5 h-3.5" />
              <span className="hidden xs:inline">Custom</span>
              <ChevronDown className={cn('w-3.5 h-3.5 transition-transform', showCustom && 'rotate-180')} />
            </button>
          </div>
        </div>
      </div>

      {/* Custom Range Picker */}
      {showCustom && (
        <div className="mb-6 bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col sm:flex-row items-start sm:items-end gap-4 animate-in slide-in-from-top-2 duration-200">
          <div>
            <label className="block text-xs font-bold text-slate-500 mb-1.5 uppercase tracking-wide">From</label>
            <input
              type="date"
              value={customFrom}
              onChange={e => setCustomFrom(e.target.value)}
              className="border border-slate-200 rounded-xl px-3 py-2.5 text-sm text-slate-700 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none"
            />
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-500 mb-1.5 uppercase tracking-wide">To</label>
            <input
              type="date"
              value={customTo}
              onChange={e => setCustomTo(e.target.value)}
              className="border border-slate-200 rounded-xl px-3 py-2.5 text-sm text-slate-700 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none"
            />
          </div>
          <button
            onClick={() => {
              if (customFrom && customTo) setShowCustom(false);
            }}
            className="flex items-center gap-2 bg-brand-blue text-white text-sm font-bold px-5 py-2.5 rounded-xl hover:bg-blue-700 transition-colors"
          >
            <Check className="w-4 h-4" /> Apply Range
          </button>
          <button onClick={() => setShowCustom(false)} className="text-slate-400 hover:text-slate-600 p-1">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* ── Stat Cards ── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 xl:gap-5 mb-8">
        <StatCard title="Total Patients"    stat={data.stats.patients} icon={Users}        color="text-blue-600"   bg="bg-blue-50"   />
        <StatCard title="Appts Today"       stat={data.stats.appts}    icon={Clock}        color="text-purple-600" bg="bg-purple-50" />
        <StatCard title="Completed Cases"   stat={data.stats.cases}    icon={CheckCircle2} color="text-emerald-600" bg="bg-emerald-50" />
        <StatCard title="Earnings (Month)"  stat={data.stats.earnings} icon={DollarSign}   color="text-amber-600"  bg="bg-amber-50"  />
      </div>

      {/* ── Main grid ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 xl:gap-8 mb-8">

        {/* Left: Charts */}
        <div className="lg:col-span-2 space-y-6">

          {/* Patient Volume Trends */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h3 className="text-base font-black text-slate-800">Patient Volume Trends</h3>
                <p className="text-[13px] text-slate-500 font-medium mt-0.5">Comparing current vs previous period</p>
              </div>
              <span className="bg-blue-50 text-brand-blue border border-blue-100 text-[11px] font-bold px-2.5 py-1 rounded-lg">{data.growthBadge}</span>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={data.volumeData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="gCurrent" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%"  stopColor="#3b82f6" stopOpacity={0.25} />
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}    />
                  </linearGradient>
                  <linearGradient id="gPrev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%"  stopColor="#94a3b8" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#94a3b8" stopOpacity={0}   />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} />
                <Tooltip
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 20px -5px rgba(0,0,0,0.15)', fontSize: 13 }}
                  labelStyle={{ fontWeight: 700, color: '#1e293b' }}
                />
                <Legend iconType="circle" wrapperStyle={{ fontSize: 13, paddingTop: 12 }} />
                <Area type="monotone" name="Current Period" dataKey="current"  stroke="#3b82f6" strokeWidth={2.5} fill="url(#gCurrent)" />
                <Area type="monotone" name="Previous Period" dataKey="previous" stroke="#94a3b8" strokeWidth={2}   strokeDasharray="5 5" fill="url(#gPrev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Revenue Breakdown */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h3 className="text-base font-black text-slate-800">Revenue Breakdown</h3>
                <p className="text-[13px] text-slate-500 font-medium mt-0.5">Earnings across consultation types</p>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={270}>
              <BarChart data={data.earningsData} margin={{ top: 10, right: 0, left: -10, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} tickFormatter={v => `$${v >= 1000 ? (v/1000).toFixed(0)+'k' : v}`} />
                <Tooltip cursor={{ fill: '#f8fafc' }} contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 20px -5px rgba(0,0,0,0.15)', fontSize: 13 }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: 13, paddingTop: 12 }} />
                <Bar dataKey="Offline"   stackId="a" fill="#3b82f6" radius={[0, 0, 4, 4]} />
                <Bar dataKey="Online"    stackId="a" fill="#8b5cf6" />
                <Bar dataKey="Emergency" stackId="a" fill="#f43f5e" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

        </div>

        {/* Right: AI + Extras */}
        <div className="space-y-6">

          {/* AI Practice Insights */}
          <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-800 rounded-2xl p-6 shadow-xl border border-slate-700/50 relative overflow-hidden">
            <div className="absolute -top-16 -right-16 w-48 h-48 bg-brand-blue rounded-full blur-3xl opacity-20 pointer-events-none" />
            <div className="absolute -bottom-16 -left-16 w-48 h-48 bg-purple-600 rounded-full blur-3xl opacity-20 pointer-events-none" />
            <div className="relative z-10">
              <h3 className="flex items-center gap-2 text-base font-black text-white mb-5">
                <Sparkles className="w-5 h-5 text-blue-400" /> AI Practice Insights
              </h3>
              <div className="space-y-3">
                {[
                  {
                    icon: TrendingUp, color: 'bg-blue-500/20', iconColor: 'text-blue-300',
                    title: 'Patient Load Increased',
                    body: <>Your patient load increased by <strong className="text-white">20%</strong> this week. Most cases are related to Diabetes & Hypertension.</>,
                  },
                  {
                    icon: Clock, color: 'bg-purple-500/20', iconColor: 'text-purple-300',
                    title: 'Schedule Optimization',
                    body: <>Spending <strong className="text-white">15% more time</strong> per patient. Add more buffer slots on Mondays to prevent delays.</>,
                    action: { label: 'Adjust Monday Slots', onClick: () => {} },
                  },
                  {
                    icon: AlertTriangle, color: 'bg-amber-500/20', iconColor: 'text-amber-300',
                    title: 'Predictive Alert',
                    body: <>High chance of emergency cases tomorrow due to weather drop. Ensure ER availability.</>,
                  },
                ].map(({ icon: Icon, color, iconColor, title, body, action }: any) => (
                  <div key={title} className="bg-white/8 hover:bg-white/[0.12] backdrop-blur-sm rounded-xl p-4 border border-white/10 transition-colors">
                    <div className="flex gap-3">
                      <div className={cn('p-2 rounded-xl h-fit shrink-0', color)}>
                        <Icon className={cn('w-4 h-4', iconColor)} />
                      </div>
                      <div>
                        <h4 className="text-[13px] font-bold text-slate-100 mb-1">{title}</h4>
                        <p className="text-[12px] text-slate-400 font-medium leading-relaxed">{body}</p>
                        {action && (
                          <button onClick={action.onClick} className="mt-2.5 bg-white/15 hover:bg-white/25 text-white text-[11px] font-bold px-3 py-1.5 rounded-lg transition-colors">
                            {action.label}
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Disease Distribution */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow">
            <h3 className="text-base font-black text-slate-800 mb-0.5">Disease Distribution</h3>
            <p className="text-[13px] text-slate-500 font-medium mb-4">Patient cases breakdown</p>
            <div className="h-[200px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={DISEASE_DISTRIBUTION} cx="50%" cy="50%" innerRadius={55} outerRadius={75} paddingAngle={4} dataKey="value">
                    {DISEASE_DISTRIBUTION.map((_, i) => (
                      <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: '10px', border: 'none', boxShadow: '0 4px 15px rgba(0,0,0,0.1)', fontSize: 13 }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-2.5 mt-1">
              {DISEASE_DISTRIBUTION.map((item, i) => (
                <div key={item.name} className="flex items-center justify-between text-[13px]">
                  <div className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{ backgroundColor: PIE_COLORS[i] }} />
                    <span className="font-semibold text-slate-700">{item.name}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-16 h-1.5 bg-slate-100 rounded-full overflow-hidden">
                      <div className="h-full rounded-full" style={{ width: `${item.value}%`, backgroundColor: PIE_COLORS[i] }} />
                    </div>
                    <span className="font-bold text-slate-500 w-8 text-right">{item.value}%</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Performance Metrics */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow">
            <h3 className="text-base font-black text-slate-800 mb-5">Performance Metrics</h3>
            <div className="space-y-5">
              {[
                { icon: Clock,        bg: 'bg-blue-50',    color: 'text-blue-500',    label: 'Avg. Consult Time',     sub: 'Target < 15 mins',  value: '18m 42s', badge: '+3m slower',     badgeColor: 'text-red-500'     },
                { icon: Star,         bg: 'bg-emerald-50', color: 'text-emerald-500', label: 'Patient Satisfaction',  sub: '241 reviews',       value: '4.9 ★',   badge: 'Top 5% in clinic', badgeColor: 'text-emerald-500' },
                { icon: AlertCircle,  bg: 'bg-red-50',     color: 'text-red-500',     label: 'Emergency Response',    sub: 'Total 12 cases',    value: '< 2 min', badge: 'Optimal',          badgeColor: 'text-emerald-500' },
              ].map(({ icon: Icon, bg, color, label, sub, value, badge, badgeColor }) => (
                <div key={label} className="flex items-center justify-between group">
                  <div className="flex items-center gap-3">
                    <div className={cn('p-2.5 rounded-xl transition-transform group-hover:scale-110', bg, color)}>
                      <Icon className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="text-[13px] font-bold text-slate-800">{label}</p>
                      <p className="text-[11px] text-slate-400 font-medium">{sub}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-[14px] font-black text-slate-800">{value}</p>
                    <p className={cn('text-[10px] font-bold', badgeColor)}>{badge}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>
      </div>

      {/* ── REFERRAL EARNINGS ── */}
      <div className="mt-8">
        <h2 className="text-xl font-black text-slate-800 mb-6">Referral Earnings</h2>
        
        {earningsLoading ? (
          <div className="flex justify-center py-16"><Loader2 className="w-6 h-6 animate-spin text-slate-400" /></div>
        ) : !earningsData ? null : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 xl:gap-8">
            <div className="lg:col-span-2 grid grid-cols-2 gap-4 xl:gap-5 h-fit">
              {[
                { label: 'Total Bookings',     value: earningsData.total_bookings.toString(),         icon: Activity,    color: 'text-blue-600',   bg: 'bg-blue-50' },
                { label: 'Total Revenue',      value: `₹${earningsData.total_revenue.toLocaleString('en-IN')}`, icon: DollarSign,  color: 'text-emerald-600', bg: 'bg-emerald-50' },
                { label: 'Total Commission',   value: `₹${earningsData.total_commission.toLocaleString('en-IN')}`, icon: TrendingUp, color: 'text-indigo-600', bg: 'bg-indigo-50' },
                { label: 'Pending Payout',     value: `₹${earningsData.pending_commission.toLocaleString('en-IN')}`, icon: DollarSign, color: 'text-amber-600', bg: 'bg-amber-50' },
              ].map((s, i) => (
                <div key={i} className="bg-white rounded-2xl border border-slate-200/60 p-5 shadow-sm hover:shadow-md transition-all group">
                  <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center mb-3 shadow-sm', s.bg)}>
                    <s.icon className={cn('w-5 h-5', s.color)} />
                  </div>
                  <p className="text-2xl font-black text-slate-800 tracking-tight">{s.value}</p>
                  <p className="text-[12px] uppercase tracking-widest text-slate-400 font-bold mt-1">{s.label}</p>
                </div>
              ))}
            </div>

            <div className="lg:col-span-1">
              <div className="bg-white rounded-2xl border border-slate-200/60 shadow-sm overflow-hidden h-full flex flex-col">
                <div className="px-5 py-4 border-b border-slate-100 bg-slate-50/50">
                  <p className="text-[14px] font-black text-slate-800">Recent Transactions</p>
                </div>
                {earningsData.recent.length === 0 ? (
                  <div className="flex-1 flex flex-col items-center justify-center p-8 text-center text-slate-400">
                    <div className="w-12 h-12 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center mb-3">
                      <DollarSign className="w-6 h-6 opacity-40" />
                    </div>
                    <p className="font-bold text-[13px] text-slate-500">No earnings yet</p>
                    <p className="text-[11px] mt-0.5">Create referrals to start earning</p>
                  </div>
                ) : (
                  <div className="flex-1 overflow-y-auto max-h-[300px] custom-scrollbar">
                    {earningsData.recent.map((e: Earning) => (
                      <div key={e.id} className="flex items-center gap-3 px-5 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition-colors">
                        <div className={cn('w-9 h-9 rounded-xl flex items-center justify-center shrink-0 text-[11px] font-black', TYPE_COLOR[e.booking_type] ?? 'bg-slate-100 text-slate-600')}>
                          {e.booking_type[0].toUpperCase()}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-[13px] font-black text-slate-800 truncate">{e.patient_name}</p>
                          <p className="text-[11px] font-semibold text-slate-400 truncate">{e.provider_name}</p>
                        </div>
                        <div className="text-right shrink-0">
                          <p className="text-[14px] font-black text-emerald-600">+₹{e.commission_amount.toFixed(0)}</p>
                          <span className={cn('inline-block text-[9px] font-bold px-1.5 py-0.5 rounded-md uppercase tracking-wider mt-0.5', e.status === 'paid' ? 'bg-emerald-50 text-emerald-600' : 'bg-amber-50 text-amber-600')}>
                            {e.status}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>

    </div>
  );
}