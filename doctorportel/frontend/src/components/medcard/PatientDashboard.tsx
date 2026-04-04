import { useState } from 'react';
import {
  User, Activity, FileText, Pill, Calendar,
  AlertTriangle, Mail, MapPin, Phone, ClipboardList,
  ChevronDown, ChevronUp, Shield, Clock, ExternalLink,
} from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import { AIInsights } from './AIInsights';
import { FamilyInfo }  from './FamilyInfo';
import type { FullRecord } from '../../services/medcardService';

interface Props {
  record: FullRecord;
  isEmergency?: boolean;
  onNewScan: () => void;
}

const initials = (name: string) =>
  name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

const BLOOD_GRADIENT: Record<string, string> = {
  'A+': 'from-red-500 to-rose-600', 'A-': 'from-red-500 to-rose-600',
  'B+': 'from-orange-500 to-amber-600', 'B-': 'from-orange-500 to-amber-600',
  'O+': 'from-blue-500 to-indigo-600', 'O-': 'from-blue-500 to-indigo-600',
  'AB+': 'from-purple-500 to-violet-600', 'AB-': 'from-purple-500 to-violet-600',
};

const RecordCard = ({ rec }: { rec: FullRecord['records'][number] }) => {
  const [open, setOpen] = useState(false);
  const date = new Date(rec.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });

  return (
    <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm">
      <button onClick={() => setOpen(o => !o)}
        className="w-full flex items-center gap-3 px-5 py-4 text-left hover:bg-slate-50 transition-colors">
        <div className="w-9 h-9 bg-blue-50 rounded-xl flex items-center justify-center shrink-0">
          <ClipboardList className="w-4 h-4 text-blue-500" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="font-black text-slate-800 text-[13px] leading-tight">{rec.diagnosis}</p>
          <p className="text-[11px] text-slate-400 font-medium mt-0.5 flex items-center gap-2">
            <Calendar className="w-3 h-3" /> {date}
            {rec.doctor_name && <><span className="text-slate-300">·</span> {rec.doctor_name}</>}
          </p>
        </div>
        {open ? <ChevronUp className="w-4 h-4 text-slate-400 shrink-0" /> : <ChevronDown className="w-4 h-4 text-slate-400 shrink-0" />}
      </button>

      {open && (
        <div className="border-t border-slate-100 px-5 pb-4 pt-3 space-y-3 animate-in slide-in-from-top-2 duration-200">
          {rec.prescription && (
            <div className="bg-teal-50 border border-teal-100 rounded-xl p-3.5">
              <div className="flex items-center gap-2 mb-1.5">
                <Pill className="w-3.5 h-3.5 text-teal-600" />
                <p className="text-[10px] font-bold text-teal-600 uppercase tracking-widest">Prescription</p>
              </div>
              <p className="text-[12px] font-semibold text-slate-700 leading-relaxed">{rec.prescription}</p>
            </div>
          )}
          {rec.notes && (
            <div className="bg-amber-50 border border-amber-100 rounded-xl p-3.5">
              <div className="flex items-center gap-2 mb-1.5">
                <FileText className="w-3.5 h-3.5 text-amber-600" />
                <p className="text-[10px] font-bold text-amber-600 uppercase tracking-widest">Doctor Notes</p>
              </div>
              <p className="text-[12px] font-semibold text-slate-700 leading-relaxed">{rec.notes}</p>
            </div>
          )}
          {rec.report_url && (
            <a href={rec.report_url} target="_blank" rel="noreferrer"
              className="flex items-center gap-2 text-[12px] font-bold text-blue-600 hover:text-blue-700">
              <ExternalLink className="w-3.5 h-3.5" /> View Report
            </a>
          )}
        </div>
      )}
    </div>
  );
};

const SectionHeader = ({ icon: Icon, title, count, color = 'text-slate-600', bg = 'bg-slate-100' }: {
  icon: React.ComponentType<{ className?: string }>;
  title: string;
  count?: number;
  color?: string;
  bg?: string;
}) => (
  <div className="flex items-center gap-3 mb-4">
    <div className={cn('w-8 h-8 rounded-xl flex items-center justify-center shrink-0', bg)}>
      <Icon className={cn('w-4 h-4', color)} />
    </div>
    <p className="font-black text-slate-800 text-[15px]">{title}</p>
    {count !== undefined && (
      <span className="ml-auto text-[11px] font-bold text-slate-400 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded-lg">
        {count}
      </span>
    )}
  </div>
);

