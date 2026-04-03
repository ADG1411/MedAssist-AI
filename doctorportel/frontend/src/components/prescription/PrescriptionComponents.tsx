import { useState, useEffect } from 'react';
import { Pill, Trash2, Printer, Download, Sparkles, Send, MapPin, Loader2, CheckCircle2 } from 'lucide-react';

export interface MedicineItem {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
  duration: number;
  timing: string;
  instructions: string;
  pricePerUnit: number;
  reason?: string;
}

export interface PatientInfo {
  name: string;
  age: number;
  gender: string;
  date: string;
  doctor: string;
  rxNumber: string;
}

// 1. Patient Header
export const PatientHeader = ({ patient }: { patient: PatientInfo }) => (
  <div className="bg-white rounded-[1.5rem] p-5 shadow-sm border border-slate-200/60 flex items-center justify-between">
     <div className="flex items-center gap-4">
        <div className="w-12 h-12 bg-indigo-50 border border-indigo-100 text-brand-blue rounded-xl flex items-center justify-center font-black text-lg">
           {patient.name.split(' ').map(n => n[0]).join('')}
        </div>
        <div>
           <h3 className="font-bold text-slate-800 text-[16px]">{patient.name}</h3>
           <p className="text-[13px] text-slate-500 font-medium">{patient.age} yrs • {patient.gender}</p>
        </div>
     </div>
     <div className="text-right">
        <p className="text-[12px] font-bold text-slate-400">Date: <span className="text-slate-700">{patient.date}</span></p>
        <p className="text-[12px] font-bold text-slate-400 mt-0.5">Rx No: <span className="text-brand-blue">{patient.rxNumber}</span></p>
     </div>
  </div>
);

