import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Filter, Sparkles, Plus,
  Users, Activity, AlertCircle, DollarSign, LayoutGrid, List, ArrowLeft,
  X, Check, Loader2
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { PatientDrawer } from '../components/PatientDrawer';
import { MinimalCarousel } from '../components/ui/minimal-carousel';
import type { CarouselCard } from '../components/ui/minimal-carousel';
import type { Patient } from '../types/patient';
import { cn } from '../layouts/DashboardLayout';
import { fetchBackendPatients } from '../services/userService';
import { mockPatients } from '../data/mockPatients';
import { CommandSearch } from '../components/ui/command-search';
// ── MinimalCarousel helpers ────────────────────────────────────────────────
const ACTIVE_COLORS = [
  'bg-emerald-500','bg-teal-500','bg-cyan-600','bg-blue-500',
  'bg-violet-500','bg-purple-500','bg-amber-500','bg-pink-500',
];
const nameHash = (name: string) =>
  name.split('').reduce((a, c) => a + c.charCodeAt(0), 0);

const patientColor = (p: Patient): string => {
  if (p.status === 'Critical')  return 'bg-red-500';
  if (p.status === 'Recovered') return 'bg-slate-500';
  return ACTIVE_COLORS[nameHash(p.name) % ACTIVE_COLORS.length];
};

const makeInitialsIcon = (name: string) => {
  const ini = name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
  const Icon = ({ size }: { size?: number; className?: string }) => (
    <span className="font-black text-white select-none" style={{ fontSize: size ? size * 0.45 : 20 }}>
      {ini}
    </span>
  );
  Icon.displayName = `InitialsIcon_${ini}`;
  return Icon;
};

const patientToCard = (p: Patient): CarouselCard => ({
  id:    p.id,
  title: p.name,
  value: `${p.age} yrs • ${p.gender} · ${p.status}`,
  color: patientColor(p),
  icon:  makeInitialsIcon(p.name),
});

// ── Map backend rich patient object → frontend Patient type ─────────────────
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function mapBackendPatient(b: Record<string, any>): Patient {
  return {
    id:            String(b.id ?? ''),
    name:          `${b.first_name ?? ''} ${b.last_name ?? ''}`.trim() || 'Unknown',
    age:           Number(b.age ?? 0),
    gender:        (['Male', 'Female', 'Other'].includes(b.gender) ? b.gender : 'Other') as Patient['gender'],
    status:        (['Active', 'Critical', 'Recovered'].includes(b.status) ? b.status : 'Active') as Patient['status'],
    lastDiagnosis: b.last_diagnosis ?? '',
    lastVisit:     b.last_visit ?? '',
    totalFees:     Number(b.total_fees ?? 0),
    pendingAmount: Number(b.pending_amount ?? 0),
    isFavorite:    Boolean(b.is_favorite),
    riskScore:     Number(b.risk_score ?? 20),
    tags:          Array.isArray(b.tags) ? b.tags : [],
    nextFollowUp:  b.next_follow_up ?? undefined,
    avatar:        b.avatar ?? `https://ui-avatars.com/api/?name=${b.first_name}+${b.last_name}&background=random&color=fff`,
    phone:         b.phone_number ?? '',
    email:         b.email ?? '',
    blood_group:   b.blood_group,
    allergies:     b.allergies,
    chronic_conditions: b.chronic_conditions,
  };
}

// ── Add Patient Form ─────────────────────────────────────────────────────────
const EMPTY_FORM = {
  first_name: '', last_name: '', email: '', phone_number: '',
  age: '', gender: 'Other', status: 'Active', last_diagnosis: '',
};

interface AddPatientModalProps {
  onClose: () => void;
  onAdd: (p: Patient) => void;
}

