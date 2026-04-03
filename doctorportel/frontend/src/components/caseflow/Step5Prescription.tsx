import { useState } from 'react';
import { Plus, Trash2, Pill, FlaskConical, FileText, Calendar, CheckSquare, Square } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState, MedicineItem, PrescriptionData } from '../../types/caseflow';

const ALL_TESTS = [
  'Complete Blood Count (CBC)', 'Blood Sugar (Fasting)', 'Liver Function Test (LFT)',
  'Kidney Function Test (KFT)', 'Lipid Profile', 'ECG', 'Chest X-Ray',
  'Ultrasound Abdomen', 'CT Scan', 'MRI', 'Urine Routine',
  'Thyroid Function (TFT)', 'HbA1c', 'Echocardiogram',
];

const FREQ_OPTIONS = ['Once daily', 'Twice daily', 'Thrice daily', 'Every 8 hours', 'As needed', 'At bedtime'];

interface Props {
  data: CaseFlowState;
  onChange: (rx: PrescriptionData) => void;
}

export const Step5Prescription = ({ data, onChange }: Props) => {
  const rx = data.prescription;
  const upd = (patch: Partial<PrescriptionData>) => onChange({ ...rx, ...patch });

  const [medForm, setMedForm] = useState({ name: '', dosage: '', duration: '', frequency: 'Twice daily' });

  const addMedicine = () => {
    if (!medForm.name.trim() || !medForm.dosage.trim()) return;
    const med: MedicineItem = { id: Date.now().toString(), ...medForm };
    upd({ medicines: [...rx.medicines, med] });
    setMedForm({ name: '', dosage: '', duration: '', frequency: 'Twice daily' });
  };

  const removeMedicine = (id: string) => upd({ medicines: rx.medicines.filter(m => m.id !== id) });

  const toggleTest = (test: string) => {
    const next = rx.tests.includes(test)
      ? rx.tests.filter(t => t !== test)
      : [...rx.tests, test];
    upd({ tests: next });
  };

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* ── Diagnosis ── */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
        <div className="flex items-center gap-2 mb-3">
          <div className="w-7 h-7 bg-blue-50 rounded-lg flex items-center justify-center">
            <FileText className="w-4 h-4 text-blue-500" />
          </div>
          <span className="font-black text-slate-800 text-[14px]">Diagnosis</span>
        </div>
        <textarea
          value={rx.diagnosis}
          onChange={e => upd({ diagnosis: e.target.value })}
          placeholder="Enter primary diagnosis…"
          rows={2}
          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-[13px] text-slate-700 font-medium outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 resize-none placeholder:text-slate-400 transition-colors"
        />
      </div>

      {/* ── Medicines ── */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
        <div className="flex items-center gap-2 mb-4">
          <div className="w-7 h-7 bg-teal-50 rounded-lg flex items-center justify-center">
            <Pill className="w-4 h-4 text-teal-500" />
          </div>
          <span className="font-black text-slate-800 text-[14px]">Medicines</span>
          <span className="ml-auto text-[11px] font-bold text-teal-600 bg-teal-50 border border-teal-100 px-2 py-0.5 rounded-lg">
            {rx.medicines.length} added
          </span>
        </div>

        {/* Add form */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-3">
          <input value={medForm.name} onChange={e => setMedForm(f => ({ ...f, name: e.target.value }))}
            placeholder="Medicine name *" className="col-span-2 sm:col-span-1 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 text-slate-700 placeholder:text-slate-400 transition-colors" />
          <input value={medForm.dosage} onChange={e => setMedForm(f => ({ ...f, dosage: e.target.value }))}
            placeholder="Dosage (e.g. 500mg)" className="bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 text-slate-700 placeholder:text-slate-400 transition-colors" />
          <input value={medForm.duration} onChange={e => setMedForm(f => ({ ...f, duration: e.target.value }))}
            placeholder="Duration (e.g. 7 days)" className="bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 text-slate-700 placeholder:text-slate-400 transition-colors" />
          <select value={medForm.frequency} onChange={e => setMedForm(f => ({ ...f, frequency: e.target.value }))}
            className="bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-[13px] outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 text-slate-700 transition-colors">
            {FREQ_OPTIONS.map(f => <option key={f}>{f}</option>)}
          </select>
        </div>
        <button onClick={addMedicine}
          className="flex items-center gap-2 text-[13px] font-bold text-white bg-teal-500 hover:bg-teal-600 px-4 py-2.5 rounded-xl transition-all active:scale-95 shadow-sm shadow-teal-500/20 mb-4">
          <Plus className="w-4 h-4" /> Add Medicine
        </button>

        {/* Medicines list */}
        {rx.medicines.length > 0 && (
          <div className="space-y-2">
            {rx.medicines.map(med => (
              <div key={med.id} className="flex items-center gap-3 bg-teal-50 border border-teal-100 rounded-xl px-4 py-3">
                <Pill className="w-4 h-4 text-teal-500 shrink-0" />
                <div className="flex-1 min-w-0">
                  <p className="text-[13px] font-black text-slate-800">{med.name}</p>
                  <p className="text-[11px] font-semibold text-slate-500">{med.dosage} · {med.frequency} · {med.duration}</p>
                </div>
                <button onClick={() => removeMedicine(med.id)} className="p-1.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors shrink-0">
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            ))}
          </div>
        )}
        {rx.medicines.length === 0 && (
          <p className="text-[12px] text-slate-400 font-medium text-center py-3">No medicines added yet</p>
        )}
      </div>

      {/* ── Tests ── */}
      <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
        <div className="flex items-center gap-2 mb-4">
          <div className="w-7 h-7 bg-purple-50 rounded-lg flex items-center justify-center">
            <FlaskConical className="w-4 h-4 text-purple-500" />
          </div>
          <span className="font-black text-slate-800 text-[14px]">Recommended Tests</span>
          {rx.tests.length > 0 && (
            <span className="ml-auto text-[11px] font-bold text-purple-600 bg-purple-50 border border-purple-100 px-2 py-0.5 rounded-lg">
              {rx.tests.length} selected
            </span>
          )}
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
          {ALL_TESTS.map(test => {
            const selected = rx.tests.includes(test);
            return (
              <button key={test} onClick={() => toggleTest(test)}
                className={cn('flex items-center gap-2.5 px-3.5 py-2.5 rounded-xl border text-left transition-all text-[12px] font-semibold',
                  selected ? 'bg-purple-50 border-purple-200 text-purple-700' : 'bg-slate-50 border-slate-200 text-slate-600 hover:border-slate-300')}>
                {selected
                  ? <CheckSquare className="w-4 h-4 text-purple-500 shrink-0" />
                  : <Square className="w-4 h-4 text-slate-300 shrink-0" />
                }
                {test}
              </button>
            );
          })}
        </div>
      </div>

      {/* ── Instructions + Follow-up ── */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-7 h-7 bg-amber-50 rounded-lg flex items-center justify-center">
              <FileText className="w-4 h-4 text-amber-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Instructions</span>
          </div>
          <textarea
            value={rx.instructions}
            onChange={e => upd({ instructions: e.target.value })}
            placeholder="Diet, precautions, lifestyle advice…"
            rows={4}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-[13px] text-slate-700 font-medium outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 resize-none placeholder:text-slate-400 transition-colors"
          />
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-7 h-7 bg-blue-50 rounded-lg flex items-center justify-center">
              <Calendar className="w-4 h-4 text-blue-500" />
            </div>
            <span className="font-black text-slate-800 text-[14px]">Follow-up Date</span>
          </div>
          <input
            type="date"
            value={rx.followUpDate}
            onChange={e => upd({ followUpDate: e.target.value })}
            min={new Date().toISOString().split('T')[0]}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-[14px] font-bold text-slate-700 outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-colors"
          />
          {rx.followUpDate && (
            <p className="text-[12px] font-semibold text-teal-600 mt-2 flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5" />
              Follow-up scheduled for {new Date(rx.followUpDate).toLocaleDateString('en-IN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            </p>
          )}
        </div>
      </div>
    </div>
  );
};
