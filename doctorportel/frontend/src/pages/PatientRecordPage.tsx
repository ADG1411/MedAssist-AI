import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Download, Printer, Shield, Clock,
  AlertTriangle, User, Phone, Mail, MapPin,
  Activity, ClipboardList, Pill, FileText, Calendar,
} from 'lucide-react';
import { accessFullRecord, type FullRecord } from '../services/medcardService';
import { generateDemoToken } from '../services/medcardService';
import { cn } from '../layouts/DashboardLayout';
import { AnnotateRecordModal } from '../components/AnnotateRecordModal';

const initials = (name: string) =>
  name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

const BLOOD_GRADIENT: Record<string, string> = {
  'B+': 'from-orange-500 to-amber-600',
  'A+': 'from-red-500 to-rose-600',
  'O+': 'from-blue-500 to-indigo-600',
  'AB+': 'from-purple-500 to-violet-600',
  'B-': 'from-orange-500 to-amber-600',
  'A-': 'from-red-500 to-rose-600',
  'O-': 'from-blue-500 to-indigo-600',
  'AB-': 'from-purple-500 to-violet-600',
};

const RISK_COLORS = {
  high:     { label: 'HIGH RISK',     badge: 'bg-red-100 text-red-700 border-red-300',     dot: 'bg-red-500' },
  moderate: { label: 'MODERATE',      badge: 'bg-amber-100 text-amber-700 border-amber-300', dot: 'bg-amber-500' },
  low:      { label: 'LOW RISK',      badge: 'bg-emerald-100 text-emerald-700 border-emerald-300', dot: 'bg-emerald-500' },
};