export const PatientDashboard = ({ record, isEmergency = false, onNewScan }: Props) => {
  const { patient, records, family_members, ai_summary } = record;
  const gradient = BLOOD_GRADIENT[patient.blood_group] ?? 'from-slate-600 to-slate-800';
  const allergiesList = Array.isArray(patient.allergies)
    ? patient.allergies.map(String).filter(Boolean)
    : typeof patient.allergies === 'string'
      ? patient.allergies.split(',').map(a => a.trim()).filter(Boolean)
      : [];

  return (
    <div className="space-y-5 animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* Emergency banner */}
      {isEmergency && (
        <div className="flex items-center gap-3 bg-red-500 text-white rounded-2xl px-5 py-3.5 shadow-lg shadow-red-500/25">
          <AlertTriangle className="w-5 h-5 shrink-0 animate-pulse" />
          <div>
            <p className="font-black text-[14px]">Emergency Access Mode</p>
            <p className="text-red-100 text-[11px] font-medium">Access has been logged · Tagged as EMERGENCY</p>
          </div>
        </div>
      )}

      {/* Access success */}
      <div className="flex items-center justify-between gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl px-4 py-3">
        <div className="flex items-center gap-2.5">
          <Shield className="w-4 h-4 text-emerald-600 shrink-0" />
          <p className="text-[12px] font-bold text-emerald-700">
            Access granted · Session expires in 15 minutes · Access logged
          </p>
        </div>
        <button onClick={onNewScan}
          className="text-[11px] font-bold text-emerald-600 hover:text-emerald-700 bg-white border border-emerald-200 px-2.5 py-1 rounded-lg shrink-0 transition-colors">
          New Scan
        </button>
      </div>

      {/* ── PATIENT INFO ── */}
      <div>
        <SectionHeader icon={User} title="Patient Information" color="text-blue-600" bg="bg-blue-50" />

        {/* ID Card */}
        <div className={cn('bg-gradient-to-br rounded-3xl p-6 text-white shadow-xl mb-4', gradient)}>
          <div className="flex items-start gap-4">
            <div className="w-16 h-16 bg-white/20 rounded-2xl flex items-center justify-center font-black text-xl shrink-0 backdrop-blur-sm">
              {initials(patient.name)}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-black text-2xl tracking-tight leading-tight">{patient.name}</p>
              <p className="text-white/70 text-[12px] font-semibold mt-1">
                {patient.age} yrs · {patient.gender} · {patient.blood_group}
              </p>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-2 mt-4">
            {[
              { label: 'Blood Group', value: patient.blood_group },
              { label: 'Gender',      value: patient.gender      },
              { label: 'Age',         value: `${patient.age} years` },
              { label: 'Patient ID',  value: `#${patient.id}`  },
            ].map(({ label, value }) => (
              <div key={label} className="bg-white/10 rounded-xl px-3 py-2 backdrop-blur-sm">
                <p className="text-[9px] font-bold text-white/50 uppercase tracking-widest">{label}</p>
                <p className="text-[13px] font-black text-white mt-0.5">{value}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Contact + Allergies */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-4 space-y-3">
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Contact Details</p>
            {[
              { icon: Phone, value: patient.phone   },
              { icon: Mail,  value: patient.email   },
              { icon: MapPin,value: patient.address },
            ].filter(i => i.value).map(({ icon: Icon, value }) => (
              <div key={value} className="flex items-start gap-2.5">
                <Icon className="w-3.5 h-3.5 text-slate-400 mt-0.5 shrink-0" />
                <p className="text-[12px] font-semibold text-slate-700 leading-snug">{value}</p>
              </div>
            ))}
          </div>

          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-4">
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3">Known Allergies</p>
            {allergiesList.length > 0 ? (
              <div className="flex flex-wrap gap-2">
                {allergiesList.map(a => (
                  <div key={a} className="flex items-center gap-1.5 bg-red-50 border border-red-200 text-red-700 text-[12px] font-bold px-3 py-1.5 rounded-xl">
                    <AlertTriangle className="w-3.5 h-3.5" /> {a}
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-[12px] font-medium text-slate-400">No known allergies</p>
            )}
          </div>
        </div>
      </div>

      {/* ── AI SUMMARY ── */}
      <div>
        <SectionHeader icon={Activity} title="AI Medical Insights" color="text-teal-600" bg="bg-teal-50" />
        <AIInsights
          insights={ai_summary}
          riskLevel={
            patient.allergies && records.length >= 3 ? 'high' :
            records.length >= 2 ? 'moderate' : 'low'
          }
          generatedAt={new Date().toISOString()}
        />
      </div>

      {/* ── MEDICAL RECORDS ── */}
      <div>
        <SectionHeader icon={ClipboardList} title="Medical Records" count={records.length} color="text-purple-600" bg="bg-purple-50" />
        {records.length === 0 ? (
          <div className="bg-white border border-dashed border-slate-200 rounded-2xl p-8 text-center">
            <FileText className="w-8 h-8 text-slate-300 mx-auto mb-2" />
            <p className="text-[13px] font-medium text-slate-400">No medical records on file</p>
          </div>
        ) : (
          <div className="space-y-3">
            {records.map(rec => <RecordCard key={rec.id} rec={rec} />)}
          </div>
        )}
      </div>

      {/* ── FAMILY INFO ── */}
      <div>
        <SectionHeader icon={User} title="Family & Emergency Contacts" count={family_members.length} color="text-blue-600" bg="bg-blue-50" />
        <FamilyInfo members={family_members} />
      </div>

      {/* Access log note */}
      <div className="flex items-center gap-2.5 bg-slate-50 border border-slate-200 rounded-2xl px-4 py-3">
        <Clock className="w-4 h-4 text-slate-400 shrink-0" />
        <p className="text-[11px] font-medium text-slate-500">
          This access was logged at {new Date().toLocaleTimeString('en-IN')} by Dr. Smith ·
          {isEmergency ? ' Tagged: EMERGENCY' : ' Tagged: STANDARD'}
        </p>
      </div>
    </div>
  );
};
