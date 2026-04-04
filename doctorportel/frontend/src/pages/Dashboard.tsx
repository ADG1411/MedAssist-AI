import { useState, useEffect } from 'react';
import {
  Users, CalendarCheck, AlertCircle, ActivitySquare, ChevronRight,
  Clock, Sparkles, UserPlus, Pill, Video, FileText, MessageSquare,
  TrendingUp, HeartPulse, Bell, CheckCircle2, Syringe, QrCode,
  X, PhoneOff, Mic, MicOff, Camera, CameraOff,
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { useNavigate } from 'react-router-dom';

/* --- MOCK DATA --- */
const STATS = [
  { label: 'Total Patients', value: '1,284', trend: '+12% this month', isPositive: true, icon: Users, color: 'text-blue-600', bg: 'bg-blue-100', border: 'border-blue-200' },
  { label: 'Appointments Today', value: '14', trend: '4 remaining', isPositive: true, icon: CalendarCheck, color: 'text-emerald-600', bg: 'bg-emerald-100', border: 'border-emerald-200' },
  { label: 'Active Tickets', value: '7', trend: '2 requires attention', isPositive: false, icon: ActivitySquare, color: 'text-purple-600', bg: 'bg-purple-100', border: 'border-purple-200' },
  { label: 'Earnings Today', value: '$840', trend: '+5% vs yesterday', isPositive: true, icon: TrendingUp, color: 'text-amber-600', bg: 'bg-amber-100', border: 'border-amber-200' },
];

const APPOINTMENTS = [
  { id: 1, patientName: 'Rahul Sharma', time: '10:30 AM', status: 'Waiting', type: 'Follow up', img: 'https://ui-avatars.com/api/?name=Rahul+Sharma&background=f87171&color=fff' },
  { id: 2, patientName: 'Emma Watson', time: '11:00 AM', status: 'In Progress', type: 'Checkup', img: 'https://ui-avatars.com/api/?name=Emma+Watson&background=60a5fa&color=fff' },
  { id: 3, patientName: 'Sarah Smith', time: '11:45 AM', status: 'Scheduled', type: 'Consultation', img: 'https://ui-avatars.com/api/?name=Sarah+Smith&background=34d399&color=fff' },
];

const NOTIFICATIONS = [
  { id: 1, title: 'Follow-up missed', desc: 'John Doe did not attend 9:00 AM schedule.', time: '1 hr ago', type: 'warning' },
  { id: 2, title: 'New Lab Report', desc: 'CBC results for Emma Watson are ready.', time: '2 hrs ago', type: 'info' },
  { id: 3, title: 'Message from Dr. Lee', desc: 'Case transfer #893 approved.', time: '4 hrs ago', type: 'success' },
];

// ── Status cycle helper ────────────────────────────────────────────────────
const STATUS_CYCLE: Record<string, string> = {
  'Waiting': 'In Progress',
  'In Progress': 'Completed',
  'Completed': 'Waiting',
  'Scheduled': 'Waiting',
};

// ── Toast (no external library) ────────────────────────────────────────────
interface Toast { id: number; msg: string; type: 'success' | 'info' | 'warning' }
let toastId = 0;

export default function DashboardPage() {
  const navigate = useNavigate();
  const [currentDate, setCurrentDate] = useState('');
  const [appointments, setAppointments] = useState(APPOINTMENTS);
  const [notifications, setNotifications] = useState(NOTIFICATIONS);
  const [showVideoCall, setShowVideoCall] = useState(false);
  const [micOn, setMicOn] = useState(true);
  const [camOn, setCamOn] = useState(true);
  const [toasts, setToasts] = useState<Toast[]>([]);

  const showToast = (msg: string, type: Toast['type'] = 'success') => {
    const id = ++toastId;
    setToasts(t => [...t, { id, msg, type }]);
    setTimeout(() => setToasts(t => t.filter(x => x.id !== id)), 3000);
  };

  const cycleStatus = (id: number) => {
    setAppointments(prev => prev.map(a => {
      if (a.id !== id) return a;
      const next = STATUS_CYCLE[a.status] ?? 'Waiting';
      showToast(`${a.patientName} → ${next}`, 'info');
      return { ...a, status: next };
    }));
  };

  const dismissNotif = (id: number) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  useEffect(() => {
    setCurrentDate(new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).format(new Date()));
  }, []);

  return (
    <div className="w-full animate-in fade-in slide-in-from-bottom-4 duration-500 pb-24 md:pb-8 flex flex-col gap-6 relative">

      {/* Toast stack */}
      <div className="fixed top-4 right-4 z-[999] flex flex-col gap-2 pointer-events-none">
        {toasts.map(t => (
          <div key={t.id} className={cn(
            'px-4 py-2.5 rounded-xl shadow-lg text-sm font-bold text-white animate-in slide-in-from-right-4 duration-300',
            t.type === 'success' ? 'bg-emerald-500' : t.type === 'warning' ? 'bg-amber-500' : 'bg-brand-blue'
          )}>{t.msg}</div>
        ))}
      </div>

      {/* 1. TOP HEADER */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 md:gap-5 bg-white p-5 md:p-8 rounded-[1.5rem] md:rounded-[2rem] shadow-sm border border-slate-200/60">
        <div className="text-center md:text-left">
           <p className="text-brand-blue font-bold text-xs md:text-sm mb-1">{currentDate}</p>
           <h1 className="text-2xl md:text-3xl lg:text-4xl font-black text-slate-800 tracking-tight">
             Good morning, <span className="text-brand-blue">Dr. Smith!</span> 👋
           </h1>
           <p className="text-slate-500 font-medium mt-1 md:mt-2 text-sm md:text-base">Here is your central control hub for today.</p>
        </div>
        <div className="grid grid-cols-2 lg:flex lg:flex-wrap gap-2 md:gap-3 w-full md:w-auto mt-2 md:mt-0">
           <button onClick={() => navigate('/dashboard/patients')} className="bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs md:text-sm font-bold px-3 md:px-4 py-3 md:py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2">
             <UserPlus className="w-4 h-4 md:w-5 md:h-5" /> <span className="hidden sm:inline">Add Patient</span><span className="sm:hidden">Patient</span>
           </button>
           <button onClick={() => navigate('/dashboard/prescription')} className="bg-blue-50 text-brand-blue hover:bg-blue-100 text-xs md:text-sm font-bold px-3 md:px-4 py-3 md:py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2 border border-blue-100">
             <Pill className="w-4 h-4 md:w-5 md:h-5 text-brand-blue" /> <span className="hidden sm:inline">Rx Prescription</span><span className="sm:hidden">Prescription</span>
           </button>
           <button onClick={() => { showToast('Emergency mode activated! 🚨', 'warning'); navigate('/dashboard/emergency'); }} className="col-span-2 lg:col-span-1 bg-red-600 text-white hover:bg-red-700 text-sm font-bold px-3 md:px-4 py-3 md:py-2.5 rounded-xl transition-colors shadow-lg shadow-red-500/20 flex items-center justify-center gap-2">
             🚨 Emergency Mode
           </button>
        </div>
      </div>

      {/* 2. AI ASSISTANT PANEL */}
      <div className="bg-gradient-to-r from-indigo-900 via-purple-900 to-indigo-900 rounded-[1.5rem] p-6 shadow-md text-white relative overflow-hidden flex flex-col md:flex-row items-center gap-6">
         <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>
         <div className="absolute -right-10 -top-10 w-40 h-40 bg-purple-500 rounded-full blur-[80px] opacity-50"></div>

         <div className="shrink-0 bg-white/10 p-4 rounded-2xl border border-white/20 backdrop-blur-md relative z-10 w-full md:w-auto text-center md:text-left">
            <div className="flex items-center justify-center md:justify-start gap-2 text-purple-200 font-bold mb-2 uppercase text-xs tracking-widest">
               <Sparkles className="w-4 h-4 text-purple-400" /> Smart Daily Brief
            </div>
            <p className="text-2xl font-black">You have <span className="text-red-400">1</span> critical case today.</p>
         </div>

         <div className="flex-1 relative z-10 w-full">
            <div className="flex flex-col sm:flex-row gap-3">
               <div className="flex-1 bg-black/20 rounded-xl p-3 border border-white/10 flex items-center gap-3">
                  <div className="bg-red-500/20 text-red-400 p-2 rounded-lg"><HeartPulse className="w-5 h-5"/></div>
                  <div>
                    <p className="text-sm font-bold text-white">Rahul Sharma (10:30 AM)</p>
                    <p className="text-xs text-slate-300">Requires severe hypertension check.</p>
                  </div>
               </div>
               <div className="flex-1 bg-black/20 rounded-xl p-3 border border-white/10 flex items-center gap-3">
                  <div className="bg-emerald-500/20 text-emerald-400 p-2 rounded-lg"><CheckCircle2 className="w-5 h-5"/></div>
                  <div>
                    <p className="text-sm font-bold text-white">2 Follow-ups Pending</p>
                    <p className="text-xs text-slate-300">Review lab results from yesterday.</p>
                  </div>
               </div>
            </div>
         </div>

         <div className="relative z-10 w-full md:w-auto shrink-0 flex flex-col gap-2">
            <button onClick={() => { showToast('Starting consultation with Rahul Sharma…', 'info'); navigate('/dashboard/schedule'); }} className="w-full bg-white text-indigo-900 border border-white hover:bg-slate-100 font-bold px-6 py-3 rounded-xl transition-all shadow-lg flex items-center justify-center gap-2">
              Start Next Appointment <ChevronRight className="w-4 h-4" />
            </button>
         </div>
      </div>

      {/* 3. QUICK STATS CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6">
        {STATS.map((stat) => (
          <div key={stat.label} className={cn("bg-white rounded-2xl p-5 shadow-sm border transition-all hover:shadow-md", stat.border)}>
            <div className="flex justify-between items-start mb-4">
               <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center", stat.bg, stat.color)}>
                 <stat.icon className="h-6 w-6" />
               </div>
               <span className={cn("text-[10px] font-bold px-2 py-1 rounded bg-slate-50 border border-slate-100 text-slate-500")}>Today</span>
            </div>
            <h3 className="text-3xl font-black text-slate-800 tracking-tight">{stat.value}</h3>
            <p className="text-slate-500 text-xs font-bold uppercase tracking-wider mb-2 mt-1">{stat.label}</p>
            <p className={cn("text-xs font-semibold flex items-center gap-1", stat.isPositive ? "text-emerald-600" : "text-amber-600")}>
              {stat.isPositive ? <TrendingUp className="w-3 h-3" /> : <AlertCircle className="w-3 h-3" />}
              {stat.trend}
            </p>
          </div>
        ))}
      </div>

      {/* 5. QUICK ACCESS SHORTCUTS (Moved up for better UX) */}
      <div className="bg-white rounded-[1.5rem] p-3 shadow-sm border border-slate-200/60 overflow-x-auto hide-scrollbar touch-pan-x">
         <div className="flex gap-2 min-w-max pb-1 md:pb-0">
            <button onClick={() => navigate('/dashboard/patients')} className="flex items-center gap-2 px-4 py-2.5 md:py-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-xl text-xs md:text-sm font-bold transition-colors border border-slate-100 shrink-0">
               <UserPlus className="w-4 h-4 text-brand-blue" /> Add Patient
            </button>
            <button onClick={() => navigate('/dashboard/prescription')} className="flex items-center gap-2 px-4 py-2.5 md:py-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-xl text-xs md:text-sm font-bold transition-colors border border-slate-100 shrink-0">
               <Pill className="w-4 h-4 text-purple-500" /> Write Prescription
            </button>
            <button onClick={() => { setShowVideoCall(true); showToast('Starting video consultation…', 'info'); }} className="flex items-center gap-2 px-4 py-2.5 md:py-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-xl text-xs md:text-sm font-bold transition-colors border border-slate-100 shrink-0">
               <Video className="w-4 h-4 text-emerald-500" /> Start Video
            </button>
            <button onClick={() => navigate('/dashboard/analytics')} className="flex items-center gap-2 px-4 py-2.5 md:py-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-xl text-xs md:text-sm font-bold transition-colors border border-slate-100 shrink-0">
               <FileText className="w-4 h-4 text-amber-500" /> View Reports
            </button>
            <button onClick={() => navigate('/dashboard/ai')} className="flex items-center gap-2 px-4 py-2.5 md:py-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-xl text-xs md:text-sm font-bold transition-colors border border-slate-100 shrink-0">
               <MessageSquare className="w-4 h-4 text-blue-500" /> Open Chat
            </button>
         </div>
      </div>

      {/* 4. MAIN SECTIONS GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        
        {/* Left Col (Appts & Patients & Prescription) */}
        <div className="col-span-1 lg:col-span-2 space-y-6">
           
           {/* NEXT ACTION SYSTEM */}
           <div className="bg-brand-blue/5 border border-brand-blue/20 rounded-2xl p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-sm">
              <div className="flex items-center gap-3 sm:gap-4">
                 <div className="bg-brand-blue text-white w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center rounded-xl shadow-sm text-lg sm:text-xl font-black shrink-0">
                    👉
                 </div>
                 <div>
                    <span className="text-[10px] sm:text-xs font-bold text-brand-blue uppercase tracking-widest block mb-0.5">Next Action</span>
                    <h3 className="text-[14px] sm:text-[16px] font-black text-slate-800 line-clamp-1">Next patient: Rahul (10:30)</h3>
                 </div>
              </div>
              <button onClick={() => { setShowVideoCall(true); showToast('Video consultation started!', 'success'); }} className="w-full sm:w-auto bg-brand-blue hover:bg-blue-700 text-white text-sm font-bold px-5 py-3 sm:py-2.5 flex items-center justify-center gap-2 rounded-xl transition-transform active:scale-95 shadow-lg shadow-brand-blue/20 shrink-0">
                 Start Consultation <Video className="w-4 h-4" />
              </button>
           </div>

           {/* Today's Appointments */}
           <div className="bg-white rounded-3xl p-6 shadow-sm border border-slate-200/60 relative overflow-hidden">
              <div className="flex justify-between items-center mb-5">
                <h3 className="text-lg font-black text-slate-800 flex items-center gap-2">
                   <CalendarCheck className="w-5 h-5 text-brand-blue" /> Today's Pipeline
                </h3>
                <button onClick={() => navigate('/dashboard/schedule')} className="text-brand-blue text-sm font-bold bg-blue-50 px-3 py-1.5 rounded-lg hover:bg-blue-100 transition-colors">
                  View All
                </button>
              </div>
              <div className="space-y-3">
                 {appointments.map((apt) => (
                    <div key={apt.id} onClick={() => navigate('/dashboard/patients')} className="group flex flex-col sm:flex-row items-start sm:items-center justify-between p-3.5 rounded-2xl border border-slate-100 hover:border-brand-blue/30 hover:bg-slate-50 transition-all cursor-pointer gap-3 sm:gap-0">
                      <div className="flex items-center gap-3 md:gap-4">
                        <img src={apt.img} alt={apt.patientName} className="w-10 h-10 md:w-12 md:h-12 rounded-xl object-cover border-2 border-white shadow-sm shrink-0" />
                        <div>
                          <h4 className="font-bold text-[14px] md:text-[15px] text-slate-800 line-clamp-1">{apt.patientName}</h4>
                          <p className="text-[11px] md:text-[12px] text-slate-500 font-medium mt-0.5 flex flex-wrap items-center gap-1.5 line-clamp-1">
                            <Clock className="w-3.5 h-3.5 shrink-0" /> {apt.time} • {apt.type}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center justify-between sm:justify-end gap-3 w-full sm:w-auto mt-2 sm:mt-0 pt-2 sm:pt-0 border-t border-slate-100 sm:border-0">
                        <button
                          onClick={e => { e.stopPropagation(); cycleStatus(apt.id); }}
                          title="Click to advance status"
                          className={cn(
                            'px-3 py-1.5 sm:py-1 rounded-lg text-xs font-bold border transition-colors hover:opacity-80 cursor-pointer flex-1 sm:flex-none text-center',
                            apt.status === 'Waiting'     ? 'bg-amber-50 text-amber-600 border-amber-200' :
                            apt.status === 'In Progress' ? 'bg-blue-50 text-blue-600 border-blue-200' :
                            apt.status === 'Completed'   ? 'bg-emerald-50 text-emerald-600 border-emerald-200' :
                            'bg-slate-100 text-slate-600 border-slate-200'
                          )}
                        >
                          {apt.status}
                        </button>
                        <div className="w-8 h-8 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-400 group-hover:bg-brand-blue group-hover:text-white group-hover:border-brand-blue transition-colors shrink-0">
                           <ChevronRight className="w-4 h-4" />
                        </div>
                      </div>
                    </div>
                 ))}
              </div>
           </div>

           {/* Double Grid for smaller sections */}
           <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              
              {/* Prescription Shortcut */}
              <div onClick={() => { navigate('/dashboard/prescription'); }} className="bg-gradient-to-br from-purple-50 to-indigo-50 border border-purple-100/60 p-6 rounded-[1.5rem] shadow-sm cursor-pointer group hover:-translate-y-1 transition-all">
                 <div className="w-12 h-12 bg-white rounded-xl shadow-sm text-purple-600 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <Syringe className="w-6 h-6" />
                 </div>
                 <h3 className="text-lg font-black text-slate-800 mb-1">Smart Prescription</h3>
                 <p className="text-sm font-medium text-slate-500">Write, estimate cost, and generate Rx instantly.</p>
                 <div className="mt-4 flex items-center text-sm font-bold text-purple-600 group-hover:text-purple-700">
                    Open Writer <ChevronRight className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
                 </div>
              </div>

              {/* Patient Record Scanner */}
              <div onClick={() => navigate('/dashboard/patients')} className="bg-white border border-slate-200/60 p-6 rounded-[1.5rem] shadow-sm cursor-pointer group hover:-translate-y-1 hover:border-brand-blue/30 transition-all">
                 <div className="w-12 h-12 bg-slate-50 border border-slate-100 rounded-xl shadow-sm text-slate-700 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform group-hover:bg-brand-blue group-hover:text-white">
                    <QrCode className="w-6 h-6" />
                 </div>
                 <h3 className="text-lg font-black text-slate-800 mb-1">Patient MedCards</h3>
                 <p className="text-sm font-medium text-slate-500">Scan QR or search directory for history.</p>
                 <div className="mt-4 flex items-center text-sm font-bold text-brand-blue">
                    Scan / Search <ChevronRight className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
                 </div>
              </div>

           </div>
        </div>

        {/* Right Col (Alerts, Analytics, Notifications) */}
        <div className="space-y-6">
           
           {/* Emergency Alerts */}
           <div className="bg-white rounded-3xl p-5 shadow-sm border border-red-100 relative overflow-hidden group cursor-pointer" onClick={() => navigate('/dashboard/emergency')}>
              <div className="absolute top-0 left-0 w-1 h-full bg-red-500"></div>
              <div className="flex items-start justify-between">
                 <div className="flex gap-3">
                    <div className="mt-0.5 animate-pulse text-red-500"><AlertCircle className="w-5 h-5"/></div>
                    <div>
                       <h4 className="font-black text-red-600 flex items-center gap-2">Emergency Cases <span className="bg-red-600 text-white text-[10px] px-1.5 py-0.5 rounded">1</span></h4>
                       <p className="text-xs font-bold text-slate-600 mt-1">Michael J. (Chest Pain)</p>
                    </div>
                 </div>
                 <ChevronRight className="w-5 h-5 text-red-300 group-hover:text-red-500 transition-colors" />
              </div>
           </div>

           {/* Active Tickets Recap */}
           <div className="bg-white rounded-3xl p-6 shadow-sm border border-slate-200/60">
              <h3 className="text-[15px] font-black text-slate-800 mb-4 flex items-center gap-2"><ActivitySquare className="w-4 h-4 text-purple-500"/> Active Ticket Resume</h3>
              <div className="space-y-3">
                 <div className="p-3 bg-slate-50 border border-slate-100 rounded-xl flex justify-between items-center group">
                    <p className="text-sm border-l-2 border-brand-blue pl-2 font-bold text-slate-700 group-hover:text-brand-blue transition-colors">Case #892 - Emma Watson</p>
                    <button onClick={() => { showToast('Resuming Case #892 - Emma Watson', 'info'); navigate('/dashboard/patients'); }} className="text-xs bg-white border border-slate-200 px-2 py-1 rounded shadow-sm font-bold text-slate-600 hover:bg-brand-blue hover:text-white hover:border-brand-blue transition-colors">Resume</button>
                 </div>
                 <div className="p-3 bg-slate-50 border border-slate-100 rounded-xl flex justify-between items-center group">
                    <p className="text-sm border-l-2 border-slate-300 pl-2 font-bold text-slate-700">Case #891 - Review Lab</p>
                    <button onClick={() => { showToast('Opening lab report…', 'info'); navigate('/dashboard/analytics'); }} className="text-xs bg-white border border-slate-200 px-2 py-1 rounded shadow-sm font-bold text-slate-600 hover:bg-slate-100 transition-colors">View</button>
                 </div>
              </div>
           </div>

           {/* Mini Analytics */}
           <div className="bg-white rounded-3xl p-6 shadow-sm border border-slate-200/60 cursor-pointer" onClick={() => navigate('/dashboard/analytics')}>
              <div className="flex justify-between items-center mb-4">
                 <h3 className="text-[15px] font-black text-slate-800 flex items-center gap-2"><TrendingUp className="w-4 h-4 text-emerald-500"/> Daily Performance</h3>
                 <button onClick={(e) => { e.stopPropagation(); navigate('/dashboard/analytics'); }} className="text-[10px] text-brand-blue bg-blue-50 px-2 py-1 rounded font-bold uppercase hover:bg-blue-100 transition-colors">View Full</button>
              </div>
              <div className="h-24 bg-gradient-to-t from-emerald-50 to-white rounded-xl border border-emerald-100 flex items-end px-4 pb-2 gap-2">
                 {/* Mock Chart Bars */}
                 {[40, 70, 30, 90, 50, 80, 60].map((h, i) => (
                    <div key={i} className="flex-1 bg-emerald-400 rounded-t-sm" style={{ height: `${h}%`, opacity: 0.5 + (h / 200) }}></div>
                 ))}
              </div>
           </div>

           {/* 6. Notifications Panel */}
           <div className="bg-white rounded-3xl p-6 shadow-sm border border-slate-200/60">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[15px] font-black text-slate-800 flex items-center gap-2"><Bell className="w-4 h-4 text-slate-400"/> Notifications</h3>
                {notifications.length > 0 && (
                  <button onClick={() => setNotifications([])} className="text-[11px] text-slate-400 hover:text-red-500 font-bold transition-colors">Clear all</button>
                )}
              </div>
              {notifications.length === 0 ? (
                <p className="text-sm text-slate-400 font-medium text-center py-4">No new notifications 🎉</p>
              ) : (
                <div className="space-y-3">
                  {notifications.map((notif) => (
                    <div key={notif.id} className="flex gap-3 group relative pr-6">
                       <div className={cn("w-2 h-2 rounded-full mt-1.5 shrink-0",
                          notif.type === 'warning' ? 'bg-amber-400' :
                          notif.type === 'success' ? 'bg-emerald-400' : 'bg-brand-blue')} />
                       <div className="flex-1 min-w-0">
                          <p className="text-sm font-bold text-slate-800">{notif.title}</p>
                          <p className="text-xs text-slate-500 mt-0.5">{notif.desc}</p>
                          <p className="text-[10px] font-bold text-slate-400 mt-1 uppercase">{notif.time}</p>
                       </div>
                       <button
                         onClick={() => dismissNotif(notif.id)}
                         className="absolute right-0 top-0 md:opacity-0 md:group-hover:opacity-100 p-2 md:p-0.5 text-slate-400 hover:text-red-500 transition-all rounded-full hover:bg-red-50"
                       >
                         <X className="w-4 h-4 md:w-3.5 md:h-3.5" />
                       </button>
                    </div>
                  ))}
                </div>
              )}
           </div>

        </div>

      </div>

      {/* ── Video Call Modal ── */}
      {showVideoCall && (
        <div className="fixed inset-0 z-[200] bg-black/90 flex flex-col items-center justify-center gap-6 px-4">
          <div className="absolute top-4 left-1/2 -translate-x-1/2 bg-white/10 text-white text-sm font-bold px-4 py-2 rounded-full backdrop-blur-sm">
            🔴 Live — Rahul Sharma (10:30 AM)
          </div>
          <div className="relative w-full max-w-2xl aspect-video bg-slate-900 rounded-3xl overflow-hidden border border-white/10 shadow-2xl flex items-center justify-center">
            <div className="text-center">
              <img src="https://ui-avatars.com/api/?name=Rahul+Sharma&background=f87171&color=fff&size=128" className="w-24 h-24 rounded-full mx-auto mb-3 ring-4 ring-white/20" alt="patient" />
              <p className="text-white font-bold text-lg">Rahul Sharma</p>
              <p className="text-slate-400 text-sm mt-1">Connecting video…</p>
            </div>
            <div className="absolute bottom-3 right-3 w-28 h-20 bg-slate-800 rounded-xl border border-white/20 flex items-center justify-center text-slate-500 text-xs">
              {camOn ? 'Your camera' : <CameraOff className="w-5 h-5" />}
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button onClick={() => setMicOn(m => !m)} className={cn('w-12 h-12 rounded-full flex items-center justify-center transition-colors', micOn ? 'bg-white/10 text-white hover:bg-white/20' : 'bg-red-500 text-white')}>
              {micOn ? <Mic className="w-5 h-5" /> : <MicOff className="w-5 h-5" />}
            </button>
            <button onClick={() => setCamOn(c => !c)} className={cn('w-12 h-12 rounded-full flex items-center justify-center transition-colors', camOn ? 'bg-white/10 text-white hover:bg-white/20' : 'bg-red-500 text-white')}>
              {camOn ? <Camera className="w-5 h-5" /> : <CameraOff className="w-5 h-5" />}
            </button>
            <button onClick={() => { setShowVideoCall(false); showToast('Call ended', 'warning'); }} className="w-14 h-14 rounded-full bg-red-600 hover:bg-red-700 text-white flex items-center justify-center shadow-lg transition-colors">
              <PhoneOff className="w-6 h-6" />
            </button>
          </div>
          <p className="text-slate-400 text-xs">Mic • Camera • End Call — Click status badges to update appointments</p>
        </div>
      )}
    </div>
  );
}