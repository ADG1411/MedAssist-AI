import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  User, Building2, Calendar, DollarSign, Star, FileText, Settings,
  ChevronRight, ChevronLeft, Check, Upload, Plus, Trash2, Copy,
  Sparkles, Loader2, Shield, Globe,
  CheckCircle2, AlertCircle, Camera
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { motion, AnimatePresence } from 'framer-motion';
import {
  getProfile, saveProfile, submitProfile, generateBio,
  type DoctorProfile, type Workplace, type DocDocument
} from '../services/doctorProfileService';

// ── Tab Config ──────────────────────────────────────────────────────────────

const TABS = [
  { id: 'overview',     label: 'Overview',      icon: User        },
  { id: 'workplaces',   label: 'Workplaces',    icon: Building2   },
  { id: 'availability', label: 'Availability',  icon: Calendar    },
  { id: 'fees',         label: 'Fees & Pricing',icon: DollarSign  },
  { id: 'reviews',      label: 'Reviews',       icon: Star        },
  { id: 'documents',    label: 'Documents',     icon: FileText    },
  { id: 'settings',     label: 'Settings',      icon: Settings    },
];

const DAYS = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'] as const;
const SPECIALIZATIONS = ['Cardiology','Dermatology','Endocrinology','Gastroenterology','General Medicine','Neurology','Oncology','Ophthalmology','Orthopedics','Pediatrics','Psychiatry','Pulmonology','Radiology','Surgery','Urology'];
const DEGREES = ['MBBS','MD','MS','DM','MCh','DNB','BDS','MDS','BAMS','BHMS','PhD'];
const LANGUAGES = ['English','Hindi','Bengali','Tamil','Telugu','Marathi','Gujarati','Kannada','Malayalam','Punjabi','Urdu'];

// ── Helpers ─────────────────────────────────────────────────────────────────

const emptyWorkplace = (): Workplace => ({ id: crypto.randomUUID(), name: '', type: 'hospital', position: 'consultant', location: '', working_hours: '', is_primary: false });

const STATUS_COLORS: Record<string, string> = {
  incomplete: 'bg-amber-100 text-amber-700 border-amber-200',
  pending: 'bg-blue-100 text-blue-700 border-blue-200',
  approved: 'bg-emerald-100 text-emerald-700 border-emerald-200',
};

// ── Page ────────────────────────────────────────────────────────────────────

