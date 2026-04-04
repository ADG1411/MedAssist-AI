import { useState, useRef, useEffect } from 'react';
import {
  Users, CheckCircle2, DollarSign, Clock, Star, AlertCircle,
  Calendar, Share2, Download, TrendingUp, TrendingDown,
  Check, Sparkles, AlertTriangle, ChevronDown, X, Activity, Loader2, Bot, Play
} from 'lucide-react';
import { motion } from 'framer-motion';
import { getEarnings } from '../services/referralService';
import type { EarningsSummary, Earning } from '../types/referral';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell, Legend,
} from 'recharts';
import { cn } from '../layouts/DashboardLayout';
import { getAnalyticsSummary, getPatientGrowth, getRevenueBreakdown, getAIInsights } from '../services/analyticsService';
import type { AnalyticsSummary, VolumeData, RevenueData, AIInsight } from '../services/analyticsService';

type Period = 'Today' | 'This Week' | 'This Month';

interface S { value: string | number; trend: string; positive: boolean }

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

  // Backend Data States
  const [summaryData, setSummaryData] = useState<AnalyticsSummary | null>(null);
  const [volumeData, setVolumeData] = useState<VolumeData[]>([]);
  const [growthBadge, setGrowthBadge] = useState('');
  const [revenueData, setRevenueData] = useState<RevenueData[]>([]);
  const [insightsData, setInsightsData] = useState<AIInsight[]>([]);
  const [chartsLoading, setChartsLoading] = useState(true);
  const [aiState, setAiState] = useState<'idle' | 'loading' | 'loaded'>('idle');

  const [earningsData, setEarningsData] = useState<EarningsSummary | null>(null);
  const [earningsLoading, setEarningsLoading] = useState(true);

  // Initial data load
  useEffect(() => {
    getEarnings().then(setEarningsData).finally(() => setEarningsLoading(false));

    // Load default period
    Promise.all([
      getAnalyticsSummary(period),
      getPatientGrowth(period),
      getRevenueBreakdown(period),
    ])
    .then(([sumStr, growthData, revData]) => {
      setSummaryData(sumStr);
      setVolumeData(growthData as any);
      setGrowthBadge(period === 'Today' ? 'Growth +8%' : period === 'This Week' ? 'Growth +15%' : 'Growth +12%');
      setRevenueData(revData as any);
    })
    .catch(err => {
      console.error('Analytics fetch error:', err);
      setSummaryData({
        total_patients: { value: '0', trend: '0%', is_positive: true },
        appointments_today: { value: '0', trend: '0%', is_positive: true },
        completed_cases: { value: '0', trend: '0%', is_positive: true },
        monthly_earnings: { value: '$0', trend: '0%', is_positive: true }
      });
    })
    .finally(() => setChartsLoading(false));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // When period changes (after initial load), update data WITHOUT showing loading spinner
  // This keeps charts mounted so Recharts animates the data transition smoothly
  useEffect(() => {
    if (chartsLoading) return; // Skip if still on initial load

    Promise.all([
      getAnalyticsSummary(period),
      getPatientGrowth(period),
      getRevenueBreakdown(period),
    ])
    .then(([sumStr, growthData, revData]) => {
      setSummaryData(sumStr);
      setVolumeData(growthData as any);
      setGrowthBadge(period === 'Today' ? 'Growth +8%' : period === 'This Week' ? 'Growth +15%' : 'Growth +12%');
      setRevenueData(revData as any);
    })
    .catch(err => console.error('Analytics period switch error:', err));

    // Reset AI state when period changes
    setAiState('idle');
    setInsightsData([]);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [period]);

  const handleGenerateAI = async () => {
    setAiState('loading');
    try {
      const data = await getAIInsights(period);
      setInsightsData(data);
      setAiState('loaded');
    } catch {
      setInsightsData([{
        type: 'error' as const,
        title: 'Connection Issue',
        description: 'Could not reach the AI service. Please ensure the backend is running and try again.',
        action: null,
      }]);
      setAiState('loaded');
    }
  };

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
    <div ref={printRef} className="w-full animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20 print:p-4">

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
      {chartsLoading || !summaryData ? (
        <div className="flex justify-center py-10"><Loader2 className="w-8 h-8 animate-spin text-brand-blue" /></div>
      ) : (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 xl:gap-5 mb-8">
          <StatCard title="Total Patients"    stat={{ value: summaryData.total_patients.value, trend: summaryData.total_patients.trend, positive: summaryData.total_patients.is_positive }} icon={Users}        color="text-blue-600"   bg="bg-blue-50"   />
          <StatCard title="Appts Today"       stat={{ value: summaryData.appointments_today.value, trend: summaryData.appointments_today.trend, positive: summaryData.appointments_today.is_positive }}    icon={Clock}        color="text-purple-600" bg="bg-purple-50" />
          <StatCard title="Completed Cases"   stat={{ value: summaryData.completed_cases.value, trend: summaryData.completed_cases.trend, positive: summaryData.completed_cases.is_positive }}    icon={CheckCircle2} color="text-emerald-600" bg="bg-emerald-50" />
          <StatCard title="Earnings (Month)"  stat={{ value: typeof summaryData.monthly_earnings.value === 'number' ? `$${summaryData.monthly_earnings.value.toLocaleString()}` : summaryData.monthly_earnings.value, trend: summaryData.monthly_earnings.trend, positive: summaryData.monthly_earnings.is_positive }} icon={DollarSign}   color="text-amber-600"  bg="bg-amber-50"  />
        </div>
      )}

      {/* ── Main grid ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 xl:gap-8 mb-8 items-start">

        {/* Left: Charts */}
        <div className="lg:col-span-2 space-y-6">

          {/* Patient Volume Trends */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow min-h-[350px]">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h3 className="text-base font-black text-slate-800">Patient Volume Trends</h3>
                <p className="text-[13px] text-slate-500 font-medium mt-0.5">Comparing current vs previous period</p>
              </div>
              {!chartsLoading && <span className="bg-blue-50 text-brand-blue border border-blue-100 text-[11px] font-bold px-2.5 py-1 rounded-lg">{growthBadge}</span>}
            </div>
            
            {chartsLoading ? (
               <div className="flex justify-center items-center h-[300px]"><Loader2 className="w-8 h-8 animate-spin text-slate-300" /></div>
            ) : (
                  <div className="h-[300px] w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={volumeData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
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
                      <Area type="natural" name="Current Period" dataKey="current"  stroke="#3b82f6" strokeWidth={3} fill="url(#gCurrent)" animationDuration={600} />
                      <Area type="natural" name="Previous Period" dataKey="previous" stroke="#94a3b8" strokeWidth={2.5} strokeDasharray="5 5" fill="url(#gPrev)" animationDuration={600} />
                    </AreaChart>
                  </ResponsiveContainer>
                  </div>
            )}
          </div>

          {/* Revenue Breakdown */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200/60 hover:shadow-md transition-shadow min-h-[350px]">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h3 className="text-base font-black text-slate-800">Revenue Breakdown</h3>
                <p className="text-[13px] text-slate-500 font-medium mt-0.5">Earnings across consultation types</p>
              </div>
            </div>
            
            {chartsLoading ? (
               <div className="flex justify-center items-center h-[270px]"><Loader2 className="w-8 h-8 animate-spin text-slate-300" /></div>
            ) : (
                  <div className="h-[270px] w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={revenueData} margin={{ top: 10, right: 0, left: -10, bottom: 0 }}>
                      <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                      <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} dy={10} />
                      <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12 }} tickFormatter={v => `$${v >= 1000 ? (v/1000).toFixed(0)+'k' : v}`} />
                      <Tooltip cursor={{ fill: '#f8fafc' }} contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 20px -5px rgba(0,0,0,0.15)', fontSize: 13 }} />
                      <Legend iconType="circle" wrapperStyle={{ fontSize: 13, paddingTop: 12 }} />
                      <Bar dataKey="Offline"   stackId="a" fill="#3b82f6" radius={[0, 0, 4, 4]} animationDuration={600} />
                      <Bar dataKey="Online"    stackId="a" fill="#8b5cf6" animationDuration={600} />
                      <Bar dataKey="Emergency" stackId="a" fill="#f43f5e" radius={[4, 4, 0, 0]} animationDuration={600} />
                    </BarChart>
                  </ResponsiveContainer>
                  </div>
            )}
          </div>

        </div>

        {/* Right: AI + Extras */}
        <div className="space-y-6 lg:sticky lg:top-4">

          {/* AI Practice Insights */}
          <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-800 rounded-2xl p-5 sm:p-6 shadow-xl border border-slate-700/50 relative overflow-hidden min-h-[340px] flex flex-col">
            <div className="absolute -top-16 -right-16 w-48 h-48 bg-brand-blue rounded-full blur-3xl opacity-20 pointer-events-none" />
            <div className="absolute -bottom-16 -left-16 w-48 h-48 bg-purple-600 rounded-full blur-3xl opacity-20 pointer-events-none" />
            <div className="relative z-10 flex flex-col h-full flex-1">
              <h3 className="flex items-center gap-2 text-base font-black text-white mb-5">
                <Sparkles className="w-5 h-5 text-blue-400" /> AI Practice Insights
              </h3>
              
              {aiState === 'idle' ? (
                <div className="flex flex-col items-center justify-center py-4 flex-1 text-center">
                   <div className="w-14 h-14 bg-blue-500/10 rounded-2xl flex items-center justify-center mb-4 border border-blue-400/20 shadow-[0_0_20px_rgba(59,130,246,0.1)]">
                     <Bot className="w-7 h-7 text-blue-400" />
                   </div>
                   <h4 className="text-[15px] font-bold text-white mb-2">Ready to Analyze</h4>
                   <p className="text-[12px] text-slate-300 font-medium px-4 mb-6 leading-relaxed">
                     Generate dynamic AI insights or a 5-day flow report based on your {period.toLowerCase()} records.
                   </p>
                   
                   <div className="w-full space-y-2">
                     <button onClick={handleGenerateAI} className="w-full relative group bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white text-[13px] font-bold py-3 rounded-xl shadow-lg shadow-blue-900/20 transition-all flex items-center justify-center gap-2 overflow-hidden">
                       <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />
                       <Sparkles className="w-4 h-4" /> Generate {period} Report
                     </button>
                     <button onClick={handleGenerateAI} className="w-full bg-white/5 hover:bg-white/10 text-slate-200 border border-white/10 text-[12px] font-bold py-2.5 rounded-xl transition-all flex items-center justify-center gap-2">
                       <Play className="w-3.5 h-3.5 text-slate-400" /> Analyze Patient Demographics
                     </button>
                   </div>
                </div>
              ) : aiState === 'loading' ? (
                <div className="flex flex-col items-center justify-center py-6 flex-1 min-h-[200px]">
                   <Loader2 className="w-8 h-8 animate-spin text-blue-400 mb-3" />
                   <p className="text-[13px] text-slate-300 font-medium text-center">AI is analyzing your {period.toLowerCase()} layout...</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {insightsData.map((item, idx) => {
                    const iconMap: Record<string, any> = { 'trend': TrendingUp, 'schedule': Clock, 'alert': AlertTriangle, 'error': AlertCircle };
                    const colorMap: Record<string, any> = { 'trend': 'bg-blue-500/20', 'schedule': 'bg-purple-500/20', 'alert': 'bg-amber-500/20', 'error': 'bg-red-500/20' };
                    const iconColorMap: Record<string, any> = { 'trend': 'text-blue-300', 'schedule': 'text-purple-300', 'alert': 'text-amber-300', 'error': 'text-red-300' };

                    const Icon = iconMap[item.type] || Sparkles;
                    const color = colorMap[item.type] || 'bg-slate-500/20';
                    const iconColor = iconColorMap[item.type] || 'text-slate-300';

                    return (
                      <motion.div 
                        key={idx} 
                        initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: idx * 0.1 }}
                        className="bg-white/8 hover:bg-white/[0.12] backdrop-blur-sm rounded-xl p-4 border border-white/10 transition-colors"
                      >
                        <div className="flex gap-3">
                          <div className={cn('p-2 rounded-xl h-fit shrink-0', color)}>
                            <Icon className={cn('w-4 h-4', iconColor)} />
                          </div>
                          <div>
                            <h4 className="text-[13px] font-bold text-slate-100 mb-1">{item.title}</h4>
                            <p className="text-[12px] text-slate-400 font-medium leading-relaxed">{item.description}</p>
                            {item.action && (
                              <button 
                                onClick={(e) => {
                                  e.currentTarget.innerText = "Task Queued!";
                                  e.currentTarget.classList.add("bg-emerald-500/80", "text-white");
                                  setTimeout(() => {
                                    if(e.currentTarget) {
                                      e.currentTarget.innerText = item.action as string;
                                      e.currentTarget.classList.remove("bg-emerald-500/80");
                                    }
                                  }, 2000);
                                }}
                                className="mt-2.5 bg-white/15 hover:bg-white/25 text-white text-[11px] font-bold px-3 py-1.5 rounded-lg transition-colors"
                              >
                                {item.action}
                              </button>
                            )}
                          </div>
                        </div>
                      </motion.div>
                    );
                  })}
                </div>
              )}
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