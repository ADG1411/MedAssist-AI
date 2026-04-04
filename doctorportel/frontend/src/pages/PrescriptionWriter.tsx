import { useState, useEffect } from 'react';
import { 
  PatientHeader, 
  MedicineForm, 
  MedicineCard, 
  CostPanel, 
  PrescriptionPreview
} from '../components/prescription/PrescriptionComponents';
import type { MedicineItem, PatientInfo } from '../components/prescription/PrescriptionComponents';
import { AlertTriangle, Clock } from 'lucide-react';
import { getProfile } from '../services/doctorProfileService';

export default function PrescriptionWriter() {
  const [medicines, setMedicines] = useState<MedicineItem[]>([]);
  
  // Mock Data
  const [patient, setPatient] = useState<PatientInfo>({ 
    name: 'Emma Watson', 
    age: 34, 
    gender: 'Female', 
    date: new Date().toLocaleDateString(),
    doctor: 'Doctor',
    rxNumber: 'RX-849201'
  });

  useEffect(() => {
    getProfile().then(prof => {
      setPatient(prev => ({
        ...prev,
        doctor: prof?.overview?.full_name || 'Doctor'
      }));
    }).catch(console.error);
  }, []);

  const handleAddMedicine = (med: MedicineItem) => {
    setMedicines([...medicines, med]);
  };

  const handleRemoveMedicine = (id: string) => {
    setMedicines(medicines.filter(m => m.id !== id));
  };

  return (
    <div className="max-w-[1600px] mx-auto h-full flex flex-col pt-2 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-24 md:pb-0">
      
      <div className="mb-6">
        <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Smart Prescription</h1>
        <p className="text-[14px] text-slate-500 font-medium mt-1">Write, estimate cost, and generate Rx.</p>
      </div>

      <div className="flex-1 flex flex-col lg:flex-row gap-6 lg:gap-8 min-h-0">
        
        {/* Left Column (Input & Forms) */}
        <div className="flex-1 flex flex-col gap-6 overflow-y-auto custom-scrollbar pr-1 lg:pr-2 pb-4">
           <PatientHeader patient={patient} />

           {/* Safety Alert Mock */}
           <div className="bg-amber-50 border border-amber-200/60 rounded-xl p-4 flex items-start gap-3 shadow-sm">
              <AlertTriangle className="w-5 h-5 text-amber-500 shrink-0 mt-0.5" />
              <div>
                 <p className="text-[13px] font-bold text-amber-800">Allergy Warning</p>
                 <p className="text-[12px] font-medium text-amber-700 mt-0.5">Patient has a reported mild allergy to penicillin. Avoid Amoxicillin variants.</p>
              </div>
           </div>

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

           {/* Follow Up & Notes */}
           <div className="bg-white rounded-[1.5rem] p-5 shadow-sm border border-slate-200/60">
              <h4 className="text-[14px] font-black text-slate-800 mb-4 flex items-center gap-2"><Clock className="w-4 h-4 text-brand-blue" /> Follow Up & Notes</h4>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                 <div>
                    <label className="text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2 block">Next Visit</label>
                    <input type="date" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none text-slate-700 focus:border-brand-blue focus:ring-4 focus:ring-brand-blue/10 transition-all cursor-pointer" />
                 </div>
                 <div>
                    <label className="text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2 block">Dietary Note</label>
                    <input type="text" placeholder="e.g. Low sodium diet" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[14px] font-medium outline-none text-slate-700" />
                 </div>
              </div>
           </div>
        </div>

        {/* Right Column (Preview & PDF & Cost) */}
        <div className="w-full lg:w-[45%] xl:w-[50%] flex flex-col gap-6 shrink-0 h-full overflow-y-auto custom-scrollbar md:pr-2">
           {medicines.length > 0 && <CostPanel medicines={medicines} />}
           <div className="flex-1 min-h-[500px]">
              <PrescriptionPreview medicines={medicines} patient={patient} />
           </div>
        </div>

      </div>
    </div>
  );
}