export default function DoctorProfileSetup() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('overview');
  const [profile, setProfile] = useState<DoctorProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [submitMsg, setSubmitMsg] = useState('');
  const [bioGenerating, setBioGenerating] = useState(false);
  const [autoSaveTimer, setAutoSaveTimer] = useState<ReturnType<typeof setTimeout> | null>(null);

  // Load profile
  useEffect(() => {
    getProfile()
      .then(setProfile)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  // Auto-save debounce
  const triggerAutoSave = useCallback((data: DoctorProfile) => {
    if (autoSaveTimer) clearTimeout(autoSaveTimer);
    const t = setTimeout(async () => {
      try {
        const saved = await saveProfile(data);
        setProfile(prev => prev ? { ...prev, completion_percent: saved.completion_percent, verification_status: saved.verification_status } : saved);
      } catch (e) { console.error('Auto-save failed:', e); }
    }, 2000);
    setAutoSaveTimer(t);
  }, [autoSaveTimer]);

  const updateProfile = (patch: Partial<DoctorProfile>) => {
    if (!profile) return;
    const updated = { ...profile, ...patch } as DoctorProfile;
    setProfile(updated);
    triggerAutoSave(updated);
  };

  const handleSave = async () => {
    if (!profile) return;
    setSaving(true);
    try {
      const saved = await saveProfile(profile);
      setProfile(saved);
    } catch (e) { console.error(e); }
    finally { setSaving(false); }
  };

  const handleSubmit = async () => {
    await handleSave();
    try {
      const result = await submitProfile();
      if (result.error) {
        setSubmitMsg(result.error);
      } else {
        setSubmitMsg(result.message || 'Profile submitted!');
        if (profile) setProfile({ ...profile, verification_status: 'pending' });
        
        // Navigate to dashboard after showing success message
        setTimeout(() => {
          navigate('/dashboard');
        }, 1500);
      }
    } catch {
      setSubmitMsg('Failed to submit. Please try again.');
    }
    // Only clear the message if we didn't navigate away, but since we are navigating, 
    // it's harmless or we can just leave it as is or clear it earlier.
    setTimeout(() => setSubmitMsg(''), 5000);
  };

  const handleGenerateBio = async () => {
    if (!profile) return;
    setBioGenerating(true);
    try {
      const bio = await generateBio({
        full_name: profile.overview.full_name,
        specialization: profile.overview.specialization,
        degree: profile.overview.degree,
        years_of_experience: profile.overview.years_of_experience,
        city: profile.overview.city,
      });
      updateProfile({ overview: { ...profile.overview, bio } });
    } catch (e) { console.error(e); }
    finally { setBioGenerating(false); }
  };

  const tabIdx = TABS.findIndex(t => t.id === activeTab);
  const goNext = () => { if (tabIdx < TABS.length - 1) setActiveTab(TABS[tabIdx + 1].id); };
  const goPrev = () => { if (tabIdx > 0) setActiveTab(TABS[tabIdx - 1].id); };

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <Loader2 className="w-8 h-8 animate-spin text-brand-blue" />
    </div>
  );

  if (!profile) return (
    <div className="flex flex-col items-center justify-center h-full text-center py-20">
      <AlertCircle className="w-12 h-12 text-red-400 mb-4" />
      <h2 className="text-lg font-bold text-slate-800">Failed to load profile</h2>
      <p className="text-sm text-slate-500 mt-1">Please try refreshing the page or check your connection.</p>
    </div>
  );

  const pct = profile.completion_percent;

  // ── RENDER ─────────────────────────────────────────────────────────────────

  return (
    <div className="w-full animate-in fade-in duration-500 pb-32 md:pb-20">

      {/* Header + Completion */}
      <div className="mb-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
          <div>
            <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Profile Setup</h1>
            <p className="text-sm text-slate-500 font-medium mt-0.5">Complete your profile to start accepting patients</p>
          </div>
          <div className="flex items-center gap-3 shrink-0">
            <span className={cn('text-[11px] font-bold px-3 py-1.5 rounded-lg border', STATUS_COLORS[profile.verification_status] || STATUS_COLORS.incomplete)}>
              {profile.verification_status === 'incomplete' ? '⚠ Incomplete' : profile.verification_status === 'pending' ? '⏳ Pending Review' : '✓ Approved'}
            </span>
          </div>
        </div>

        {/* Completion Bar */}
        <div className="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-bold text-slate-700">Profile Completion</span>
            <span className="text-sm font-black text-brand-blue">{pct}%</span>
          </div>
          <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden">
            <motion.div
              className={cn('h-full rounded-full', pct >= 80 ? 'bg-emerald-500' : pct >= 50 ? 'bg-blue-500' : 'bg-amber-500')}
              initial={{ width: 0 }}
              animate={{ width: `${pct}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
            />
          </div>
          {pct < 100 && (
            <p className="text-[11px] text-slate-400 font-medium mt-2">
              {pct < 30 ? '📋 Fill in your basic details to get started' :
               pct < 60 ? '🏥 Add workplaces and set your availability' :
               pct < 80 ? '📄 Upload your medical license to proceed' :
               '✨ Almost there! Review and submit'}
            </p>
          )}
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1.5 overflow-x-auto hide-scrollbar pb-1 mb-6">
        {TABS.map((tab, i) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                'flex items-center gap-2 px-3 sm:px-4 py-2.5 rounded-xl text-[12px] sm:text-[13px] font-bold transition-all whitespace-nowrap shrink-0',
                isActive ? 'bg-brand-blue text-white shadow-md shadow-blue-200' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50',
              )}
            >
              <Icon className="w-4 h-4" />
              <span className="hidden xs:inline sm:inline">{tab.label}</span>
              <span className="xs:hidden sm:hidden">{i + 1}</span>
            </button>
          );
        })}
      </div>

      {/* Tab Content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -8 }}
          transition={{ duration: 0.2 }}
        >
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 sm:p-8">

            {/* ── OVERVIEW TAB ── */}
            {activeTab === 'overview' && (
              <div className="space-y-6">
                <h2 className="text-lg font-black text-slate-800">Basic Details</h2>

                {/* Photo + Name row */}
                <div className="flex flex-col sm:flex-row gap-6">
                  <div className="shrink-0">
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-2">Profile Photo</label>
                    <div className="relative group">
                      <div className="w-28 h-28 rounded-2xl bg-slate-100 border-2 border-dashed border-slate-300 flex items-center justify-center overflow-hidden">
                        {profile.overview.profile_photo ? (
                          <img src={profile.overview.profile_photo} alt="Profile" className="w-full h-full object-cover" />
                        ) : (
                          <Camera className="w-8 h-8 text-slate-300" />
                        )}
                      </div>
                      <label className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity rounded-2xl cursor-pointer">
                        <Upload className="w-5 h-5 text-white" />
                        <input type="file" accept="image/*" className="hidden" onChange={(e) => {
                          const file = e.target.files?.[0];
                          if (file) {
                            const reader = new FileReader();
                            reader.onload = () => updateProfile({ overview: { ...profile.overview, profile_photo: reader.result as string } });
                            reader.readAsDataURL(file);
                          }
                        }} />
                      </label>
                    </div>
                  </div>

                  <div className="flex-1 space-y-4">
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">Full Name *</label>
                      <input value={profile.overview.full_name} onChange={e => updateProfile({ overview: { ...profile.overview, full_name: e.target.value } })}
                        className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" placeholder="Dr. John Smith" />
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">Specialization *</label>
                        <select value={profile.overview.specialization} onChange={e => updateProfile({ overview: { ...profile.overview, specialization: e.target.value } })}
                          className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none bg-white">
                          <option value="">Select...</option>
                          {SPECIALIZATIONS.map(s => <option key={s} value={s}>{s}</option>)}
                        </select>
                      </div>
                      <div>
                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">Degree *</label>
                        <select value={profile.overview.degree} onChange={e => updateProfile({ overview: { ...profile.overview, degree: e.target.value } })}
                          className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none bg-white">
                          <option value="">Select...</option>
                          {DEGREES.map(d => <option key={d} value={d}>{d}</option>)}
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">Years of Experience *</label>
                    <input type="number" min={0} max={60} value={profile.overview.years_of_experience} onChange={e => updateProfile({ overview: { ...profile.overview, years_of_experience: parseInt(e.target.value) || 0 } })}
                      className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">City *</label>
                    <input value={profile.overview.city} onChange={e => updateProfile({ overview: { ...profile.overview, city: e.target.value } })}
                      className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" placeholder="Mumbai" />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide mb-1.5">Languages Spoken</label>
                  <div className="flex flex-wrap gap-2">
                    {LANGUAGES.map(lang => (
                      <button key={lang} onClick={() => {
                        const langs = profile.overview.languages.includes(lang)
                          ? profile.overview.languages.filter(l => l !== lang)
                          : [...profile.overview.languages, lang];
                        updateProfile({ overview: { ...profile.overview, languages: langs } });
                      }} className={cn(
                        'px-3 py-1.5 rounded-lg text-[12px] font-bold border transition-all',
                        profile.overview.languages.includes(lang) ? 'bg-brand-blue text-white border-blue-500' : 'bg-white text-slate-600 border-slate-200 hover:border-slate-300'
                      )}>
                        {lang}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wide">Professional Bio *</label>
                    <button onClick={handleGenerateBio} disabled={bioGenerating} className="flex items-center gap-1.5 text-[11px] font-bold text-indigo-600 hover:text-indigo-700 disabled:opacity-50">
                      {bioGenerating ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Sparkles className="w-3.5 h-3.5" />}
                      AI Suggest Bio
                    </button>
                  </div>
                  <textarea value={profile.overview.bio} onChange={e => updateProfile({ overview: { ...profile.overview, bio: e.target.value } })}
                    rows={4} className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none resize-none"
                    placeholder="Write a professional bio or click 'AI Suggest Bio' to auto-generate..." />
                </div>
              </div>
            )}

            {/* ── WORKPLACES TAB ── */}
            {activeTab === 'workplaces' && (
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg font-black text-slate-800">Workplaces</h2>
                  <button onClick={() => updateProfile({ workplaces: [...profile.workplaces, emptyWorkplace()] })}
                    className="flex items-center gap-1.5 bg-brand-blue text-white text-[12px] font-bold px-3 py-2 rounded-xl hover:bg-blue-700 transition-colors">
                    <Plus className="w-4 h-4" /> Add Workplace
                  </button>
                </div>

                {profile.workplaces.length === 0 ? (
                  <div className="text-center py-12 text-slate-400">
                    <Building2 className="w-12 h-12 mx-auto mb-3 opacity-30" />
                    <p className="text-sm font-bold">No workplaces added</p>
                    <p className="text-xs">Add your hospital or clinic</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {profile.workplaces.map((wp, i) => (
                      <div key={wp.id} className={cn('border rounded-2xl p-5 space-y-4 transition-all', wp.is_primary ? 'border-blue-300 bg-blue-50/30' : 'border-slate-200')}>
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            {wp.is_primary && <span className="text-[10px] font-bold bg-blue-100 text-blue-700 px-2 py-0.5 rounded-md">PRIMARY</span>}
                            <span className="text-sm font-bold text-slate-600">Workplace {i + 1}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            {!wp.is_primary && (
                              <button onClick={() => {
                                const updated = profile.workplaces.map((w, j) => ({ ...w, is_primary: j === i }));
                                updateProfile({ workplaces: updated });
                              }} className="text-[11px] font-bold text-blue-600 hover:underline">Set Primary</button>
                            )}
                            <button onClick={() => updateProfile({ workplaces: profile.workplaces.filter((_, j) => j !== i) })}
                              className="p-1.5 text-slate-400 hover:text-red-500 rounded-lg hover:bg-red-50 transition-colors">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <input value={wp.name} onChange={e => { const wps = [...profile.workplaces]; wps[i] = { ...wps[i], name: e.target.value }; updateProfile({ workplaces: wps }); }}
                            className="border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" placeholder="Hospital / Clinic Name" />
                          <select value={wp.type} onChange={e => { const wps = [...profile.workplaces]; wps[i] = { ...wps[i], type: e.target.value }; updateProfile({ workplaces: wps }); }}
                            className="border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none bg-white">
                            <option value="hospital">Hospital</option>
                            <option value="private_clinic">Private Clinic</option>
                          </select>
                          <select value={wp.position} onChange={e => { const wps = [...profile.workplaces]; wps[i] = { ...wps[i], position: e.target.value }; updateProfile({ workplaces: wps }); }}
                            className="border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none bg-white">
                            <option value="consultant">Consultant</option>
                            <option value="surgeon">Surgeon</option>
                            <option value="owner">Owner</option>
                          </select>
                          <input value={wp.location} onChange={e => { const wps = [...profile.workplaces]; wps[i] = { ...wps[i], location: e.target.value }; updateProfile({ workplaces: wps }); }}
                            className="border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" placeholder="Location / Address" />
                        </div>
                        <input value={wp.working_hours} onChange={e => { const wps = [...profile.workplaces]; wps[i] = { ...wps[i], working_hours: e.target.value }; updateProfile({ workplaces: wps }); }}
                          className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" placeholder="Working Hours (e.g. Mon-Fri 9 AM - 5 PM)" />
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* ── AVAILABILITY TAB ── */}
            {activeTab === 'availability' && (
              <div className="space-y-6">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <h2 className="text-lg font-black text-slate-800">Weekly Schedule</h2>
                  <div className="flex items-center gap-3">
                    <label className="text-xs font-bold text-slate-500 uppercase">Slot Duration</label>
                    <select value={profile.availability.slot_duration} onChange={e => updateProfile({ availability: { ...profile.availability, slot_duration: parseInt(e.target.value) } })}
                      className="border border-slate-200 rounded-xl px-3 py-2 text-sm font-medium bg-white focus:ring-2 focus:ring-brand-blue/20 outline-none">
                      <option value={15}>15 min</option>
                      <option value={30}>30 min</option>
                    </select>
                  </div>
                </div>

                <div className="space-y-3">
                  {DAYS.map((day) => {
                    const sched = profile.availability[day];
                    return (
                      <div key={day} className={cn('flex flex-col sm:flex-row sm:items-center gap-3 p-4 rounded-xl border transition-all', sched.enabled ? 'border-blue-200 bg-blue-50/30' : 'border-slate-200 bg-slate-50/50')}>
                        <div className="flex items-center gap-3 w-full sm:w-32 shrink-0">
                          <button onClick={() => {
                            const updated = { ...profile.availability, [day]: { ...sched, enabled: !sched.enabled } };
                            updateProfile({ availability: updated });
                          }} className={cn('w-10 h-5 rounded-full relative transition-colors', sched.enabled ? 'bg-brand-blue' : 'bg-slate-300')}>
                            <div className={cn('w-5 h-5 bg-white rounded-full shadow border border-slate-200 absolute top-0 transition-transform', sched.enabled ? 'translate-x-5' : 'translate-x-0')} />
                          </button>
                          <span className="text-sm font-bold text-slate-700 capitalize">{day}</span>
                        </div>

                        {sched.enabled && (
                          <div className="flex flex-wrap items-center gap-2 sm:gap-3 flex-1">
                            <div className="flex items-center gap-1.5">
                              <label className="text-[10px] font-bold text-slate-400 uppercase">Start</label>
                              <input type="time" value={sched.start_time} onChange={e => updateProfile({ availability: { ...profile.availability, [day]: { ...sched, start_time: e.target.value } } })}
                                className="border border-slate-200 rounded-lg px-2 py-1.5 text-xs font-medium" />
                            </div>
                            <div className="flex items-center gap-1.5">
                              <label className="text-[10px] font-bold text-slate-400 uppercase">End</label>
                              <input type="time" value={sched.end_time} onChange={e => updateProfile({ availability: { ...profile.availability, [day]: { ...sched, end_time: e.target.value } } })}
                                className="border border-slate-200 rounded-lg px-2 py-1.5 text-xs font-medium" />
                            </div>
                            <div className="flex items-center gap-1.5">
                              <label className="text-[10px] font-bold text-slate-400 uppercase">Break</label>
                              <input type="time" value={sched.break_start} onChange={e => updateProfile({ availability: { ...profile.availability, [day]: { ...sched, break_start: e.target.value } } })}
                                className="border border-slate-200 rounded-lg px-2 py-1.5 text-xs font-medium" />
                              <span className="text-slate-400 text-xs">—</span>
                              <input type="time" value={sched.break_end} onChange={e => updateProfile({ availability: { ...profile.availability, [day]: { ...sched, break_end: e.target.value } } })}
                                className="border border-slate-200 rounded-lg px-2 py-1.5 text-xs font-medium" />
                            </div>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>

                <button onClick={() => {
                  const monday = profile.availability.monday;
                  const filled: any = {};
                  DAYS.forEach(d => { filled[d] = { ...monday }; });
                  updateProfile({ availability: { ...profile.availability, ...filled } });
                }} className="flex items-center gap-2 text-[12px] font-bold text-brand-blue hover:underline">
                  <Copy className="w-3.5 h-3.5" /> Copy Monday to all days
                </button>
              </div>
            )}

            {/* ── FEES TAB ── */}
            {activeTab === 'fees' && (
              <div className="space-y-6">
                <h2 className="text-lg font-black text-slate-800">Fees & Pricing</h2>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
                  {[
                    { label: 'Online Consultation', key: 'online_fee' as const, icon: Globe, color: 'text-blue-500 bg-blue-50' },
                    { label: 'Offline Visit', key: 'offline_fee' as const, icon: Building2, color: 'text-emerald-500 bg-emerald-50' },
                    { label: 'Emergency', key: 'emergency_fee' as const, icon: AlertCircle, color: 'text-red-500 bg-red-50' },
                  ].map(f => (
                    <div key={f.key} className="border border-slate-200 rounded-2xl p-5 space-y-3">
                      <div className="flex items-center gap-3">
                        <div className={cn('p-2 rounded-xl', f.color)}><f.icon className="w-5 h-5" /></div>
                        <span className="text-sm font-bold text-slate-700">{f.label}</span>
                      </div>
                      <div className="relative">
                        <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 font-bold text-sm">₹</span>
                        <input type="number" min={0} value={profile.fees[f.key]} onChange={e => updateProfile({ fees: { ...profile.fees, [f.key]: parseFloat(e.target.value) || 0 } })}
                          className="w-full border border-slate-200 rounded-xl pl-8 pr-4 py-3 text-lg font-black text-slate-800 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none" />
                      </div>
                    </div>
                  ))}
                </div>

                <div className="flex flex-col sm:flex-row gap-4 p-5 border border-slate-200 rounded-2xl">
                  <div className="flex items-center gap-3 flex-1">
                    <button onClick={() => updateProfile({ fees: { ...profile.fees, free_consultation: !profile.fees.free_consultation } })}
                      className={cn('w-10 h-5 rounded-full relative transition-colors', profile.fees.free_consultation ? 'bg-emerald-500' : 'bg-slate-300')}>
                      <div className={cn('w-5 h-5 bg-white rounded-full shadow border absolute top-0 transition-transform', profile.fees.free_consultation ? 'translate-x-5' : 'translate-x-0')} />
                    </button>
                    <div>
                      <p className="text-sm font-bold text-slate-700">Free First Consultation</p>
                      <p className="text-[11px] text-slate-400">Waive fee for new patients' first visit</p>
                    </div>
                  </div>
                  <div className="sm:w-40">
                    <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Discount %</label>
                    <input type="number" min={0} max={100} value={profile.fees.discount_percent} onChange={e => updateProfile({ fees: { ...profile.fees, discount_percent: parseFloat(e.target.value) || 0 } })}
                      className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm font-bold focus:ring-2 focus:ring-brand-blue/20 outline-none" />
                  </div>
                </div>
              </div>
            )}

            {/* ── REVIEWS TAB ── */}
            {activeTab === 'reviews' && (
              <div className="text-center py-16">
                <div className="w-20 h-20 rounded-2xl bg-amber-50 border border-amber-100 flex items-center justify-center mx-auto mb-4">
                  <Star className="w-10 h-10 text-amber-400" />
                </div>
                <h2 className="text-lg font-black text-slate-800 mb-2">Reviews Coming Soon</h2>
                <p className="text-sm text-slate-500 font-medium max-w-sm mx-auto">Patient reviews will appear here after your first consultations. Complete your profile to get started!</p>
              </div>
            )}

            {/* ── DOCUMENTS TAB ── */}
            {activeTab === 'documents' && (
              <div className="space-y-6">
                <h2 className="text-lg font-black text-slate-800">Verification Documents</h2>
                <p className="text-sm text-slate-500 -mt-3">Upload required documents for profile verification</p>

                {[
                  { type: 'license', label: 'Medical License', required: true, desc: 'Your registration certificate from the medical council' },
                  { type: 'degree', label: 'Degree Certificate', required: false, desc: 'MBBS, MD, or equivalent degree certificate' },
                  { type: 'id_proof', label: 'ID Proof', required: false, desc: 'Government-issued photo ID (Aadhar, Passport, etc.)' },
                ].map(docType => {
                  const existing = profile.documents.find(d => d.type === docType.type);
                  return (
                    <div key={docType.type} className={cn('border rounded-2xl p-5 transition-all', existing ? 'border-emerald-200 bg-emerald-50/30' : 'border-slate-200')}>
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex items-start gap-3">
                          <div className={cn('p-2.5 rounded-xl shrink-0', existing ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-400')}>
                            {existing ? <CheckCircle2 className="w-5 h-5" /> : <FileText className="w-5 h-5" />}
                          </div>
                          <div>
                            <p className="text-sm font-bold text-slate-800">
                              {docType.label}
                              {docType.required && <span className="text-red-500 ml-1">*</span>}
                            </p>
                            <p className="text-[11px] text-slate-400 mt-0.5">{docType.desc}</p>
                            {existing && (
                              <p className="text-[11px] text-emerald-600 font-bold mt-1">✓ {existing.file_name}</p>
                            )}
                          </div>
                        </div>

                        <div className="flex items-center gap-2 shrink-0">
                          {existing && (
                            <button onClick={() => updateProfile({ documents: profile.documents.filter(d => d.type !== docType.type) })}
                              className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-colors">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          )}
                          <label className="flex items-center gap-1.5 bg-white border border-slate-200 text-slate-700 text-[12px] font-bold px-3 py-2 rounded-xl hover:bg-slate-50 cursor-pointer transition-colors">
                            <Upload className="w-3.5 h-3.5" />
                            {existing ? 'Replace' : 'Upload'}
                            <input type="file" accept=".pdf,.jpg,.jpeg,.png" className="hidden" onChange={(e) => {
                              const file = e.target.files?.[0];
                              if (file) {
                                const reader = new FileReader();
                                reader.onload = () => {
                                  const newDoc: DocDocument = {
                                    id: crypto.randomUUID(),
                                    name: docType.label,
                                    type: docType.type,
                                    file_url: reader.result as string,
                                    file_name: file.name,
                                    uploaded_at: new Date().toISOString(),
                                    status: 'pending',
                                  };
                                  const docs = profile.documents.filter(d => d.type !== docType.type);
                                  docs.push(newDoc);
                                  updateProfile({ documents: docs });
                                };
                                reader.readAsDataURL(file);
                              }
                            }} />
                          </label>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}

            {/* ── SETTINGS TAB ── */}
            {activeTab === 'settings' && (
              <div className="space-y-6">
                <h2 className="text-lg font-black text-slate-800">Preferences</h2>

                <div className="space-y-4">
                  <h3 className="text-sm font-bold text-slate-600 uppercase tracking-wide">Notifications</h3>
                  {[
                    { key: 'email_notifications' as const, label: 'Email Notifications', desc: 'Receive appointment and system updates via email' },
                    { key: 'sms_notifications' as const, label: 'SMS Notifications', desc: 'Get text alerts for urgent matters' },
                    { key: 'push_notifications' as const, label: 'Push Notifications', desc: 'Browser push notifications for real-time alerts' },
                  ].map(item => (
                    <div key={item.key} className="flex items-center justify-between p-4 border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors">
                      <div>
                        <p className="text-sm font-bold text-slate-700">{item.label}</p>
                        <p className="text-[11px] text-slate-400">{item.desc}</p>
                      </div>
                      <button onClick={() => updateProfile({ settings: { ...profile.settings, [item.key]: !profile.settings[item.key] } })}
                        className={cn('w-10 h-5 rounded-full relative transition-colors shrink-0', profile.settings[item.key] ? 'bg-brand-blue' : 'bg-slate-300')}>
                        <div className={cn('w-5 h-5 bg-white rounded-full shadow border absolute top-0 transition-transform', profile.settings[item.key] ? 'translate-x-5' : 'translate-x-0')} />
                      </button>
                    </div>
                  ))}
                </div>

                <div className="space-y-4 pt-2">
                  <h3 className="text-sm font-bold text-slate-600 uppercase tracking-wide">Privacy</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5">Profile Visibility</label>
                      <select value={profile.settings.profile_visibility} onChange={e => updateProfile({ settings: { ...profile.settings, profile_visibility: e.target.value } })}
                        className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium bg-white focus:ring-2 focus:ring-brand-blue/20 outline-none">
                        <option value="public">Public</option>
                        <option value="private">Private</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-slate-500 uppercase mb-1.5">Language</label>
                      <select value={profile.settings.language} onChange={e => updateProfile({ settings: { ...profile.settings, language: e.target.value } })}
                        className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium bg-white focus:ring-2 focus:ring-brand-blue/20 outline-none">
                        {LANGUAGES.map(l => <option key={l} value={l}>{l}</option>)}
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            )}

          </div>
        </motion.div>
      </AnimatePresence>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 md:relative md:mt-6 bg-white md:bg-transparent border-t md:border-0 border-slate-200 p-4 md:p-0 z-40 flex items-center justify-between gap-3">
        <button onClick={goPrev} disabled={tabIdx === 0}
          className="flex items-center gap-1.5 px-4 py-2.5 text-[13px] font-bold text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 disabled:opacity-30 disabled:cursor-not-allowed transition-all">
          <ChevronLeft className="w-4 h-4" /> Previous
        </button>

        <div className="flex items-center gap-2">
          <button onClick={handleSave} disabled={saving}
            className="flex items-center gap-1.5 px-4 py-2.5 text-[13px] font-bold text-slate-700 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-all">
            {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4" />}
            Save
          </button>

          {tabIdx === TABS.length - 1 ? (
            <button onClick={handleSubmit}
              className="flex items-center gap-1.5 px-5 py-2.5 text-[13px] font-bold text-white bg-gradient-to-r from-emerald-600 to-emerald-500 rounded-xl hover:from-emerald-500 hover:to-emerald-400 shadow-lg shadow-emerald-200 transition-all">
              <Shield className="w-4 h-4" /> Submit for Verification
            </button>
          ) : (
            <button onClick={goNext}
              className="flex items-center gap-1.5 px-4 py-2.5 text-[13px] font-bold text-white bg-brand-blue rounded-xl hover:bg-blue-700 transition-all">
              Next <ChevronRight className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Submit Message Toast */}
      <AnimatePresence>
        {submitMsg && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="fixed bottom-20 md:bottom-8 left-1/2 -translate-x-1/2 z-50 bg-slate-900 text-white text-sm font-bold px-6 py-3 rounded-xl shadow-xl max-w-md text-center"
          >
            {submitMsg}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
