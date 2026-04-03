import { useState } from 'react';
import { Link } from 'react-router-dom';
import type { Appointment } from '../types/appointment';
import { mockAppointmentsToday } from '../data/mockAppointments';
import { AppointmentCard } from '../components/AppointmentCard';
import { ConsultationPanel } from '../components/ConsultationPanel';
import {
  Calendar as CalendarIcon, Search, Plus, ChevronRight,
  Activity, Clock, Users, CheckCircle2, AlertTriangle, ListFilter,
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

const TodayAppointments = () => {
  const [activeConsultation, setActiveConsultation] = useState<Appointment | null>(null);
  const [search, setSearch] = useState('');

  const waitingCount   = mockAppointmentsToday.filter(a => a.status === 'Waiting' || a.status === 'Pending').length;
  const completedCount = mockAppointmentsToday.filter(a => a.status === 'Completed').length;
  const emergencyCount = mockAppointmentsToday.filter(a => a.priority === 'Emergency').length;
  const total          = mockAppointmentsToday.length;

  const filtered = search.trim()
    ? mockAppointmentsToday.filter(a =>
        a.patientName.toLowerCase().includes(search.toLowerCase()) ||
        a.symptoms.toLowerCase().includes(search.toLowerCase())
      )
    : mockAppointmentsToday;

  const STATS = [
    { label: 'Total',     value: total,          icon: Users,         cls: 'bg-blue-50 text-blue-700 border-blue-200'     },
    { label: 'Waiting',   value: waitingCount,   icon: Clock,         cls: 'bg-amber-50 text-amber-700 border-amber-200'  },
    { label: 'Done',      value: completedCount, icon: CheckCircle2,  cls: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
    { label: 'Emergency', value: emergencyCount, icon: AlertTriangle, cls: 'bg-red-50 text-red-700 border-red-200'        },
  ];

  return (
    <div className="max-w-[1600px] mx-auto flex flex-col h-[calc(100vh-8rem)] md:h-[calc(100vh-7rem)] pt-1 animate-in fade-in slide-in-from-bottom-4 duration-500 gap-4">

      {/* ── Command Bar ─────────────────────────────────────────────────────── */}
      <div className="space-y-3">
        {/* Row 1: Date + Search + CTA */}
        <div className="flex flex-col xl:flex-row gap-3 justify-between items-stretch xl:items-center">
          <div className="flex flex-col sm:flex-row gap-3 flex-1">
            {/* Date pill */}
            <button className="flex items-center gap-3 bg-white border border-slate-200 rounded-2xl px-4 py-3 hover:border-blue-300 hover:shadow-md transition-all group shadow-sm shrink-0">
              <div className="w-9 h-9 bg-blue-600 rounded-xl flex items-center justify-center shadow-sm shadow-blue-600/25">
                <CalendarIcon className="w-4 h-4 text-white" />
              </div>
              <div className="text-left">
                <p className="text-[13px] font-black text-slate-800 leading-none">Today</p>
                <p className="text-[11px] font-semibold text-slate-400 mt-0.5">24 October 2024</p>
              </div>
              <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-blue-400 ml-1 transition-colors" />
            </button>

            {/* Search */}
            <div className="flex-1 relative group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4 group-focus-within:text-blue-500 transition-colors" />
              <input
                type="text"
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Search patient or symptom…"
                className="w-full bg-white border border-slate-200 rounded-2xl pl-11 pr-4 py-3 text-[14px] font-medium outline-none focus:border-blue-400 focus:ring-4 focus:ring-blue-500/10 transition-all shadow-sm placeholder:text-slate-400 text-slate-800"
              />
            </div>
          </div>

          <div className="flex flex-wrap sm:flex-nowrap items-center gap-2.5 shrink-0 mt-2 xl:mt-0">
            <button className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-white border border-slate-200 text-slate-600 text-[13px] font-bold px-4 py-3 rounded-2xl hover:bg-slate-50 transition-all shadow-sm">
              <ListFilter className="w-4 h-4" /> Filter
            </button>
            <Link
              to="/dashboard/sos"
              className="flex-1 sm:flex-none flex justify-center items-center gap-2 bg-red-50 border border-red-200 text-red-700 text-[13px] font-bold px-4 py-3 rounded-2xl hover:bg-red-100 hover:border-red-300 transition-all shadow-sm whitespace-nowrap"
            >
              <AlertTriangle className="w-4 h-4" />
              SOS
              <span className="bg-red-500 text-white text-[10px] font-black w-5 h-5 rounded-full flex items-center justify-center shadow-sm">
                {emergencyCount}
              </span>
            </Link>
            <button className="w-full sm:w-auto flex items-center justify-center gap-2 bg-slate-900 text-white text-[14px] font-bold px-5 py-3 rounded-2xl hover:bg-slate-800 active:scale-95 transition-all shadow-lg flex-none mt-1 sm:mt-0 whitespace-nowrap">
              <Plus className="w-4 h-4" /> Walk-in
            </button>
          </div>
        </div>

        {/* Row 2: Stats chips */}
        <div className="flex items-center gap-2.5 overflow-x-auto hide-scrollbar pb-1">
          {activeConsultation && (
            <button
              onClick={() => setActiveConsultation(null)}
              className="flex lg:hidden items-center gap-2 text-slate-700 hover:text-blue-600 bg-white font-bold text-[13px] px-4 py-2 rounded-2xl shadow-sm border border-slate-200 transition-all shrink-0"
            >
              <ChevronRight className="w-4 h-4 rotate-180" /> Queue
            </button>
          )}
          {STATS.map(({ label, value, icon: Icon, cls }) => (
            <div
              key={label}
              className={cn('flex items-center gap-2 px-4 py-2 rounded-2xl border text-[13px] font-bold whitespace-nowrap shadow-sm', cls)}
            >
              <Icon className="w-3.5 h-3.5" />
              {label}
              <span className="font-black ml-0.5">{value}</span>
            </div>
          ))}
          <div className="ml-auto flex items-center gap-1.5 text-[12px] font-bold text-slate-500 bg-white border border-slate-200 px-3 py-2 rounded-xl shadow-sm whitespace-nowrap">
            <Activity className="w-3.5 h-3.5 text-emerald-500" />
            Next: 09:00 AM
          </div>
        </div>
      </div>

      {/* ── Main Body ───────────────────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col lg:flex-row gap-4 min-h-0">

        {/* Queue Panel */}
        <div className={cn(
          'flex flex-col rounded-3xl overflow-hidden border border-slate-200/80 shadow-md bg-white shrink-0 transition-all duration-300',
          activeConsultation ? 'hidden lg:flex lg:w-[260px] xl:w-[280px]' : 'flex w-full lg:w-[400px] xl:w-[450px]'
        )}>
          {/* Queue header — soft light style */}
          <div className="bg-white border-b border-slate-200 px-5 py-4 flex items-center justify-between shrink-0">
            <div>
              <h2 className="text-slate-800 font-black text-[16px] leading-tight">Patient Queue</h2>
              <p className="text-slate-400 text-[12px] font-semibold mt-0.5">
                {waitingCount} waiting · {completedCount} done
              </p>
            </div>
            <div className="flex items-center gap-1.5 bg-blue-50 border border-blue-100 px-3 py-1.5 rounded-xl">
              <span className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
              <span className="text-blue-600 text-[12px] font-bold">{total} today</span>
            </div>
          </div>

          {/* Queue list */}
          <div className="flex-1 overflow-y-auto custom-scrollbar bg-slate-50/60 p-3 space-y-2.5 pb-20 lg:pb-3">
            {filtered.length > 0 ? (
              filtered.map(apt => (
                <AppointmentCard
                  key={apt.id}
                  appointment={apt}
                  onStart={setActiveConsultation}
                  isActive={activeConsultation?.id === apt.id}
                />
              ))
            ) : (
              <div className="flex flex-col items-center justify-center py-12 text-slate-400 text-center">
                <Search className="w-8 h-8 mb-3 text-slate-300" />
                <p className="font-semibold text-slate-500">No results for "{search}"</p>
              </div>
            )}
          </div>
        </div>

        {/* Consultation workspace */}
        {activeConsultation ? (
          <div className="flex-1 min-w-0 h-full relative animate-in slide-in-from-right-6 duration-300">
            <ConsultationPanel appointment={activeConsultation} />
          </div>
        ) : (
          <div className="hidden lg:flex flex-1 flex-col items-center justify-center bg-white/60 backdrop-blur-md border-2 border-dashed border-slate-200 rounded-3xl text-slate-400">
            <div className="w-24 h-24 bg-gradient-to-br from-blue-100 to-indigo-100 rounded-3xl shadow-sm flex items-center justify-center mb-6 rotate-3 hover:rotate-0 transition-transform duration-500 cursor-default">
              <Activity className="w-10 h-10 text-blue-500" />
            </div>
            <h3 className="text-xl font-black text-slate-700 mb-2">Select a Patient</h3>
            <p className="text-[14px] font-medium text-slate-400 text-center max-w-xs leading-relaxed">
              Click any appointment in the queue to start or continue a consultation.
            </p>
          </div>
        )}

      </div>
    </div>
  );
};

export default TodayAppointments;