import { useState } from 'react';
import { Plus, X, Loader2, Send, FlaskConical } from 'lucide-react';
import type { CreateReferralPayload, ReferralType } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  onSubmit: (payload: CreateReferralPayload) => Promise<void>;
  onCancel: () => void;
}

const REFERRAL_TYPES: { value: ReferralType; label: string; color: string }[] = [
  { value: 'lab',        label: '🧪 Lab',        color: 'border-teal-400 bg-teal-50 text-teal-700' },
  { value: 'hospital',   label: '🏥 Hospital',   color: 'border-blue-400 bg-blue-50 text-blue-700' },
  { value: 'specialist', label: '👨‍⚕️ Specialist', color: 'border-violet-400 bg-violet-50 text-violet-700' },
  { value: 'emergency',  label: '🚨 Emergency',  color: 'border-red-400 bg-red-50 text-red-700' },
];

const COMMON_TESTS = ['CBC', 'Blood Sugar', 'Lipid Profile', 'Liver Function Test', 'Thyroid Panel', 'Urine Routine', 'ECG', 'X-Ray Chest', 'HbA1c', 'Kidney Function Test'];

export function ReferralForm({ onSubmit, onCancel }: Props) {
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState<CreateReferralPayload>({
    patient_id: 'pat-1',
    patient_name: 'Rahul Sharma',
    patient_age: 34,
    patient_gender: 'Male',
    patient_blood_group: 'B+',
    diagnosis: '',
    notes: '',
    medicines: [],
    tests: [],
    reason: '',
    type: 'lab',
  });
  const [testInput, setTestInput] = useState('');

  const set = (k: keyof CreateReferralPayload, v: unknown) =>
    setForm(f => ({ ...f, [k]: v }));

  const addItem = (list: 'medicines' | 'tests', val: string, setInput: (v: string) => void) => {
    const v = val.trim();
    if (v && !(form[list] as string[]).includes(v)) {
      set(list, [...(form[list] as string[]), v]);
    }
    setInput('');
  };

  const removeItem = (list: 'medicines' | 'tests', val: string) =>
    set(list, (form[list] as string[]).filter(x => x !== val));

  const handleSubmit = async () => {
    if (!form.diagnosis.trim() || !form.reason.trim()) return;
    setSaving(true);
    try { await onSubmit(form); } finally { setSaving(false); }
  };

  const inputCls = "w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-800 focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none transition-colors placeholder:text-slate-400";
  const labelCls = "block text-xs font-bold text-slate-600 mb-1.5 uppercase tracking-wide";

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
      <div className="space-y-5">
      {/* Patient Info */}
      <div className="bg-slate-50 rounded-2xl p-4 border border-slate-200">
        <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">Patient Info</p>
        <div className="grid grid-cols-2 gap-3">
          <div className="col-span-2">
            <label className={labelCls}>Full Name *</label>
            <input value={form.patient_name} onChange={e => set('patient_name', e.target.value)} className={inputCls} placeholder="Patient name" />
          </div>
          <div>
            <label className={labelCls}>Age *</label>
            <input type="number" value={form.patient_age} onChange={e => set('patient_age', +e.target.value)} className={inputCls} placeholder="Age" />
          </div>
          <div>
            <label className={labelCls}>Gender *</label>
            <select value={form.patient_gender} onChange={e => set('patient_gender', e.target.value)} className={inputCls}>
              <option>Male</option><option>Female</option><option>Other</option>
            </select>
          </div>
          <div>
            <label className={labelCls}>Blood Group</label>
            <select value={form.patient_blood_group} onChange={e => set('patient_blood_group', e.target.value)} className={inputCls}>
              {['A+','A-','B+','B-','O+','O-','AB+','AB-'].map(g => <option key={g}>{g}</option>)}
            </select>
          </div>
        </div>
      </div>

      {/* Referral Type */}
      <div>
        <label className={labelCls}>Referral Type *</label>
        <div className="grid grid-cols-2 gap-2">
          {REFERRAL_TYPES.map(t => (
            <button key={t.value} type="button" onClick={() => set('type', t.value)}
              className={cn('border-2 rounded-xl px-3 py-2.5 text-[13px] font-bold transition-all',
                form.type === t.value ? t.color + ' border-current' : 'border-slate-200 bg-white text-slate-500 hover:border-slate-300')}>
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* Diagnosis */}
      <div>
        <label className={labelCls}>Diagnosis *</label>
        <textarea value={form.diagnosis} onChange={e => set('diagnosis', e.target.value)} rows={3}
          className={cn(inputCls, 'resize-none')} placeholder="Primary diagnosis..." />
      </div>
      </div> {/* END LEFT COL */}

      <div className="space-y-5 flex flex-col justify-between h-full">
        <div className="space-y-5">

      {/* Doctor Notes */}
      <div>
        <label className={labelCls}>Doctor Notes</label>
        <textarea value={form.notes} onChange={e => set('notes', e.target.value)} rows={2}
          className={cn(inputCls, 'resize-none')} placeholder="Additional notes for the provider..." />
      </div>

      {/* Reason */}
      <div>
        <label className={labelCls}>Reason for Referral *</label>
        <input value={form.reason} onChange={e => set('reason', e.target.value)} className={inputCls} placeholder="Why is this referral needed?" />
      </div>


      {/* Tests */}
      <div>
        <div className="flex items-center gap-2 mb-2">
          <FlaskConical className="w-3.5 h-3.5 text-teal-500" />
          <label className={cn(labelCls, 'mb-0')}>Tests to Order</label>
        </div>
        <div className="flex gap-2 mb-2">
          <input value={testInput} onChange={e => setTestInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && addItem('tests', testInput, setTestInput)}
            className={cn(inputCls, 'flex-1 text-xs')} placeholder="Type test name and press Enter..." />
          <button onClick={() => addItem('tests', testInput, setTestInput)}
            className="p-2.5 bg-teal-500 text-white rounded-xl hover:bg-teal-600 transition-colors shrink-0">
            <Plus className="w-4 h-4" />
          </button>
        </div>
        <div className="flex flex-wrap gap-1.5 mb-2">
          {COMMON_TESTS.map(t => (
            <button key={t} type="button" onClick={() => addItem('tests', t, () => {})}
              className={cn('text-[11px] font-semibold px-2.5 py-1 rounded-lg border transition-colors',
                form.tests.includes(t) ? 'bg-teal-100 border-teal-300 text-teal-700' : 'bg-slate-50 border-slate-200 text-slate-500 hover:border-teal-300')}>
              {t}
            </button>
          ))}
        </div>
        <div className="flex flex-wrap gap-1.5">
          {form.tests.map(t => (
            <span key={t} className="flex items-center gap-1 bg-teal-100 text-teal-700 text-[12px] font-semibold px-2.5 py-1 rounded-lg">
              {t}
              <button type="button" onClick={() => removeItem('tests', t)}><X className="w-3 h-3" /></button>
            </span>
          ))}
        </div>
      </div>
      </div> {/* CLOSES spacing div for right col */}

      {/* Actions */}
      <div className="flex gap-3 pt-2 mt-auto">
        <button type="button" onClick={onCancel}
          className="flex-1 py-3 rounded-2xl border border-slate-200 text-slate-600 font-bold text-[14px] hover:bg-slate-50 transition-colors">
          Cancel
        </button>
        <button type="button" onClick={handleSubmit} disabled={saving || !form.diagnosis.trim() || !form.reason.trim()}
          className="flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl bg-teal-500 hover:bg-teal-600 text-white font-bold text-[14px] transition-all disabled:opacity-50 shadow-lg shadow-teal-500/25">
          {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
          {saving ? 'Creating…' : 'Create Referral'}
        </button>
      </div>
      </div> {/* END RIGHT COL */}
    </div>
  );
}