// 2. Medicine Input Form & AI Tool
export const MedicineForm = ({ onAdd }: { onAdd: (med: MedicineItem) => void }) => {
  const [name, setName] = useState('');
  const [dosage, setDosage] = useState('500mg');
  const [frequency, setFrequency] = useState('1-0-1');
  const [duration, setDuration] = useState(5);
  const [timing, setTiming] = useState('After food');
  const [instructions, setInstructions] = useState('');
  
  const [isFetchingAI, setIsFetchingAI] = useState(false);
  const [aiData, setAiData] = useState<{reason: string, price: number} | null>(null);

  useEffect(() => {
    if (name.length > 2) {
      setIsFetchingAI(true);
      const timer = setTimeout(() => {
        // Mock AI response
        setAiData({
          reason: `AI Analysis: Indicated for underlying symptoms related to ${name}. Targets the specific receptors to reduce problem areas and accelerate patient recovery safely.`,
          price: Math.floor(Math.random() * 12) + 3
        });
        setIsFetchingAI(false);
      }, 700);
      return () => clearTimeout(timer);
    } else {
      setAiData(null);
      setIsFetchingAI(false);
    }
  }, [name]);

  const handleAdd = () => {
    if (!name) return;
    onAdd({
      id: Math.random().toString(36).substr(2, 9),
      name, dosage, frequency, duration, timing, instructions,
      pricePerUnit: aiData?.price || 5,
      reason: aiData?.reason
    });
    setName(''); setInstructions(''); setAiData(null);
  };

  return (
    <div className="bg-white rounded-[1.5rem] p-6 shadow-sm border border-slate-200/60 relative shrink-0 transition-all duration-300">
      <div className="flex items-center gap-2 mb-5">
         <div className="bg-blue-50 p-2 rounded-lg text-brand-blue"><Pill className="w-5 h-5"/></div>
         <h3 className="text-[16px] font-black text-slate-800">Add Medicine</h3>
         
         <div className="ml-auto flex gap-2">
            <button className="bg-purple-50 hover:bg-purple-100 text-purple-600 border border-purple-100/50 text-[12px] font-bold px-3 py-1.5 rounded-lg flex items-center gap-1.5 transition-colors shadow-sm">
               <Sparkles className="w-3.5 h-3.5" /> AI Suggest
            </button>
            <button className="bg-slate-100 hover:bg-slate-200 text-slate-600 text-[12px] font-bold px-3 py-1.5 rounded-lg transition-colors">
               Use Template
            </button>
         </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
         <div className="relative">
            <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block flex items-center gap-2">
              Search Medicine 
              {isFetchingAI && <Loader2 className="w-3.5 h-3.5 animate-spin text-brand-blue" />}
            </label>
            <input value={name} onChange={e => setName(e.target.value)} type="text" placeholder="e.g. Paracetamol" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none focus:border-brand-blue focus:ring-4 focus:ring-brand-blue/10 transition-all text-slate-800" />
         </div>
         <div className="grid grid-cols-2 gap-3">
            <div>
               <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block">Dosage</label>
               <input value={dosage} onChange={e => setDosage(e.target.value)} type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none focus:border-brand-blue focus:ring-4 focus:ring-brand-blue/10 transition-all text-slate-800" />
            </div>
            <div>
               <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block">Frequency</label>
               <select value={frequency} onChange={e => setFrequency(e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none text-slate-800">
                  <option value="1-0-1">1-0-1 (Twice)</option>
                  <option value="1-1-1">1-1-1 (Thrice)</option>
                  <option value="1-0-0">1-0-0 (Morning)</option>
                  <option value="0-0-1">0-0-1 (Night)</option>
               </select>
            </div>
         </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-5">
         <div>
            <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block">Duration (Days)</label>
            <input value={duration} onChange={e => setDuration(parseInt(e.target.value))} type="number" min="1" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none focus:border-brand-blue focus:ring-4 focus:ring-brand-blue/10 transition-all text-slate-800" />
         </div>
         <div>
            <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block">Timing</label>
            <select value={timing} onChange={e => setTiming(e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none text-slate-800">
               <option>After Food</option>
               <option>Before Food</option>
               <option>Empty Stomach</option>
            </select>
         </div>
         <div>
            <label className="text-[12px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 block">Instructions</label>
            <input value={instructions} onChange={e => setInstructions(e.target.value)} type="text" placeholder="e.g. Drink warm water" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none focus:border-brand-blue focus:ring-4 focus:ring-brand-blue/10 transition-all text-slate-800" />
         </div>
      </div>

      {/* AI Explanation & Price Result */}
      {aiData && !isFetchingAI && (
         <div className="mb-5 bg-purple-50/50 border border-purple-100 rounded-xl p-4 animate-in slide-in-from-top-2 fade-in duration-300">
            <div className="flex gap-4">
               <div className="flex-1">
                  <h4 className="flex items-center gap-1.5 text-[13px] font-bold text-purple-800 mb-1">
                     <Sparkles className="w-4 h-4 text-purple-500" /> 
                     Why take this? (AI Insight)
                  </h4>
                  <p className="text-[13px] text-purple-700/80 font-medium leading-relaxed">
                     {aiData.reason}
                  </p>
               </div>
               <div className="bg-white rounded-lg p-3 border border-purple-100 shadow-sm text-center shrink-0 min-w-[90px] flex flex-col items-center justify-center">
                  <span className="text-[10px] uppercase font-bold text-slate-400">Est. Price</span>
                  <span className="text-[18px] font-black text-emerald-600">${aiData.price}</span>
                  <span className="text-[10px] font-bold text-slate-400">Per Unit</span>
               </div>
            </div>
         </div>
      )}

      <button onClick={handleAdd} className="w-full bg-slate-800 hover:bg-slate-700 text-white font-bold py-3.5 rounded-xl shadow-lg shadow-slate-800/20 transition-all active:scale-[0.99] flex justify-center items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed">
         {aiData && !isFetchingAI ? <CheckCircle2 className="w-5 h-5 text-emerald-400"/> : <Plus className="w-5 h-5"/>} 
         {aiData && !isFetchingAI ? 'Confirm & Add Medicine' : 'Add Medicine to Prescription'}
      </button>
    </div>
  );
};

// Simple utility 
const Plus = ({className}:{className?:string}) => <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" /></svg>;

// 3. Medicine Cards List
export const MedicineCard = ({ med, onRemove }: { med: MedicineItem, onRemove: () => void }) => {
   const qty = med.frequency.split('-').reduce((acc, curr) => acc + parseInt(curr || '0', 10), 0) * med.duration;
   return (
     <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center group hover:border-brand-blue/30 transition-colors relative overflow-hidden">
       {/* Small left color accent based on whether AI reason exists */}
       <div className={`absolute left-0 top-0 bottom-0 w-1 ${med.reason ? 'bg-purple-400' : 'bg-brand-blue'}`}></div>
       
       <div className="pl-2 w-full sm:w-auto flex-1">
         <h4 className="font-bold text-slate-800 text-[15px] flex items-center gap-2">
            {med.name} <span className="bg-slate-100 text-slate-500 px-2 py-0.5 rounded text-[11px] uppercase tracking-wider">{med.dosage}</span>
         </h4>
         <p className="text-[13px] text-slate-600 font-medium mt-1">
            <span className="text-brand-blue font-bold">{med.frequency}</span> • {med.duration} days • {med.timing}
         </p>
         
         {/* Show AI Reason if available */}
         {med.reason && (
           <div className="mt-2.5 bg-purple-50/50 rounded-lg p-2.5 border border-purple-100/50 flex gap-2">
              <Sparkles className="w-3.5 h-3.5 text-purple-400 mt-0.5 shrink-0" />
              <p className="text-[12px] text-purple-700/90 font-medium leading-relaxed">
                 {med.reason}
              </p>
           </div>
         )}
         
         {med.instructions && <p className="text-[12px] text-slate-400 mt-2 italic">Note: {med.instructions}</p>}
       </div>

       <div className="flex items-center gap-4 w-full sm:w-auto mt-2 sm:mt-0 pt-3 sm:pt-0 border-t sm:border-0 border-slate-100">
         <div className="text-right flex-1 sm:flex-none">
            <p className="text-[12px] font-bold text-slate-400">Qty: {qty}</p>
            <p className="text-[14px] font-black text-emerald-600">${(qty * med.pricePerUnit).toFixed(2)}</p>
         </div>
         <button onClick={onRemove} className="p-2.5 text-red-400 hover:bg-red-50 hover:text-red-600 rounded-lg transition-colors">
            <Trash2 className="w-5 h-5"/>
         </button>
       </div>
     </div>
   );
};

// 4. Cost Estimation Panel
export const CostPanel = ({ medicines }: { medicines: MedicineItem[] }) => {
   const calculateTotal = () => medicines.reduce((total, med) => {
      const qty = med.frequency.split('-').reduce((acc, curr) => acc + parseInt(curr || '0', 10), 0) * med.duration;
      return total + (qty * med.pricePerUnit);
   }, 0);

   return (
     <div className="bg-gradient-to-br from-emerald-50 to-teal-50 rounded-[1.25rem] p-5 border border-emerald-100/50 shadow-sm">
        <h4 className="text-[13px] font-bold text-emerald-800 uppercase tracking-widest mb-4">Estimated Pharmacy Cost</h4>
        <div className="space-y-2 mb-4 max-h-[120px] overflow-y-auto custom-scrollbar pr-2">
           {medicines.map((m, i) => {
              const qty = m.frequency.split('-').reduce((acc, curr) => acc + parseInt(curr || '0', 10), 0) * m.duration;
              return (
                <div key={i} className="flex justify-between text-[13px] font-medium text-emerald-900 border-b border-emerald-100/50 pb-2">
                   <span className="truncate pr-4">{m.name} (x{qty})</span>
                   <span className="font-bold">${(qty * m.pricePerUnit).toFixed(2)}</span>
                </div>
              )
           })}
        </div>
        <div className="flex justify-between items-end pt-3 border-t-2 border-emerald-200/60">
           <span className="text-[14px] font-black text-emerald-900">Total Approx:</span>
           <span className="text-[22px] font-black text-emerald-600 tracking-tight">${calculateTotal().toFixed(2)}</span>
        </div>
     </div>
   );
};

// 5. Prescription Preview & PDF Generator
export const PrescriptionPreview = ({ medicines, patient }: { medicines: MedicineItem[], patient: PatientInfo }) => (
   <div className="h-full flex flex-col">
      <div className="flex gap-2 mb-4 overflow-x-auto hide-scrollbar">
         <button className="flex-1 bg-white border border-slate-200 text-slate-700 text-[13px] font-bold py-2.5 rounded-xl hover:bg-brand-blue hover:text-white hover:border-brand-blue transition-all shadow-sm flex items-center justify-center gap-2 group whitespace-nowrap">
            <Printer className="w-4 h-4 group-hover:scale-110 transition-transform" /> Print
         </button>
         <button className="flex-1 bg-white border border-slate-200 text-slate-700 text-[13px] font-bold py-2.5 rounded-xl hover:bg-slate-800 hover:text-white hover:border-slate-800 transition-all shadow-sm flex items-center justify-center gap-2 group whitespace-nowrap">
            <Download className="w-4 h-4 group-hover:scale-110 transition-transform" /> Save PDF
         </button>
         <button className="flex-1 bg-white border border-slate-200 text-slate-700 text-[13px] font-bold py-2.5 rounded-xl hover:bg-emerald-50 hover:text-emerald-700 hover:border-emerald-200 transition-all shadow-sm flex items-center justify-center gap-2 group whitespace-nowrap">
            <Send className="w-4 h-4 group-hover:translate-x-1 transition-transform" /> e-Pharmacy
         </button>
      </div>

      <div className="flex-1 bg-white rounded-2xl shadow-lg border border-slate-200 p-6 md:p-8 flex flex-col relative overflow-hidden">
         {/* Rx Background */}
         <div className="absolute top-[30%] left-1/2 -translate-x-1/2 opacity-[0.03] pointer-events-none scale-150">
            <svg viewBox="0 0 24 24" fill="currentColor" className="w-96 h-96"><path d="M15 3h1.5a1.5 1.5 0 011.5 1.5V6h3a1.5 1.5 0 011.5 1.5V9h-3v12a1.5 1.5 0 01-1.5 1.5H6A1.5 1.5 0 014.5 21V9h-3V7.5A1.5 1.5 0 013 6h3V4.5A1.5 1.5 0 017.5 3H9m6 0v6M9 3v6" /></svg>
         </div>

         {/* Header */}
         <div className="border-b-2 border-slate-900 pb-5 flex justify-between items-center z-10">
            <div>
               <h1 className="text-[22px] font-black text-slate-900 tracking-tight">MedAssist Clinic</h1>
               <p className="text-[11px] text-slate-500 font-bold mt-1 max-w-[200px]">123 Medical Boulevard, Health City, NY 10001</p>
            </div>
            <div className="text-right">
               <h2 className="text-[16px] font-black text-brand-blue">Dr. {patient.doctor}</h2>
               <p className="text-[11px] text-slate-500 font-bold">MBBS, MD - Cardiology</p>
               <p className="text-[11px] text-slate-500 font-bold">Reg No: 83921</p>
            </div>
         </div>

         {/* Patient Details */}
         <div className="py-4 border-b border-slate-200 flex justify-between z-10 text-[12px] font-bold text-slate-600">
            <div>
               <p>Patient: <span className="text-slate-900">{patient.name}</span></p>
               <p className="mt-1">Details: <span className="text-slate-900">{patient.age}Y / {patient.gender}</span></p>
            </div>
            <div className="text-right">
               <p>Date: <span className="text-slate-900">{patient.date}</span></p>
               <p className="mt-1">Rx No: <span className="text-slate-900">{patient.rxNumber}</span></p>
            </div>
         </div>

         {/* Rx Main */}
         <div className="flex-1 mt-6 z-10">
            <h1 className="text-4xl font-serif font-bold text-slate-800 mb-6">Rx</h1>
            
            {medicines.length === 0 ? (
               <div className="text-center text-slate-400 py-10">No medicines added to prescription yet.</div>
            ) : (
               <ul className="space-y-4">
                  {medicines.map((m, idx) => (
                     <li key={m.id} className="text-[13px] font-medium text-slate-800 leading-relaxed">
                        <div className="flex gap-3">
                           <span className="font-bold">{idx + 1}.</span>
                           <div className="flex-1">
                              <p className="font-black text-[14px]">
                                 {m.name} <span className="text-slate-500 font-bold ml-1">{m.dosage}</span>
                              </p>
                              <p className="text-slate-600 mt-1">
                                 {m.frequency} • {m.duration} Days • {m.timing}
                              </p>
                              {m.instructions && <p className="text-slate-500 italic mt-0.5">{m.instructions}</p>}
                           </div>
                        </div>
                     </li>
                  ))}
               </ul>
            )}
         </div>

         {/* Footer */}
         <div className="mt-8 pt-4 border-t-2 border-slate-100 flex justify-between items-end z-10">
            <div>
               <p className="text-[11px] font-bold text-slate-500 mb-1">Follow up exactly after 5 days.</p>
               <div className="flex items-center gap-1 text-[10px] text-emerald-600 font-bold bg-emerald-50 px-2 py-1 rounded w-fit">
                  <MapPin className="w-3 h-3"/> Near Pharmacy: Wellness Meds (+0.2mi)
               </div>
            </div>
            <div className="text-center">
               <div className="w-32 border-b-2 border-slate-800 border-dashed mb-2"></div>
               <p className="text-[11px] font-bold text-slate-800">Doctor's Signature</p>
            </div>
         </div>
      </div>
   </div>
);