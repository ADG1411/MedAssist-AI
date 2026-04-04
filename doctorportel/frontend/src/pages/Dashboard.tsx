import { useState, useEffect } from 'react';
import {
  Users, CalendarCheck, AlertCircle, ActivitySquare, ChevronRight,
  Clock, Pill, TrendingUp, Hand,
  ChevronDown, ArrowUpRight
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { useNavigate } from 'react-router-dom';
import { getProfile } from '../services/doctorProfileService';
import type { DoctorProfile } from '../services/doctorProfileService';

/* --- MOCK DATA --- */
const STATS = [
  { label: 'Total Patients', value: '1,284', trend: '+12% this month', icon: Users, color: 'text-[#10b981]', bg: 'bg-[#ecfdf5]' },
  { label: 'Appointments Today', value: '14', trend: '+2 today', icon: CalendarCheck, color: 'text-[#10b981]', bg: 'bg-[#ecfdf5]' },
  { label: 'Active Tickets', value: '7', trend: '2 urgent cases', icon: ActivitySquare, color: 'text-[#8b5cf6]', bg: 'bg-[#f3e8ff]' },
  { label: 'Earnings Today', value: '$840', trend: '+8% vs yesterday', icon: TrendingUp, color: 'text-[#f59e0b]', bg: 'bg-[#fef3c7]' },
];

const APPOINTMENTS = [
  { id: 1, patientName: 'Rahul Kumar', time: '10:30 AM - 11:30 AM', status: 'Waiting', type: 'waiting', iconColor: 'bg-red-400', initials: 'R' },
  { id: 2, patientName: 'Emma Watson', time: '11:00 AM - 11:01 PM', status: 'In Progress', type: 'progress', iconColor: 'bg-teal-400', initials: 'S' },
  { id: 3, patientName: 'Sarah Smith', time: '11:45 AM - 11:05 PM', status: 'Scheduled', type: 'scheduled', iconColor: 'bg-teal-400', initials: 'S' },
];

const TICKETS = [
  { id: '#015', name: 'Emma Watson', status: 'Pending' },
  { id: '#013', name: 'Kevin Lee', status: 'New' },
];

const NOTIFICATIONS = [
  { id: 1, title: 'Follow-up missed', desc: 'Case #012. Action set on Emma Watson', time: '2:21 AM', color: 'bg-blue-500' },
  { id: 2, title: 'New Lab Report', desc: 'Message from Kevin Lee', time: '9:44 AM', color: 'bg-emerald-500' },
];

export default function DashboardPage() {
  const navigate = useNavigate();
  const [currentDate, setCurrentDate] = useState('');
  const [profile, setProfile] = useState<DoctorProfile | null>(null);

  useEffect(() => {
    setCurrentDate(new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'short', day: 'numeric' }).format(new Date()));
    getProfile()
      .then(setProfile)
      .catch(console.error);
  }, []);

  return (
    <div className="w-full relative min-h-[calc(100vh-64px)] pb-12">
      {/* Background soft wavy gradient matching the image */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden z-0">
        <div className="absolute -top-[20%] -left-[10%] w-[70%] h-[60%] bg-blue-100/50 rounded-full blur-3xl opacity-60 mix-blend-multiply" />
        <div className="absolute top-[10%] -right-[10%] w-[50%] h-[50%] bg-[#ecfdf5]/40 rounded-full blur-3xl opacity-50 mix-blend-multiply" />
      </div>

      <div className="relative z-10 space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
        {/* 1. TOP HEADER */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 py-2">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="w-16 h-16 rounded-full overflow-hidden border-[3px] border-white shadow-sm shrink-0 bg-slate-100">
                <img src={profile?.overview?.profile_photo || `https://ui-avatars.com/api/?name=${encodeURIComponent(profile?.overview?.full_name || 'Doctor')}&background=1A6BFF&color=fff&size=128`} alt={profile?.overview?.full_name || "Doctor"} className="w-full h-full object-cover" />
              </div>
            </div>
            <div>
              <p className="text-brand-blue font-bold text-xs mb-0.5 tracking-wide">{currentDate}</p>
              <h1 className="text-2xl md:text-[28px] font-black text-[#0A2540] tracking-tight flex items-center gap-2">
                Good morning, {profile?.overview?.full_name || 'Doctor'} <Hand className="w-6 h-6 text-yellow-400 fill-yellow-400" />
              </h1>
              <p className="text-slate-500 font-medium text-sm mt-0.5">Everything is under control today</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3 self-start sm:self-auto">
            <div className="flex items-center gap-2 bg-[#ecfdf5] text-[#10b981] px-4 py-2 rounded-full border border-emerald-100 shadow-sm shadow-emerald-100/50">
              <div className="w-2.5 h-2.5 bg-[#10b981] rounded-full animate-pulse shadow-[0_0_8px_rgba(16,185,129,0.8)]" />
              <span className="text-sm font-bold tracking-wide">Online</span>
            </div>
            <button 
              onClick={() => navigate('/dashboard/emergency')}
              className="bg-red-500 hover:bg-red-600 text-white text-sm font-bold px-5 py-2 rounded-full border justify-center border-red-500 shadow-md shadow-red-500/20 transition-all flex items-center gap-2"
            >
              <AlertCircle className="w-4 h-4" /> Emergency Mode
            </button>
          </div>
        </div>

        {/* 2. STATS CARDS */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {STATS.map((stat, i) => (
            <div key={i} className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] p-5 shadow-sm border border-slate-100/50 hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-2">
                <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center mb-1", stat.bg, stat.color)}>
                  <stat.icon className="h-5 w-5" strokeWidth={2.5} />
                </div>
                <div className="text-slate-200">
                  {/* Subtle decorative arrow/graph in corner */}
                  <TrendingUp className="w-4 h-4 opacity-50" />
                </div>
              </div>
              <h3 className="text-slate-500 text-xs font-bold mt-1 tracking-wide">{stat.label}</h3>
              <p className="text-[26px] font-black text-[#0A2540] tracking-tight leading-tight mt-0.5">{stat.value}</p>
              <p className={cn("text-[11px] font-bold mt-1.5", stat.color.includes('purple') ? 'text-purple-500' : 'text-emerald-500')}>
                {stat.trend}
              </p>
            </div>
          ))}
        </div>

        {/* Action Bar / Shortcuts (Optional in this layout, but aligns with "Bottom Cards" logically) */}
        
        {/* 4. MAIN LAYOUT */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
          
          {/* LEFT SIDE: Pipeline & Patient Tools */}
          <div className="col-span-1 lg:col-span-2 space-y-6">
            
            {/* Today's Pipeline */}
            <div className="bg-white/80 backdrop-blur-xl rounded-[1.5rem] p-6 shadow-sm border border-slate-100/50">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-[17px] font-black text-[#0A2540] flex items-center gap-2">
                  <CalendarCheck className="w-5 h-5 text-brand-blue" /> Today's Pipeline
                </h3>
                <button 
                  onClick={() => navigate('/dashboard/schedule')}
                  className="bg-brand-blue hover:bg-blue-700 text-white text-xs font-bold px-4 py-2 rounded-lg transition-colors flex items-center gap-1.5 shadow-sm"
                >
                  Start Consultation <ChevronRight className="w-3.5 h-3.5" />
                </button>
              </div>

              <div className="relative pl-3 space-y-6">
                {/* Timeline vertical line */}
                <div className="absolute top-4 bottom-4 left-5 w-0.5 bg-slate-100/80 -z-10" />

                {APPOINTMENTS.map((apt) => (
                  <div key={apt.id} className="flex items-center gap-4 group">
                    <div className="relative">
                      <div className="w-3 h-3 rounded-full bg-white border-[2.5px] border-slate-200 z-10 relative 
                        group-first:border-brand-blue group-first:bg-blue-50" />
                    </div>
                    
                    <div className="flex-1 flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-2">
                      <div className="flex items-center gap-3">
                         <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold shadow-sm", apt.iconColor)}>
                           {apt.initials}
                         </div>
                         <div>
                           <p className="text-sm font-bold text-[#0A2540] flex items-center gap-2">
                             {apt.patientName} 
                             <span className="text-[11px] font-medium text-slate-500 font-normal">{apt.status}</span>
                           </p>
                           <p className="text-xs text-slate-400 mt-0.5">{apt.time}</p>
                         </div>
                      </div>
                      <button 
                        onClick={() => navigate(apt.type === 'progress' ? '/dashboard/schedule' : '/dashboard/patients')}
                        className={cn("px-3 py-1.5 rounded-md text-[11px] font-bold border transition-colors flex items-center justify-center gap-1 w-max",
                         apt.type === 'waiting' ? 'bg-amber-50 text-amber-600 border-amber-100 hover:bg-amber-100' :
                         apt.type === 'progress' ? 'bg-brand-blue border-transparent text-white shadow-sm shadow-blue-500/20' :
                         'bg-slate-50 text-slate-500 border-slate-200 hover:bg-slate-100'
                      )}>
                         {apt.status} <ChevronDown className="w-3 h-3 ml-0.5" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Bottom 2 Action Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
               {/* Smart Prescription */}
               <div 
                  onClick={() => navigate('/dashboard/prescription')}
                  className="bg-gradient-to-br from-[#f5f9ff] to-[#fbfdff] rounded-[1.25rem] p-5 shadow-sm border border-blue-100/50 cursor-pointer group hover:shadow-md transition-all"
               >
                 <div className="w-10 h-10 bg-indigo-100 rounded-lg text-indigo-600 flex items-center justify-center mb-3">
                   <Pill className="w-5 h-5" />
                 </div>
                 <h4 className="text-[15px] font-black text-[#0A2540] mb-1">Smart Prescription</h4>
                 <p className="text-xs text-slate-500 mb-4">Write, streamline, and generate Rx. instantly.</p>
                 <div className="text-xs font-bold text-indigo-600 flex items-center gap-1 group-hover:gap-1.5 transition-all">
                   Start Open <ChevronRight className="w-3 h-3" />
                 </div>
               </div>

               {/* Patient MedCards */}
               <div 
                  onClick={() => navigate('/dashboard/patients')}
                  className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] p-5 shadow-sm border border-slate-100/50 cursor-pointer group hover:shadow-md transition-all"
               >
                 <div className="w-10 h-10 bg-slate-50 border border-slate-100 rounded-lg text-slate-600 flex items-center justify-center mb-3">
                   <ArrowUpRight className="w-5 h-5" />
                 </div>
                 <h4 className="text-[15px] font-black text-[#0A2540] mb-1">Patient MedCards</h4>
                 <p className="text-xs text-slate-500 mb-4">Quickly access patient history.</p>
                 {/* Decorative background logo */}
                 <div className="text-xs font-bold text-slate-400 mt-4 opacity-0">.</div>
               </div>
            </div>
            
            {/* Third Action Card (Patients List Mini) */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
               <div 
                  onClick={() => navigate('/dashboard/patients')}
                  className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] p-5 shadow-sm border border-slate-100/50 cursor-pointer hover:shadow-md transition-shadow"
               >
                 <div className="flex items-center gap-2 mb-3">
                   <Users className="w-4 h-4 text-brand-blue" />
                   <h4 className="text-sm font-black text-[#0A2540]">Patients</h4>
                 </div>
                 <div className="flex items-center justify-between p-3 bg-slate-50 rounded-xl border border-slate-100 hover:border-brand-blue/30 transition-colors">
                    <div className="flex items-center gap-3">
                       <div className="w-9 h-9 bg-teal-400 rounded-lg text-white font-bold flex items-center justify-center shadow-sm">S</div>
                       <div>
                         <p className="text-sm font-bold text-[#0A2540]">Sarah Kumar</p>
                         <p className="text-[10px] text-slate-400">12:30 AM - 62% HQ</p>
                       </div>
                    </div>
                    <div className="w-6 h-6 rounded bg-white shadow-sm flex items-center justify-center text-brand-blue border border-slate-100">
                       <ChevronRight className="w-3 h-3" />
                    </div>
                 </div>
               </div>

               {/* Could expand or place additional functional tiles */}
            </div>

          </div>

          {/* RIGHT SIDE: Emergency, Queues, Analytics */}
          <div className="col-span-1 space-y-4">
            
            {/* Warning Card */}
            <div 
              onClick={() => navigate('/dashboard/emergency')}
              className="bg-gradient-to-br from-[#fef2f2] to-white rounded-[1.25rem] p-5 shadow-sm border border-red-100 cursor-pointer hover:shadow-md transition-shadow relative overflow-hidden"
            >
               {/* Pulse dot matching style */}
               <div className="absolute top-4 right-4 flex items-center justify-center">
                 <div className="w-1.5 h-1.5 bg-red-400 rounded-full" />
                 <div className="w-1 h-1 bg-red-300 rounded-full ml-1" />
                 <div className="w-0.5 h-0.5 bg-red-200 rounded-full ml-1" />
               </div>

               <h3 className="text-[15px] font-black text-[#b91c1c] flex items-center gap-2 mb-1">
                 <AlertCircle className="w-4 h-4" /> Emergency Case
               </h3>
               <p className="text-xs text-red-600/80 font-medium mb-4"><span className="text-red-600 font-bold">1</span> critical case requires immediate attention</p>
               
               <div className="bg-white rounded-xl p-3 border border-red-100/50 shadow-sm flex items-center justify-between">
                 <div>
                    <p className="text-sm font-bold text-[#0A2540] flex items-center gap-1.5">
                      <Clock className="w-3.5 h-3.5 text-red-500" /> Case #012, Emma Watson
                    </p>
                    <p className="text-[10px] text-slate-400 mt-0.5 ml-5">7 minutes ago</p>
                 </div>
                 <span className="bg-slate-50 text-slate-600 text-[10px] font-bold px-2 py-1 rounded border border-slate-200">Pending</span>
               </div>
            </div>

            {/* Active Ticket Queue */}
            <div className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] py-5 px-4 shadow-sm border border-slate-100/50">
               <h3 className="text-sm font-black text-[#0A2540] flex items-center gap-2 mb-4 px-1">
                 <ActivitySquare className="w-4 h-4 text-brand-blue" /> Active Ticket Queue
               </h3>
               <div className="space-y-2">
                 {TICKETS.map((t, idx) => (
                   <div 
                      key={idx} 
                      onClick={() => navigate('/dashboard/patients')}
                      className="flex justify-between items-center py-2.5 px-3 bg-slate-50/50 border border-slate-100/80 rounded-lg hover:bg-slate-50 cursor-pointer group transition-colors"
                   >
                     <p className="text-[13px] font-bold text-slate-700 flex items-center gap-2">
                       <span className="w-0.5 h-3 bg-brand-blue rounded-full"></span>
                       Case {t.id}. {t.name}
                     </p>
                     <div className="flex items-center gap-2">
                       <span className="text-[10px] font-bold text-slate-500 uppercase">{t.status}</span>
                       <ChevronRight className="w-3 h-3 text-slate-300 group-hover:text-slate-500" />
                     </div>
                   </div>
                 ))}
               </div>
            </div>

            {/* Daily Performance Graph */}
            <div 
              className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] p-5 shadow-sm border border-slate-100/50 cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => navigate('/dashboard/analytics')}
            >
               <h3 className="text-sm font-black text-[#0A2540] flex items-center gap-2 mb-6">
                 <TrendingUp className="w-4 h-4 text-emerald-500" /> Daily Performance
               </h3>
               {/* Simple CSS-based bar chart matching Stripe look */}
               <div className="flex items-end justify-between h-16 gap-2 w-full mt-2">
                 {[30, 45, 25, 40, 20, 35, 60, 45, 80, 50, 40].map((h, i) => (
                   <div key={i} className="flex-1 transition-colors rounded-t-sm" style={{ height: `${h}%`, backgroundColor: '#10b981' }}></div>
                 ))}
               </div>
            </div>

            {/* Notifications */}
            <div className="bg-white/80 backdrop-blur-xl rounded-[1.25rem] p-5 shadow-sm border border-slate-100/50">
               <h3 className="text-sm font-black text-[#0A2540] flex items-center gap-2 mb-4">
                 <div className="w-3.5 h-3.5 border-2 border-amber-400 rounded-full flex items-center justify-center p-0.5">
                   <div className="w-full h-full bg-amber-400 rounded-full" />
                 </div>
                 Notifications
               </h3>
               <div className="space-y-4">
                  {NOTIFICATIONS.map((n, i) => (
                    <div key={i} className="flex items-start gap-3">
                       <div className={cn("w-1.5 h-1.5 rounded-full mt-1.5 shrink-0", n.color)} />
                       <div className="flex-1">
                         <div className="flex justify-between items-start">
                           <p className="text-[13px] font-bold text-[#0A2540] leading-tight">{n.title}</p>
                           <p className="text-[10px] text-slate-400 font-medium whitespace-nowrap">{n.time}</p>
                         </div>
                         <p className="text-[11px] text-slate-500 mt-0.5">{n.desc}</p>
                       </div>
                    </div>
                  ))}
               </div>
            </div>

          </div>

        </div>
      </div>
    </div>
  );
}