const AddPatientModal = ({ onClose, onAdd }: AddPatientModalProps) => {
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const set = (k: string, v: string) => setForm(f => ({ ...f, [k]: v }));

  const handleSubmit = async () => {
    if (!form.first_name.trim() || !form.last_name.trim() || !form.email.trim()) {
      setError('First name, last name and email are required.');
      return;
    }
    setSaving(true);
    setError('');

    const payload = {
      ...form,
      age: Number(form.age) || 0,
      total_fees: 0,
      pending_amount: 0,
      risk_score: 20,
      tags: [],
    };

    try {
      const res = await fetch('/api/v1/patients/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      if (res.ok) {
        const created = await res.json();
        onAdd(mapBackendPatient(created));
      } else {
        // Backend not running — create locally
        throw new Error('offline');
      }
    } catch {
      // Offline fallback — create patient client-side
      const localId = `P-${Date.now()}`;
      onAdd(mapBackendPatient({ ...payload, id: localId,
        avatar: `https://ui-avatars.com/api/?name=${form.first_name}+${form.last_name}&background=random&color=fff` }));
    }

    setSaving(false);
    onClose();
  };

  const field = (label: string, key: string, type = 'text', required = false) => (
    <div>
      <label className="block text-xs font-semibold text-slate-600 mb-1.5">
        {label}{required && <span className="text-red-500 ml-0.5">*</span>}
      </label>
      <input
        type={type}
        value={(form as Record<string, string>)[key]}
        onChange={e => set(key, e.target.value)}
        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none transition-colors"
        placeholder={label}
      />
    </div>
  );

  return (
    <div
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:p-4 bg-black/40 backdrop-blur-sm"
      onClick={e => { if (e.target === e.currentTarget) onClose(); }}
    >
      <motion.div
        initial={{ scale: 0.95, opacity: 0, y: 16 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        exit={{ scale: 0.95, opacity: 0, y: 16 }}
        transition={{ type: 'spring', damping: 25, stiffness: 300 }}
        className="bg-white rounded-t-3xl sm:rounded-3xl shadow-2xl w-full sm:max-w-lg overflow-hidden"
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-slate-100">
          <div>
            <h2 className="text-lg font-bold text-slate-800">Add New Patient</h2>
            <p className="text-xs text-slate-500 mt-0.5">Fill in the patient details below</p>
          </div>
          <button onClick={onClose} className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-full transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        <div className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            {field('First Name', 'first_name', 'text', true)}
            {field('Last Name', 'last_name', 'text', true)}
          </div>
          {field('Email', 'email', 'email', true)}
          {field('Phone Number', 'phone_number')}
          <div className="grid grid-cols-2 gap-4">
            {field('Age', 'age', 'number')}
            <div>
              <label className="block text-xs font-semibold text-slate-600 mb-1.5">Gender</label>
              <select
                value={form.gender}
                onChange={e => set('gender', e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none"
              >
                <option>Male</option><option>Female</option><option>Other</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-600 mb-1.5">Status</label>
              <select
                value={form.status}
                onChange={e => set('status', e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none"
              >
                <option>Active</option><option>Critical</option><option>Recovered</option>
              </select>
            </div>
            {field('Initial Diagnosis', 'last_diagnosis')}
          </div>

          {error && <p className="text-xs font-medium text-red-500 bg-red-50 px-3 py-2 rounded-xl">{error}</p>}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-slate-100 bg-slate-50/50">
          <button onClick={onClose} className="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={saving}
            className="flex items-center gap-2 px-5 py-2 bg-slate-800 hover:bg-slate-700 text-white text-sm font-bold rounded-xl transition-colors shadow-sm disabled:opacity-50"
          >
            {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4" />}
            {saving ? 'Adding…' : 'Add Patient'}
          </button>
        </div>
      </motion.div>
    </div>
  );
};

// ── Main Page ────────────────────────────────────────────────────────────────

const PatientsPage = () => {
  const navigate = useNavigate();
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');        
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [showAddModal, setShowAddModal] = useState(false);

  const LS_KEY = 'dp_patients_cache';

  const saveToCache = (list: Patient[]) => {
    try { localStorage.setItem(LS_KEY, JSON.stringify(list)); } catch { /* quota */ }
  };

  const loadFromCache = (): Patient[] | null => {
    try {
      const raw = localStorage.getItem(LS_KEY);
      return raw ? (JSON.parse(raw) as Patient[]) : null;
    } catch { return null; }
  };

  useEffect(() => {
    const loadPatients = async () => {
      const data = await fetchBackendPatients();
      if (data !== null) {
        const mapped = data.map(mapBackendPatient);
        setPatients(mapped);
        saveToCache(mapped);
      } else {
        // Backend unavailable -> try localStorage cache first, then static mocks
        const cached = loadFromCache();
        setPatients(cached && cached.length > 0 ? cached : mockPatients);
      }
    };
    loadPatients();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleAddPatient = (p: Patient) => {
    setPatients(prev => {
      const next = [p, ...prev];
      saveToCache(next);
      return next;
    });
  };

  const filtered = patients.filter(p =>
    searchQuery.trim() === '' ||
    p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.lastDiagnosis.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.tags.some(t => t.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  // Stats Data
  const stats = [
    { label: 'Total Patients', value: patients.length.toString(), icon: Users, color: 'text-brand-blue', bg: 'bg-brand-blue/10' },
    { label: 'Active Cases', value: patients.filter(p => p.status === 'Active').length.toString(), icon: Activity, color: 'text-emerald-600', bg: 'bg-emerald-500/10' },
    { label: 'Critical', value: patients.filter(p => p.status === 'Critical').length.toString(), icon: AlertCircle, color: 'text-red-500', bg: 'bg-red-500/10' },
    { label: 'Total Earnings', value: '$' + patients.reduce((acc, p) => acc + p.totalFees, 0).toLocaleString(), icon: DollarSign, color: 'text-amber-500', bg: 'bg-amber-500/10' },
  ];

  return (
    <div className="w-full animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20 md:pb-0">
      
      {/* Top Bar (Smart Control Panel) */}
      <div className="sticky top-0 z-20 bg-white/70 backdrop-blur-2xl py-5 -mx-4 px-4 md:-mx-8 md:px-8 mb-8 border-b border-slate-200/50 flex flex-col xl:flex-row gap-5 justify-between items-start xl:items-center shadow-sm">
         
         {/* Search & Voice */}
           <div className="flex-1 w-full xl:max-w-2xl relative flex items-center gap-4">
              <button 
                onClick={() => navigate(-1)} 
                className="p-3 bg-white hover:bg-slate-50 flex-shrink-0 rounded-2xl text-slate-700 transition-all shadow-sm border border-slate-200/60 hover:border-slate-300"
                title="Go Back"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <CommandSearch 
                value={searchQuery} 
                onChange={setSearchQuery} 
              />
           </div>

           {/* Actions & Filters */}
           <div className="flex w-full xl:w-auto items-center justify-between gap-3 overflow-x-auto pb-2 xl:pb-0 hide-scrollbar">

              <button onClick={() => alert("Filters modal coming soon")} className="flex items-center whitespace-nowrap bg-white border border-slate-200 hover:border-slate-300 hover:bg-slate-50 text-slate-700 text-[15px] font-semibold px-5 py-3.5 rounded-2xl transition-all shadow-sm">
                <Filter className="w-4 h-4 mr-2.5 text-slate-500" /> Filters
              </button>

              <button onClick={() => alert("AI filters processing...")} className="flex items-center whitespace-nowrap bg-gradient-to-r from-indigo-50 to-purple-50 hover:from-indigo-100 hover:to-purple-100 border border-indigo-100 text-indigo-700 text-[15px] font-semibold px-5 py-3.5 rounded-2xl transition-all shadow-sm">
                <Sparkles className="w-4 h-4 mr-2.5 text-indigo-500" /> Smart Filter
              </button>

              <div className="h-8 w-px bg-slate-200/80 mx-2 hidden md:block"></div>

              {/* View Toggles */}
              <div className="hidden md:flex bg-white border border-slate-200/80 p-1.5 rounded-2xl shadow-sm gap-1">
                 <button 
                   onClick={() => setViewMode('grid')}
                   className={cn("p-2.5 rounded-xl transition-all", viewMode === 'grid' ? "bg-slate-100/80 text-slate-900 shadow-sm" : "text-slate-400 hover:text-slate-600 hover:bg-slate-50")}
                 >
                   <LayoutGrid className="w-4 h-4" />
                 </button>
                 <button 
                   onClick={() => setViewMode('table')}
                   className={cn("p-2.5 rounded-xl transition-all", viewMode === 'table' ? "bg-slate-100/80 text-slate-900 shadow-sm" : "text-slate-400 hover:text-slate-600 hover:bg-slate-50")}
                 >
                   <List className="w-4 h-4" />
                 </button>
              </div>

            <button
              onClick={() => setShowAddModal(true)}
              className="flex items-center whitespace-nowrap bg-slate-800 hover:bg-slate-700 active:scale-95 text-white text-[15px] font-semibold px-6 py-3.5 rounded-2xl transition-all shadow-lg shadow-slate-800/20"
            >
              <Plus className="w-5 h-5 mr-2" /> New Patient
            </button>
         </div>
      </div>

      {/* Mini Analytics */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-6 sm:mb-8">
        {stats.map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.07 }}
            className="bg-white rounded-2xl sm:rounded-3xl p-4 sm:p-5 shadow-sm border border-slate-100 hover:shadow-md hover:border-slate-200 transition-all cursor-default group overflow-hidden relative"
          >
            <div className="absolute top-0 right-0 w-24 h-24 rounded-full opacity-5 -translate-y-8 translate-x-8" style={{ background: 'currentColor' }} />
            <div className="flex items-start justify-between mb-3">
              <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center shrink-0 transition-transform group-hover:scale-110", stat.bg, stat.color)}>
                <stat.icon className="w-5 h-5" />
              </div>
              <div className={cn("w-2 h-2 rounded-full", stat.bg)} />
            </div>
            <h3 className="text-2xl sm:text-3xl font-black text-slate-800 tracking-tight leading-none mb-1">{stat.value}</h3>
            <p className="text-xs sm:text-[13px] text-slate-400 font-semibold">{stat.label}</p>
          </motion.div>
        ))}
      </div>

      {/* AI Insights Banner */}
      <motion.div 
        initial={{ y: 10, opacity: 0 }} 
        animate={{ y: 0, opacity: 1 }} 
        className="bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-900 rounded-3xl p-5 md:p-6 mb-10 shadow-xl shadow-indigo-900/10 flex flex-col md:flex-row items-start md:items-center justify-between gap-4 border border-slate-800"
      >
        <div className="flex items-start md:items-center text-white">
           <div className="bg-white/10 p-3 rounded-2xl mr-4 hidden md:block backdrop-blur-md border border-white/10 shadow-inner">
             <Sparkles className="w-6 h-6 text-indigo-300" />
           </div>
           <div>
             <h4 className="font-bold text-base md:text-lg flex items-center mb-1">
               AI Health Insights <span className="ml-3 bg-indigo-500/80 backdrop-blur-md text-white border border-indigo-400/50 text-[10px] px-2.5 py-1 rounded-lg uppercase tracking-wider font-bold shadow-sm">Update</span>
             </h4>
             <p className="text-indigo-200/80 text-sm font-medium leading-relaxed max-w-2xl">3 patients need urgent follow-up today. Michael Johnson's latest reports show elevated risks based on recent lab processing.</p>
           </div>
        </div>
        <button onClick={() => navigate("/emergency")} className="bg-white text-slate-900 text-sm font-bold px-6 py-3 rounded-2xl shadow-lg hover:bg-indigo-50 hover:shadow-xl hover:-translate-y-0.5 transition-all whitespace-nowrap w-full md:w-auto">
          Review Cases
        </button>
      </motion.div>

      {/* Patient List Title */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <h2 className="text-xl font-black text-slate-800 flex items-center gap-2">
            Patient Directory
            <span className="bg-emerald-100 text-emerald-700 font-bold px-2.5 py-0.5 rounded-full text-xs">
              {filtered.length} active
            </span>
            {searchQuery && <span className="text-xs text-slate-400 font-normal">for "{searchQuery}"</span>}
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">Click any card to expand &amp; view actions</p>
        </div>
      </div>

      {/* Patients Grid/Table */}
      {viewMode === 'grid' ? (
        filtered.length === 0 ? (
          <div className="text-center py-20 text-slate-400">
            <Users className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p className="font-semibold">No patients found</p>
          </div>
        ) : (
          <MinimalCarousel
            cards={filtered.map(patientToCard)}
            copyLabel="View Details"
            customizeLabel="Consult"
            onCopyClick={card => {
              const p = filtered.find(x => x.id === card.id);
              if (p) setSelectedPatient(p);
            }}
            onCustomizeClick={card => navigate(`/dashboard/case?patient=${card.id}`)}
          />
        )
      ) : (
        <div className="bg-white/80 backdrop-blur-md rounded-3xl shadow-sm border border-slate-200/60 overflow-hidden">
           <div className="overflow-x-auto">
             <table className="w-full text-left border-collapse">
               <thead>
                 <tr className="bg-slate-50/50 border-b border-slate-200/60 text-xs uppercase tracking-wider text-slate-500">
                   <th className="p-5 font-bold">Patient</th>
                   <th className="p-5 font-bold">Status</th>
                   <th className="p-5 font-bold hidden md:table-cell">Diagnosis</th>
                   <th className="p-5 font-bold hidden lg:table-cell">Last Visit</th>
                   <th className="p-5 font-bold">Risk Score</th>
                   <th className="p-5 font-bold text-right">Actions</th>
                 </tr>
               </thead>
               <tbody className="divide-y divide-slate-100">
                 {filtered.map(patient => (
                   <tr key={patient.id} className="hover:bg-blue-50/30 transition-colors group cursor-pointer" onClick={() => setSelectedPatient(patient)}>
                     <td className="p-5">
                       <div className="flex items-center gap-4">
                         <div className={`w-12 h-12 rounded-2xl flex items-center justify-center font-black text-white text-sm select-none bg-slate-400`} style={{ background: `hsl(${patient.name.split('').reduce((a,c)=>a+c.charCodeAt(0),0) % 360},55%,58%)` }}>{patient.name.split(' ').map(n=>n[0]).join('').slice(0,2).toUpperCase()}</div>
                         <div>
                           <p className="font-bold text-slate-800 group-hover:text-brand-blue transition-colors text-[15px]">{patient.name}</p>
                           <p className="text-xs font-medium text-slate-500 mt-0.5">{patient.age} y/o • {patient.gender}</p>
                         </div>
                       </div>
                     </td>
                     <td className="p-5">
                       <span className={cn(
                          "px-3 py-1.5 rounded-xl text-xs font-semibold tracking-wide",
                          patient.status === 'Critical' ? "bg-red-100 text-red-700" :
                          patient.status === 'Recovered' ? "bg-slate-100 text-slate-600" : "bg-emerald-100 text-emerald-700"
                        )}>
                          {patient.status}
                        </span>
                     </td>
                     <td className="p-5 hidden md:table-cell text-[14px] font-medium text-slate-600">
                       <div className="flex items-center gap-2">
                         <div className="w-8 h-8 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center">
                           <Activity className="w-4 h-4 text-slate-400" />
                         </div>
                         {patient.lastDiagnosis}
                       </div>
                     </td>
                     <td className="p-5 hidden lg:table-cell text-[14px] font-medium text-slate-600">{patient.lastVisit}</td>
                     <td className="p-5">
                        <div className="flex items-center gap-3">
                           <div className="w-24 h-2 bg-slate-100 rounded-full overflow-hidden shadow-inner">
                             <div 
                               className={cn("h-full rounded-full transition-all duration-1000", patient.riskScore > 75 ? "bg-gradient-to-r from-red-400 to-red-500" : patient.riskScore > 40 ? "bg-gradient-to-r from-amber-400 to-amber-500" : "bg-gradient-to-r from-emerald-400 to-emerald-500")}
                               style={{ width: `${patient.riskScore}%` }}
                             />
                           </div>
                           <span className="text-[13px] font-bold text-slate-600">{patient.riskScore}</span>
                        </div>
                     </td>
                     <td className="p-5 text-right">
                       <button onClick={(e) => { e.stopPropagation(); setSelectedPatient(patient); }} className="text-brand-blue bg-blue-50 hover:bg-brand-blue hover:text-white px-4 py-2 rounded-xl text-[13px] font-bold transition-colors">Review</button>
                     </td>
                   </tr>
                 ))}
               </tbody>
             </table>
           </div>
        </div>
      )}

      {/* Drawer Overlay */}
      <PatientDrawer 
        isOpen={selectedPatient !== null} 
        onClose={() => setSelectedPatient(null)} 
        patient={selectedPatient} 
      />

      {/* Add Patient Modal */}
      <AnimatePresence>
        {showAddModal && (
          <AddPatientModal
            onClose={() => setShowAddModal(false)}
            onAdd={handleAddPatient}
          />
        )}
      </AnimatePresence>

    </div>
  );
};

export default PatientsPage;