import { useState, useEffect } from 'react';
import type { Appointment } from '../types/appointment';
import {
  Mic, MicOff, VideoOff, PhoneOff, Upload, Sparkles, Send,
  ExternalLink, Activity, Heart, Thermometer, Clock, Droplets,
  AlertTriangle, FileText, MessageCircle, Wifi, Save, Users,
  ChevronRight, X, Pill, ArrowLeft,
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { useNavigate } from 'react-router-dom';
import { 
  PatientHeader, 
  MedicineForm, 
  MedicineCard, 
  CostPanel, 
  PrescriptionPreview
} from './prescription/PrescriptionComponents';
import type { MedicineItem, PatientInfo } from './prescription/PrescriptionComponents';
import { getProfile } from '../services/doctorProfileService';


interface ConsultationPanelProps {
  appointment: Appointment;
}

// ── Vitals (offline only) ──────────────────────────────────────────────────────
const VITALS = [
  { label: 'Blood Pressure', value: '120/80', unit: 'mmHg', icon: Activity,    color: 'text-blue-500',    bg: 'bg-blue-50'    },
  { label: 'Heart Rate',     value: '72',      unit: 'bpm',  icon: Heart,       color: 'text-rose-500',    bg: 'bg-rose-50'    },
  { label: 'Temperature',    value: '98.6',    unit: '°F',   icon: Thermometer, color: 'text-amber-500',   bg: 'bg-amber-50'   },
  { label: 'SpO₂',           value: '98',      unit: '%',    icon: Droplets,    color: 'text-emerald-500', bg: 'bg-emerald-50' },
];



const QUICK_CHIPS = ['Gen. Checkup', 'Follow-up', 'Refill Request', 'Lab Order', 'Referral'];

// ── Video Panel ────────────────────────────────────────────────────────────────
const VideoFeed = ({ appointment, doctorName, doctorAvatar }: { appointment: Appointment, doctorName: string, doctorAvatar: string }) => (
  <div className="flex flex-col h-full gap-2.5">

    {/* Video feed — fills all available vertical space */}
    <div className="relative rounded-2xl overflow-hidden bg-slate-900 w-full flex-1 min-h-0 shadow-xl">
      <img
        src={appointment.avatar}
        className="absolute inset-0 w-full h-full object-cover opacity-30 mix-blend-overlay"
      />
      {/* LIVE badge */}
      <div className="absolute top-3 left-3 flex items-center gap-1.5 bg-black/60 backdrop-blur-md text-white text-[11px] font-bold px-2.5 py-1.5 rounded-lg border border-white/10">
        <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse" /> LIVE
      </div>
      {/* Overlay mic/cam buttons */}
      <div className="absolute inset-0 flex items-end justify-center pb-5 gap-4">
        <button className="p-3 bg-white/10 hover:bg-white/20 backdrop-blur-md rounded-full text-white transition-colors border border-white/15 shadow-lg">
          <MicOff className="w-5 h-5" />
        </button>
        <button className="p-3 bg-white/10 hover:bg-white/20 backdrop-blur-md rounded-full text-white transition-colors border border-white/15 shadow-lg">
          <VideoOff className="w-5 h-5" />
        </button>
      </div>
      {/* Self-view PIP */}
      <div className="absolute bottom-4 right-3 w-[72px] h-24 bg-slate-800 rounded-xl ring-2 ring-white/20 overflow-hidden shadow-xl">
        <img
          src={doctorAvatar}
          alt={doctorName}
          className="w-full h-full object-cover"
        />
      </div>
    </div>

    {/* Compact control bar */}
    <div className="flex items-center gap-2 shrink-0">
      {([
        { icon: Mic,      label: 'Mute',   danger: false },
        { icon: VideoOff, label: 'Camera', danger: false },
        { icon: Upload,   label: 'Share',  danger: false },
        { icon: PhoneOff, label: 'End',    danger: true  },
      ] as const).map(({ icon: Icon, label, danger }) => (
        <button
          key={label}
          className={cn(
            'flex-1 flex flex-col items-center gap-1 py-2.5 rounded-xl border text-[10px] font-bold transition-all',
            danger
              ? 'bg-red-50 border-red-200 text-red-500 hover:bg-red-500 hover:text-white hover:border-red-500'
              : 'bg-white border-slate-200 text-slate-500 hover:border-blue-300 hover:text-blue-600'
          )}
        >
          <Icon className="w-4 h-4" />
          {label}
        </button>
      ))}

      {/* Connection pill — inline with controls */}
      <div className="flex items-center gap-1.5 bg-white border border-slate-200 rounded-xl px-3 py-2.5 shrink-0 ml-1">
        <Wifi className="w-3.5 h-3.5 text-emerald-500" />
        <div className="leading-none">
          <p className="text-[10px] font-bold text-slate-700">Stable</p>
          <p className="text-[9px] text-slate-400 font-medium">24ms · HD</p>
        </div>
        <div className="flex items-center gap-1 text-emerald-600 bg-emerald-50 border border-emerald-100 text-[10px] font-bold px-2 py-1 rounded-lg ml-1">
          <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" />
          05:24
        </div>
      </div>
    </div>
  </div>
);

// ── Component ─────────────────────────────────────────────────────────────────
export const ConsultationPanel = ({ appointment }: ConsultationPanelProps) => {
  const [activeTab, setActiveTab]   = useState<'notes' | 'chat'>('notes');
  const [mode, setMode]             = useState<'consult' | 'prescription'>('consult');
  
  const navigate = useNavigate();
  const [medicines, setMedicines] = useState<MedicineItem[]>([]);
  const [doctorName, setDoctorName] = useState('Doctor');
  const [doctorAvatar, setDoctorAvatar] = useState('https://ui-avatars.com/api/?name=Doctor&background=2563EB&color=fff');

  useEffect(() => {
    getProfile().then(prof => {
      if (prof?.overview?.full_name) {
        setDoctorName(prof.overview.full_name);
        setDoctorAvatar(prof.overview.profile_photo || `https://ui-avatars.com/api/?name=${encodeURIComponent(prof.overview.full_name)}&background=2563EB&color=fff`);
      }
    }).catch(console.error);
  }, []);

  const isOnline    = appointment.type    === 'online';
  const isEmergency = appointment.priority === 'Emergency';

  const handleAddMedicine = (med: MedicineItem) => setMedicines([...medicines, med]);
  const handleRemoveMedicine = (id: string) => setMedicines(medicines.filter(m => m.id !== id));

  // Map appointment details to PatientInfo
  const patientInfo: PatientInfo = {
    name: appointment.patientName,
    age: parseInt(appointment.patientAge?.toString() || '34', 10),
    gender: 'Unknown', 
    date: new Date().toLocaleDateString(),
    doctor: doctorName,
    rxNumber: 'RX-' + Math.floor(100000 + Math.random() * 900000)
  };


  // ── Shared header ────────────────────────────────────────────────────────────
  const Header = () => (
    <div className={cn(
      'flex flex-col sm:flex-row sm:items-center gap-4 px-5 py-4 border-b border-slate-100 bg-white shrink-0',
      isEmergency ? 'border-l-4 border-l-red-400' : 'border-l-4 border-l-blue-400'
    )}>
      <div className="flex items-center gap-4 w-full sm:w-auto flex-1 min-w-0">
        <div className="relative cursor-pointer shrink-0" onClick={() => navigate(`/case/${appointment.id}`)}>
          <img src={appointment.avatar} alt="Patient" className="w-12 h-12 rounded-xl object-cover ring-2 ring-slate-100" />
          <span className={cn('absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 rounded-full border-2 border-white', isEmergency ? 'bg-red-400' : 'bg-emerald-400')} />
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <h2 className="font-black text-slate-800 text-[17px] leading-tight">{appointment.patientName}</h2>
            {isEmergency && (
              <span className="flex items-center gap-1 bg-red-50 text-red-600 border border-red-200 text-[10px] font-black px-2 py-0.5 rounded-full">
                <AlertTriangle className="w-2.5 h-2.5" /> EMERGENCY
              </span>
            )}
            <button onClick={() => navigate(`/case/${appointment.id}`)} className="hidden sm:flex items-center gap-1 text-blue-500 hover:text-blue-600 text-[12px] font-bold transition-colors">
              <ExternalLink className="w-3 h-3" /> Case View
            </button>
          </div>
          <p className="text-slate-400 text-[13px] font-semibold mt-0.5 truncate">
            {appointment.patientAge} yrs Â· {appointment.symptoms}
          </p>
        </div>
      </div>

      <div className="flex flex-wrap sm:flex-nowrap items-center gap-2 w-full sm:w-auto shrink-0 justify-end mt-1 sm:mt-0">
        <button onClick={() => navigate(`/case/${appointment.id}`)} className="sm:hidden flex flex-1 items-center justify-center gap-1.5 text-[13px] font-bold text-blue-600 border border-blue-200 bg-blue-50 px-3.5 py-2 rounded-xl">
          <ExternalLink className="w-4 h-4" /> Case View
        </button>
        {mode === 'prescription' && (
          <button onClick={() => setMode('consult')} className="flex flex-1 sm:flex-none justify-center items-center gap-1.5 text-[13px] font-bold text-slate-600 border border-slate-200 bg-white px-3.5 py-2 rounded-xl hover:bg-slate-50 transition-all">
            <ArrowLeft className="w-4 h-4" /> Back
          </button>
        )}
        <button onClick={() => navigate('/patients')} className="flex flex-1 sm:flex-none justify-center items-center gap-1.5 text-[13px] font-bold text-slate-600 border border-slate-200 bg-white px-3.5 py-2 rounded-xl hover:bg-slate-50 transition-all">
          <Users className="w-4 h-4" /> History
        </button>
        <button onClick={() => alert('Consultation saved and ended.')} className="flex flex-1 sm:flex-none justify-center items-center gap-1.5 text-[13px] font-bold text-white bg-red-500 hover:bg-red-600 px-4 py-2 rounded-xl transition-all active:scale-95 shadow-sm">
          <X className="w-4 h-4" /> End Consult
        </button>
      </div>
    </div>
  );

  // ── ONLINE — Prescription mode (Video + Rx side by side) ────────────────────
  if (isOnline && mode === 'prescription') {
    return (
      <div className={cn('flex flex-col h-[calc(100vh-140px)] md:h-full rounded-2xl overflow-hidden border bg-white shadow-lg', isEmergency ? 'border-red-200' : 'border-slate-200')}>
        <Header />
        <div className="flex-1 flex flex-col md:flex-row overflow-hidden min-h-0">
          {/* Left: Video (45%) */}
          <div className="w-full h-[40vh] md:h-auto md:w-[30%] lg:w-[25%] shrink-0 flex flex-col p-4 border-b md:border-b-0 md:border-r border-slate-100 bg-slate-50/40">
            <div className="text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3 flex items-center gap-2">
              <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse" /> Video Call Active
            </div>
            <VideoFeed appointment={appointment} doctorName={doctorName} doctorAvatar={doctorAvatar} />
          </div>

          {/* Right: Smart Prescription Writer */}
          <div className="flex-1 flex flex-col overflow-hidden bg-white p-4 overflow-y-auto custom-scrollbar">
             <div className="flex flex-col lg:flex-row gap-6">
                {/* Inputs */}
                <div className="flex-1 space-y-5 min-w-0">
                   <PatientHeader patient={patientInfo} />
                   
                   <MedicineForm onAdd={handleAddMedicine} />

                   {medicines.length > 0 && (
                     <div className="space-y-4">
                        <h4 className="text-[14px] font-black text-slate-800 flex items-center justify-between">
                           Added Medicines ({medicines.length})
                        </h4>
                        <div className="space-y-3">
                          {medicines.map((med) => (
                            <MedicineCard key={med.id} med={med} onRemove={() => handleRemoveMedicine(med.id)} />
                          ))}
                        </div>
                     </div>
                   )}
                </div>

                {/* Vertical Divider */}
                <div className="hidden lg:block w-px bg-slate-100 shrink-0" />

                {/* Preview */}
                <div className="w-full lg:w-[45%] flex flex-col gap-5 shrink-0">
                   {medicines.length > 0 && <CostPanel medicines={medicines} />}
                   <div className="flex-1 min-h-[400px]">
                      <PrescriptionPreview medicines={medicines} patient={patientInfo} />
                   </div>
                </div>
             </div>
          </div>
        </div>
      </div>
    );
  }

  // ── ONLINE — Consult mode (large full-width video + notes) ───────────────────
  if (isOnline && mode === 'consult') {
    return (
      <div className={cn('flex flex-col h-[calc(100vh-140px)] md:h-full rounded-2xl overflow-hidden border bg-white shadow-lg', isEmergency ? 'border-red-200' : 'border-slate-200')}>
        <Header />
        <div className="flex-1 flex flex-col md:flex-row overflow-hidden min-h-0">

          {/* Left: Large video (55%) */}
          <div className="w-full md:w-[52%] shrink-0 flex flex-col p-4 border-b md:border-b-0 md:border-r border-slate-100 bg-slate-50/30 min-h-0">
            <VideoFeed appointment={appointment} doctorName={doctorName} doctorAvatar={doctorAvatar} />
          </div>

          {/* Right: Notes / Chat (48%) */}
          <div className="flex-1 flex flex-col overflow-hidden min-h-0 bg-white">
            {/* Tab bar */}
            <div className="flex items-center border-b border-slate-100 px-4 gap-0.5 shrink-0">
              {([
                { id: 'notes', label: 'Clinical Notes', icon: FileText      },
                { id: 'chat',  label: 'Patient Chat',   icon: MessageCircle },
              ] as const).map(({ id, label, icon: Icon }) => (
                <button
                  key={id}
                  onClick={() => setActiveTab(id)}
                  className={cn(
                    'flex items-center gap-1.5 px-4 py-3.5 text-[13px] font-bold transition-all border-b-2 -mb-px',
                    activeTab === id ? 'text-blue-600 border-blue-500' : 'text-slate-400 border-transparent hover:text-slate-600'
                  )}
                >
                  <Icon className="w-4 h-4" />{label}
                </button>
              ))}
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar p-4 min-h-0">
              {activeTab === 'notes' ? (
                <div className="flex flex-col h-full gap-3 min-h-[280px]">
                  <div className="flex flex-wrap gap-1.5">
                    {QUICK_CHIPS.map((chip, i) => (
                      <button key={chip} className={cn('text-[12px] font-bold px-3 py-1.5 rounded-xl border transition-all', i === 0 ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-700' : 'bg-white text-slate-500 border-slate-200 hover:border-blue-300 hover:text-blue-600')}>
                        + {chip}
                      </button>
                    ))}
                  </div>
                  <div className="flex-1 flex flex-col rounded-xl border border-slate-200 overflow-hidden min-h-[150px]">
                    <div className="flex items-center justify-between px-3 py-2.5 bg-slate-50 border-b border-slate-200">
                      <span className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Notes</span>
                      <button className="p-1.5 rounded-lg bg-violet-100 text-violet-600 hover:bg-violet-200 transition-colors">
                        <Sparkles className="w-3.5 h-3.5" />
                      </button>
                    </div>
                    <textarea
                      className="flex-1 p-4 outline-none resize-none text-[13px] text-slate-700 font-medium leading-relaxed bg-white placeholder:text-slate-300"
                      placeholder="Start typing observation notes…"
                      defaultValue={`Patient reports: ${appointment.symptoms}\n\nObservations:\n- Has been feeling unwell for 2 days.\n- Vitals are stable.\n\nDiagnosis:\n- `}
                    />
                    <div className="px-3 py-2 bg-slate-50 border-t border-slate-100 flex justify-between text-[11px] text-slate-400 font-medium">
                      <span>Last saved: Just now</span><span>28 words</span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button className="flex-1 flex items-center justify-center gap-2 bg-white border border-slate-200 text-slate-600 text-[13px] font-bold py-2.5 rounded-xl hover:border-blue-300 hover:text-blue-600 transition-all group">
                      <Mic className="w-4 h-4 group-hover:text-blue-500 text-slate-400 transition-colors" /> Voice to Text
                    </button>
                    <button className="flex items-center gap-1.5 bg-blue-600 text-white text-[13px] font-bold px-5 py-2.5 rounded-xl hover:bg-blue-700 shadow-sm transition-all active:scale-95">
                      <Save className="w-4 h-4" /> Save
                    </button>
                  </div>
                </div>
              ) : (
                <div className="flex flex-col h-full gap-3 min-h-[280px]">
                  <div className="flex-1 space-y-4">
                    <div className="flex items-end gap-2.5">
                      <img src={appointment.avatar} className="w-8 h-8 rounded-full border-2 border-white shadow-sm shrink-0" />
                      <div className="bg-slate-100 p-3.5 rounded-2xl rounded-bl-sm text-[13px] font-medium text-slate-700 max-w-[80%] leading-relaxed">
                        Hello Doctor, I've been feeling dizzy since yesterday morning.
                      </div>
                    </div>
                    <div className="flex items-end gap-2.5 flex-row-reverse">
                      <div className="bg-blue-600 text-white p-3.5 rounded-2xl rounded-br-sm text-[13px] font-medium max-w-[80%] leading-relaxed shadow-sm">
                        I see. Have you checked your BP recently?
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2 border-t border-slate-100 pt-3">
                    <input type="text" placeholder="Type message…" className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-[13px] font-medium outline-none focus:border-blue-400 transition-all" />
                    <button className="w-11 h-11 bg-slate-900 hover:bg-slate-800 text-white rounded-xl transition-all shadow active:scale-95 flex items-center justify-center">
                      <Send className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Prescription CTA */}
            <div className="px-4 py-3.5 border-t border-slate-100 bg-white shrink-0">
              <button
                onClick={() => setMode('prescription')}
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold text-[14px] py-3.5 rounded-xl flex items-center justify-center gap-2.5 shadow-md shadow-blue-500/20 hover:shadow-lg transition-all active:scale-[0.99]"
              >
                <Pill className="w-5 h-5" /> Write Prescription (video stays on)
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── OFFLINE consultation ─────────────────────────────────────────────────────
  return (
    <div className={cn('flex flex-col h-full rounded-3xl overflow-hidden border bg-white shadow-xl ring-1', isEmergency ? 'border-red-200 ring-red-100 shadow-red-500/10 border-l-4 border-l-red-500' : 'border-slate-200 ring-slate-100 shadow-blue-500/5')}>
      <Header />

      {/* Vitals strip */}
      <div className="grid grid-cols-2 md:grid-cols-4 divide-y md:divide-y-0 md:divide-x divide-slate-100 border-b border-slate-100 bg-white shrink-0">
        {VITALS.map((v) => {
          const Icon = v.icon;
          return (
            <div key={v.label} className="flex flex-col sm:flex-row items-start sm:items-center gap-4 p-5 hover:bg-slate-50/80 transition-all duration-300">
              <div className={cn('w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 shadow-inner', v.bg)}>
                <Icon className={cn('w-6 h-6', v.color)} />
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <p className="text-[12px] font-bold text-slate-400 truncate tracking-wide uppercase">{v.label}</p>
                  <span className="text-[10px] font-black text-emerald-600 bg-emerald-50 border border-emerald-200/60 px-2 py-0.5 rounded-md shrink-0 shadow-sm">OK</span>
                </div>
                <p className="font-black text-slate-800 text-[26px] leading-none tracking-tight">
                  {v.value}<span className="text-[13px] font-bold text-slate-400 ml-1.5">{v.unit}</span>
                </p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Body */}
      <div className="flex-1 flex flex-col lg:flex-row overflow-hidden min-h-0 bg-slate-50/30">
        {/* Left: AI Insights */}
        <div className="w-full lg:w-[320px] shrink-0 flex flex-col border-b lg:border-b-0 lg:border-r border-slate-200/60 overflow-y-auto custom-scrollbar p-5 space-y-5 bg-white/50 backdrop-blur-sm">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-violet-100 to-fuchsia-100 rounded-2xl flex items-center justify-center shadow-inner border border-violet-200/50">
              <Sparkles className="w-5 h-5 text-violet-600" />
            </div>
            <div>
              <h3 className="font-black text-[16px] text-slate-800 tracking-tight">AI Insights</h3>
              <p className="flex items-center gap-1 text-[12px] font-bold text-slate-400">
                <Clock className="w-3.5 h-3.5" /> Updated 10m ago
              </p>
            </div>
          </div>

          <div className="space-y-3">
            <p className="text-[11px] font-black text-slate-400 uppercase tracking-widest pl-1">Identified Symptoms</p>
            <div className="flex flex-wrap gap-2">
              {appointment.symptoms.split(',').map((s, i) => (
                <span key={i} className="bg-white text-violet-700 border border-violet-200 px-3.5 py-1.5 rounded-xl text-[13px] font-bold shadow-sm hover:shadow-md transition-shadow cursor-default">{s.trim()}</span>
              ))}
            </div>
          </div>

          <div className="bg-gradient-to-br from-violet-50 to-white border border-violet-100/80 rounded-2xl p-4 shadow-sm relative overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-violet-500/5 rounded-full blur-2xl -mr-10 -mt-10 pointer-events-none" />
            <p className="text-[11px] font-black text-violet-600 uppercase tracking-widest mb-2.5 relative z-10">Suggested Focus</p>
            <p className="text-[13px] text-slate-700 font-semibold leading-relaxed relative z-10">
              Monitor BP closely. High correlation with reported symptoms. Consider ordering an ECG if chest pain persists.
            </p>
          </div>

          {appointment.roomNumber && (
            <div className="flex items-center gap-4 bg-white border border-slate-200 rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow cursor-pointer group mt-auto">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl flex items-center justify-center shadow-inner group-hover:scale-105 transition-transform">
                <span className="text-white text-[15px] font-black">{appointment.roomNumber}</span>
              </div>
              <div className="flex-1">
                <p className="font-black text-slate-800 text-[15px]">In-Person</p>
                <p className="text-slate-400 text-[13px] font-bold">Room {appointment.roomNumber}</p>
              </div>
              <ChevronRight className="w-5 h-5 text-slate-300 group-hover:text-blue-500 group-hover:translate-x-1 transition-all" />
            </div>
          )}
        </div>

        {/* Right: Notes / Chat */}
        <div className="flex-1 flex flex-col overflow-hidden min-h-0 bg-white">
          <div className="flex items-center border-b border-slate-100 px-6 gap-6 shrink-0 bg-white/80 backdrop-blur-md z-10">
            {([
              { id: 'notes', label: 'Clinical Notes', icon: FileText      },
              { id: 'chat',  label: 'Patient Chat',   icon: MessageCircle },
            ] as const).map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={cn('relative flex items-center gap-2 py-4 text-[14px] font-black transition-all group', activeTab === id ? 'text-blue-600' : 'text-slate-400 hover:text-slate-700')}
              >
                <Icon className={cn("w-4.5 h-4.5 transition-colors", activeTab === id ? "text-blue-500" : "group-hover:text-slate-500")} />
                {label}
                {activeTab === id && (
                  <span className="absolute bottom-0 left-0 right-0 h-1 bg-blue-600 rounded-t-full shadow-[0_-2px_10px_rgba(37,99,235,0.4)]" />
                )}
              </button>
            ))}
          </div>

          <div className="flex-1 overflow-y-auto custom-scrollbar p-6 min-h-0">
            {activeTab === 'notes' ? (
              <div className="flex flex-col h-full gap-5 min-h-[350px]">
                <div className="flex flex-wrap gap-2">
                  {QUICK_CHIPS.map((chip, i) => (
                    <button key={chip} className={cn('text-[13px] font-bold px-4 py-2 rounded-xl border transition-all duration-200 active:scale-95 shadow-sm', i === 0 ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-700 hover:shadow-md' : 'bg-white text-slate-600 border-slate-200 hover:border-slate-300 hover:bg-slate-50 hover:text-slate-900')}>+ {chip}</button>
                  ))}
                </div>
                
                <div className="flex-1 flex flex-col rounded-2xl border-2 border-slate-100 overflow-hidden min-h-[220px] focus-within:border-blue-400 focus-within:ring-4 focus-within:ring-blue-500/10 transition-all bg-white shadow-sm">
                  <div className="flex items-center justify-between px-5 py-3 bg-slate-50/80 border-b border-slate-100">
                    <span className="text-[12px] font-black text-slate-500 uppercase tracking-widest">Consultation Notes</span>
                    <button className="p-2 rounded-xl bg-violet-100 text-violet-600 hover:bg-violet-200 transition-colors shadow-sm active:scale-95 group">
                      <Sparkles className="w-4 h-4 group-hover:scale-110 transition-transform" />
                    </button>
                  </div>
                  <textarea
                    className="flex-1 p-5 outline-none resize-none text-[15px] text-slate-700 font-medium leading-relaxed bg-transparent placeholder:text-slate-300 custom-scrollbar"
                    placeholder="Start typing observation notes…"
                    defaultValue={`Patient reports: ${appointment.symptoms}\n\nObservations:\n- Has been feeling unwell for 2 days.\n- Vitals are stable, but monitoring is required.\n\nDiagnosis:\n- `}
                  />
                  <div className="px-5 py-3 bg-slate-50/80 border-t border-slate-100 flex justify-between items-center">
                     <span className="text-[12px] text-slate-400 font-bold flex items-center gap-1.5">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" /> Auto-saving...
                     </span>
                     <span className="text-[12px] text-slate-400 font-bold bg-white px-2 py-1 rounded-md border border-slate-200 shadow-sm">28 words</span>
                  </div>
                </div>

                <div className="flex flex-col sm:flex-row gap-3 pt-2">
                  <button className="flex-1 flex items-center justify-center gap-2.5 bg-white border-2 border-slate-200 text-slate-700 text-[14px] font-black py-3.5 rounded-xl hover:border-slate-300 hover:bg-slate-50 transition-all active:scale-95 shadow-sm group">
                    <Mic className="w-5 h-5 text-slate-400 group-hover:text-blue-500 transition-colors" /> Start Voice Typing
                  </button>
                  <div className="flex gap-3">
                    <button className="w-14 h-14 flex items-center justify-center bg-white border-2 border-slate-200 text-slate-500 rounded-xl hover:border-slate-300 hover:bg-slate-50 hover:text-slate-700 transition-all shadow-sm active:scale-95">
                      <Upload className="w-5 h-5" />
                    </button>
                    <button className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-slate-900 text-white text-[14px] font-black px-8 py-3.5 rounded-xl hover:bg-slate-800 shadow-md shadow-slate-900/20 transition-all active:scale-95">
                      <Save className="w-5 h-5" /> Save Notes
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="flex flex-col h-full gap-4 min-h-[350px]">
                <div className="flex-1 space-y-6 overflow-y-auto pr-2 custom-scrollbar">
                  <div className="flex items-end gap-3">
                    <img src={appointment.avatar} className="w-10 h-10 rounded-full border-2 border-white shadow-md shrink-0" />
                    <div className="bg-slate-100 p-4 rounded-2xl rounded-bl-sm text-[14px] font-semibold text-slate-700 max-w-[80%] leading-relaxed shadow-sm">Hello Doctor, I've been feeling dizzy since yesterday morning.</div>
                  </div>
                  <div className="flex items-end gap-3 flex-row-reverse">
                    <div className="bg-blue-600 text-white p-4 rounded-2xl rounded-br-sm text-[14px] font-medium max-w-[80%] leading-relaxed shadow-md shadow-blue-500/20">I see. Have you checked your BP recently?</div>
                  </div>
                </div>
                <div className="flex gap-3 pt-4 border-t border-slate-100 relative">
                  <input type="text" placeholder="Type a message to the patient…" className="flex-1 bg-white border-2 border-slate-200 rounded-2xl px-5 py-4 text-[14px] font-medium outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 shadow-sm transition-all" />
                  <button className="w-14 h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl transition-all shadow-lg shadow-blue-500/30 active:scale-90 flex items-center justify-center shrink-0 absolute right-1.5 top-[1.1rem]">
                    <Send className="w-5 h-5 ml-1" />
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="p-5 border-t border-slate-100 bg-white shrink-0 z-20 shadow-[0_-10px_30px_rgba(0,0,0,0.02)]">
        <button
          onClick={() => navigate('/dashboard/prescription')}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white font-black text-[16px] py-4 rounded-2xl flex items-center justify-center gap-2.5 shadow-xl shadow-blue-600/20 hover:shadow-2xl hover:-translate-y-0.5 transition-all active:scale-[0.99] active:translate-y-0 relative overflow-hidden group"
        >
          <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />
          <Sparkles className="w-5 h-5 relative z-10" /> 
          <span className="relative z-10">Open Smart Prescription Writer</span>
        </button>
      </div>
    </div>
  );
};