export default function PatientRecordPage() {
  const { patientId } = useParams<{ patientId: string }>();
  const navigate = useNavigate();

  const [record, setRecord]     = useState<FullRecord | null>(null);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState<string | null>(null);
  const [printing, setPrinting] = useState(false);
  const [activeAnnotateRecord, setActiveAnnotateRecord] = useState<{ id: string; category: string } | null>(null);

  useEffect(() => {
    if (!patientId) { setError('No patient ID'); setLoading(false); return; }
    const id = parseInt(patientId, 10);
    if (isNaN(id)) { setError('Invalid patient ID'); setLoading(false); return; }

    const token = generateDemoToken(id);
    accessFullRecord(token, false)
      .then(data => { setRecord(data); setLoading(false); })
      .catch(e  => { setError(e.message); setLoading(false); });
  }, [patientId]);

  const handlePrint = () => {
    setPrinting(true);
    setTimeout(() => { window.print(); setPrinting(false); }, 100);
  };

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 border-4 border-teal-500 border-t-transparent rounded-full animate-spin" />
        <p className="font-bold text-slate-500">Loading patient record…</p>
      </div>
    </div>
  );

  if (error || !record) return (
    <div className="min-h-screen flex flex-col items-center justify-center gap-4 text-center px-6">
      <AlertTriangle className="w-12 h-12 text-red-400" />
      <p className="font-black text-slate-700 text-lg">{error ?? 'Record not found'}</p>
      <button onClick={() => navigate('/dashboard/medcard')}
        className="bg-teal-500 text-white font-bold px-5 py-2.5 rounded-xl hover:bg-teal-600 transition-colors">
        Back to Scanner
      </button>
    </div>
  );

  const { patient, records, family_members, ai_summary } = record;
  const gradient = BLOOD_GRADIENT[patient.blood_group] ?? 'from-slate-600 to-slate-800';
  const allergiesRaw = patient.allergies;
  const allergiesList: string[] = Array.isArray(allergiesRaw) 
    ? allergiesRaw 
    : (typeof allergiesRaw === 'string' ? allergiesRaw.split(',').map((a: string) => a.trim()).filter(Boolean) : []);
  const riskLevel: 'high' | 'moderate' | 'low' =
    allergiesList.length > 0 && records.length >= 3 ? 'high' :
    records.length >= 2 ? 'moderate' : 'low';
  const risk = RISK_COLORS[riskLevel];
  const printDate = new Date().toLocaleString('en-IN', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' });

  return (
    <>
      {/* ── Print CSS (injected into head via <style>) ─────────────────────────── */}
      <style>{`
        @media print {
          body { font-size: 12px !important; }
          .no-print { display: none !important; }
          .print-page { box-shadow: none !important; border: none !important; }
          @page { size: A4; margin: 15mm; }
        }
        @keyframes scanline {
          0%   { top: 15%; opacity: 0; }
          10%  { opacity: 1; }
          90%  { opacity: 1; }
          100% { top: 85%; opacity: 0; }
        }
      `}</style>

      <div className="w-full max-w-6xl mx-auto pb-20 print-page">

        {/* ── Top bar ── */}
        <div className="no-print flex items-center justify-between mb-6 gap-3">
          <button onClick={() => navigate('/dashboard/medcard')}
            className="flex items-center gap-2 text-[13px] font-bold text-slate-600 hover:text-slate-800 bg-white border border-slate-200 px-3.5 py-2 rounded-xl shadow-sm transition-all">
            <ArrowLeft className="w-4 h-4" /> Back to Scanner
          </button>
          <div className="flex items-center gap-2">
            <button onClick={handlePrint} disabled={printing}
              className="flex items-center gap-2 text-[13px] font-bold text-white bg-teal-500 hover:bg-teal-600 px-4 py-2 rounded-xl shadow-sm transition-all disabled:opacity-60">
              <Printer className="w-4 h-4" />
              {printing ? 'Opening…' : 'Print / Save PDF'}
            </button>
            <button onClick={handlePrint} disabled={printing}
              className="flex items-center gap-2 text-[13px] font-bold text-slate-600 bg-white border border-slate-200 hover:border-slate-300 px-4 py-2 rounded-xl shadow-sm transition-all">
              <Download className="w-4 h-4" /> Download PDF
            </button>
          </div>
        </div>

        {/* ── PDF Header (visible in print) ── */}
        <div className="hidden print:flex items-center justify-between mb-6 pb-4 border-b border-slate-200">
          <div>
            <p className="font-black text-xl text-slate-800">MedAssist · Patient Medical Record</p>
            <p className="text-[12px] text-slate-500 mt-0.5">Printed by Dr. Smith · {printDate}</p>
          </div>
          <div className="flex items-center gap-2">
            <Shield className="w-4 h-4 text-teal-600" />
            <p className="text-[11px] font-bold text-teal-600">CONFIDENTIAL · Authorised Access Only</p>
          </div>
        </div>

        {/* ── Security note ── */}
        <div className="no-print flex items-center gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl px-4 py-3 mb-6">
          <Shield className="w-4 h-4 text-emerald-600 shrink-0" />
          <p className="text-[12px] font-bold text-emerald-700">
            Authenticated access · Session logged · Confidential medical record
          </p>
          <div className="ml-auto flex items-center gap-1.5 text-[11px] font-bold text-slate-400">
            <Clock className="w-3.5 h-3.5" /> {printDate}
          </div>
        </div>

        {/* ── PATIENT IDENTITY CARD ── */}
        <div className={cn('bg-gradient-to-br rounded-3xl p-6 text-white shadow-xl mb-6', gradient)}>
          <div className="flex items-start gap-4">
            <div className="w-20 h-20 bg-white/20 rounded-2xl flex items-center justify-center font-black text-2xl shrink-0 backdrop-blur-sm">
              {initials(patient.name)}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-black text-3xl tracking-tight leading-tight">{patient.name}</p>
              <p className="text-white/70 text-sm font-semibold mt-1">
                {patient.age} yrs · {patient.gender} · {patient.blood_group}
              </p>
              <div className={cn('inline-flex items-center gap-1.5 mt-2 px-3 py-1 rounded-full bg-white/20 backdrop-blur-sm border border-white/30')}>
                <div className={cn('w-2 h-2 rounded-full', risk.dot)} />
                <span className="text-[11px] font-black tracking-widest">{risk.label}</span>
              </div>
            </div>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mt-4">
            {[
              { label: 'Blood Group', value: patient.blood_group },
              { label: 'Gender',      value: patient.gender },
              { label: 'Age',         value: `${patient.age} years` },
              { label: 'Patient ID',  value: `#${patient.id}` },
            ].map(({ label, value }) => (
              <div key={label} className="bg-white/10 rounded-xl px-3 py-2 backdrop-blur-sm">
                <p className="text-[9px] font-bold text-white/50 uppercase tracking-widest">{label}</p>
                <p className="text-[13px] font-black text-white mt-0.5">{value}</p>
              </div>
            ))}
          </div>
        </div>

        {/* ── Contact + Allergies side-by-side ── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
            <div className="flex items-center gap-2 mb-3">
              <User className="w-4 h-4 text-slate-400" />
              <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Contact Details</p>
            </div>
            {[
              { icon: Phone, val: patient.phone   },
              { icon: Mail,  val: patient.email   },
              { icon: MapPin,val: patient.address },
            ].filter(i => i.val).map(({ icon: Icon, val }) => (
              <div key={val} className="flex items-start gap-2.5 mb-2 last:mb-0">
                <Icon className="w-3.5 h-3.5 text-slate-400 mt-0.5 shrink-0" />
                <p className="text-[12px] font-semibold text-slate-700 leading-snug">{val}</p>
              </div>
            ))}
          </div>

          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
            <div className="flex items-center gap-2 mb-3">
              <AlertTriangle className="w-4 h-4 text-red-400" />
              <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Known Allergies</p>
            </div>
            {allergiesList.length > 0 ? (
              <div className="flex flex-wrap gap-2">
                {allergiesList.map((a: string) => (
                  <div key={a} className="flex items-center gap-1.5 bg-red-50 border border-red-200 text-red-700 text-[12px] font-bold px-3 py-1.5 rounded-xl">
                    <AlertTriangle className="w-3 h-3" /> {a}
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-[13px] font-medium text-slate-400">No known allergies</p>
            )}
          </div>
        </div>

        {/* ── AI SUMMARY ── */}
        <div className="bg-slate-900 rounded-2xl overflow-hidden shadow-sm mb-6">
          <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-700/50">
            <div className="w-9 h-9 bg-gradient-to-br from-teal-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-md shrink-0">
              <Activity className="w-4 h-4 text-white" />
            </div>
            <div>
              <p className="font-black text-white text-[14px]">AI Medical Summary</p>
              <p className="text-[10px] font-medium text-slate-400 mt-0.5">Generated from visit history · {printDate}</p>
            </div>
            <div className={cn('ml-auto flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-[11px] font-black', risk.badge)}>
              <div className={cn('w-2 h-2 rounded-full', risk.dot)} />
              {risk.label}
            </div>
          </div>
          <div className="px-5 py-4 space-y-2.5">
            {ai_summary.map((insight, i) => {
              const isAlert = /allerg|critical|high priority/.test(insight.toLowerCase());
              const isTrend = /trend|recurring|increasing|frequent/.test(insight.toLowerCase());
              const borderColor = isAlert ? 'border-l-rose-400' : isTrend ? 'border-l-amber-400' : 'border-l-teal-400';
              return (
                <div key={i} className={cn('flex items-start gap-3 rounded-xl px-4 py-3 border-l-4 bg-slate-800/60', borderColor)}>
                  <Activity className="w-4 h-4 text-slate-300 shrink-0 mt-0.5" />
                  <p className="text-[13px] font-semibold text-slate-200 leading-snug">{insight}</p>
                </div>
              );
            })}
          </div>
        </div>

        {/* ── MEDICAL RECORDS ── */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-6">
          <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-100">
            <div className="w-8 h-8 bg-purple-50 rounded-xl flex items-center justify-center">
              <ClipboardList className="w-4 h-4 text-purple-500" />
            </div>
            <p className="font-black text-slate-800 text-[14px]">Medical Records</p>
            <span className="ml-auto text-[11px] font-bold text-slate-400 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded-lg">
              {records.length} visits
            </span>
          </div>
          {records.length === 0 ? (
            <div className="py-10 text-center">
              <FileText className="w-8 h-8 text-slate-300 mx-auto mb-2" />
              <p className="text-[13px] font-medium text-slate-400">No records on file</p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {records.map(rec => (
                <div key={rec.id} className="px-5 py-4 relative group">
                  <div className="flex items-start justify-between gap-3 mb-2">
                    <p className="font-black text-slate-800 text-[14px]">
                      {rec.diagnosis || (rec as any).category || 'File Record'}
                    </p>
                    <div className="flex items-center gap-3">
                      <button 
                        onClick={() => setActiveAnnotateRecord({ id: String(rec.id), category: rec.diagnosis || (rec as any).category || 'File Record' })}
                        className="no-print opacity-0 group-hover:opacity-100 flex items-center gap-1.5 text-[11px] font-bold text-teal-600 bg-teal-50 px-2 py-1 rounded-lg hover:bg-teal-100 transition-all"
                      >
                        <ClipboardList className="w-3 h-3" /> Annotate
                      </button>
                      <p className="text-[11px] font-medium text-slate-400 shrink-0 flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {new Date(rec.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
                      </p>
                    </div>
                  </div>
                  {rec.doctor_name && (
                    <p className="text-[11px] font-bold text-slate-400 mb-2 flex items-center gap-1">
                      <User className="w-3 h-3" /> {rec.doctor_name}
                    </p>
                  )}
                  {rec.prescription && (
                    <div className="bg-teal-50 border border-teal-100 rounded-xl p-3 mb-2">
                      <div className="flex items-center gap-1.5 mb-1">
                        <Pill className="w-3 h-3 text-teal-600" />
                        <p className="text-[10px] font-bold text-teal-600 uppercase tracking-widest">Prescription</p>
                      </div>
                      <p className="text-[12px] font-semibold text-slate-700">{rec.prescription}</p>
                    </div>
                  )}
                  {rec.notes && (
                    <div className="bg-amber-50 border border-amber-100 rounded-xl p-3">
                      <div className="flex items-center gap-1.5 mb-1">
                        <FileText className="w-3 h-3 text-amber-600" />
                        <p className="text-[10px] font-bold text-amber-600 uppercase tracking-widest">Doctor Notes</p>
                      </div>
                      <p className="text-[12px] font-semibold text-slate-700">{rec.notes}</p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* ── FAMILY & EMERGENCY CONTACTS ── */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-6">
          <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-100">
            <div className="w-8 h-8 bg-blue-50 rounded-xl flex items-center justify-center">
              <User className="w-4 h-4 text-blue-500" />
            </div>
            <p className="font-black text-slate-800 text-[14px]">Family & Emergency Contacts</p>
          </div>
          {family_members.length === 0 ? (
            <div className="py-8 text-center">
              <p className="text-[13px] font-medium text-slate-400">No contacts on file</p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {family_members.map(m => (
                <div key={m.id} className="flex items-center gap-4 px-5 py-3.5">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-100 to-indigo-100 rounded-xl flex items-center justify-center font-black text-blue-600 text-sm shrink-0">
                    {m.name.split(' ').map(n => n[0]).join('').slice(0, 2)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-[13px] font-black text-slate-800">{m.name}</p>
                      {m.is_primary && (
                        <span className="text-[9px] font-bold text-amber-600 bg-amber-50 border border-amber-200 px-1.5 py-0.5 rounded-md">PRIMARY</span>
                      )}
                    </div>
                    <p className="text-[11px] font-medium text-slate-400">{m.relation} · {m.phone}</p>
                  </div>
                  <a href={`tel:${m.phone}`} className="no-print flex items-center gap-1.5 bg-emerald-50 border border-emerald-200 text-emerald-700 font-bold text-[11px] px-3 py-1.5 rounded-xl hover:bg-emerald-100 transition-colors">
                    <Phone className="w-3.5 h-3.5" /> Call
                  </a>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* ── Print footer ── */}
        <div className="border-t border-slate-200 pt-4 text-center">
          <p className="text-[10px] text-slate-400 font-medium">
            MedAssist Doctor Portal · Patient ID #{patient.id} · Accessed by Dr. Smith · {printDate}
          </p>
          <p className="text-[10px] text-red-400 font-bold mt-0.5">
            CONFIDENTIAL — This document contains protected health information. Do not share or distribute.
          </p>
        </div>

        {/* ── PDF Download button (bottom) ── */}
        <div className="no-print flex justify-center mt-8">
          <button onClick={handlePrint}
            className="flex items-center gap-3 bg-slate-900 hover:bg-slate-800 text-white font-black text-[14px] px-8 py-4 rounded-2xl shadow-xl transition-all active:scale-[0.98]">
            <Download className="w-5 h-5" />
            Download as PDF
          </button>
        </div>
      </div>
      
      {activeAnnotateRecord && (
        <AnnotateRecordModal 
          recordId={activeAnnotateRecord.id}
          patientName={patient.name}
          category={activeAnnotateRecord.category}
          onClose={() => setActiveAnnotateRecord(null)}
          onSuccess={() => {
            setActiveAnnotateRecord(null);
            // Optionally refresh the list or show a toast
          }}
        />
      )}
    </>
  );
}
