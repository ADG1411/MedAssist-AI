import { useState } from 'react';
import { Download, Share2, Save, CheckCircle2, FileText, Pill, FlaskConical, Calendar, User, Activity, DollarSign, Printer } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState } from '../../types/caseflow';

const fmtCost = (min: number, max: number) => `₹${(min / 1000).toFixed(0)}k – ${(max / 1000).toFixed(0)}k`;

interface Props { data: CaseFlowState; onSave: () => void; }

export const Step6Report = ({ data, onSave }: Props) => {
  const { patient, visit, prescription } = data;
  const [saved,    setSaved]    = useState(false);
  const [shared,   setShared]   = useState(false);
  const [printing, setPrinting] = useState(false);

  const handleSave = () => { setSaved(true); onSave(); setTimeout(() => setSaved(false), 3000); };
  const handleShare = async () => {
    try { await navigator.clipboard.writeText(`Case Report: ${patient.name} · ${patient.reqId}`); } catch { /* */ }
    setShared(true); setTimeout(() => setShared(false), 2500);
  };
  const handlePrint = () => { setPrinting(true); setTimeout(() => { window.print(); setPrinting(false); }, 400); };

  const reportDate = new Date().toLocaleDateString('en-IN', { day: 'numeric', month: 'long', year: 'numeric' });
  const scoreColor = patient.aiScore >= 76 ? 'text-rose-600' : patient.aiScore >= 41 ? 'text-amber-600' : 'text-emerald-600';
  const scoreBg    = patient.aiScore >= 76 ? 'bg-rose-50 border-rose-200' : patient.aiScore >= 41 ? 'bg-amber-50 border-amber-200' : 'bg-emerald-50 border-emerald-200';

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* ── Action bar ── */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="flex items-center gap-2 flex-1 min-w-0">
          <div className="w-8 h-8 bg-teal-500 rounded-xl flex items-center justify-center shrink-0">
            <FileText className="w-4 h-4 text-white" />
          </div>
          <div className="min-w-0">
            <p className="font-black text-slate-800 text-[14px] leading-tight">Final Case Report</p>
            <p className="text-[11px] text-slate-500 font-medium">{patient.reqId} · Generated {reportDate}</p>
          </div>
        </div>
        <div className="flex items-center gap-2 shrink-0 flex-wrap">
          <button onClick={handleShare}
            className="flex items-center gap-1.5 text-[12px] font-bold px-3.5 py-2 rounded-xl border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-all shadow-sm">
            {shared ? <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" /> : <Share2 className="w-3.5 h-3.5" />}
            {shared ? 'Copied!' : 'Share'}
          </button>
          <button onClick={handlePrint}
            className="flex items-center gap-1.5 text-[12px] font-bold px-3.5 py-2 rounded-xl border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-all shadow-sm">
            <Printer className="w-3.5 h-3.5" />
            {printing ? 'Preparing…' : 'Print / PDF'}
          </button>
          <button onClick={handlePrint}
            className="flex items-center gap-1.5 text-[12px] font-bold px-3.5 py-2 rounded-xl border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-all shadow-sm">
            <Download className="w-3.5 h-3.5" /> Export
          </button>
          <button onClick={handleSave}
            className={cn('flex items-center gap-1.5 text-[12px] font-bold px-4 py-2 rounded-xl transition-all shadow-sm active:scale-95',
              saved ? 'bg-emerald-500 text-white border-emerald-500' : 'bg-slate-900 hover:bg-slate-800 text-white')}>
            {saved ? <CheckCircle2 className="w-3.5 h-3.5" /> : <Save className="w-3.5 h-3.5" />}
            {saved ? 'Saved!' : 'Save Case'}
          </button>
        </div>
      </div>

      {/* ── Report card ── */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden print:shadow-none print:border-0">

        {/* Report header */}
        <div className="bg-gradient-to-r from-slate-900 to-slate-800 px-6 py-5">
          <div className="flex items-start justify-between flex-wrap gap-3">
            <div>
              <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mb-1">Medical Case Report</p>
              <h2 className="text-white font-black text-2xl tracking-tight">{patient.name}</h2>
              <p className="text-slate-400 text-[12px] font-medium mt-0.5">{patient.reqId} · {patient.idNumber}</p>
            </div>
            <div className={cn('text-right px-3 py-2 rounded-xl border', scoreBg)}>
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">AI Risk Score</p>
              <p className={cn('font-black text-xl', scoreColor)}>{patient.aiScore}<span className="text-slate-400 text-sm font-bold">/100</span></p>
            </div>
          </div>
        </div>

        <div className="p-6 space-y-6">

          {/* Section 1: Patient Details */}
          <section>
            <div className="flex items-center gap-2 mb-3">
              <User className="w-4 h-4 text-slate-400" />
              <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Patient Details</h3>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {[
                { label: 'Full Name',    value: patient.name        },
                { label: 'Age / Gender', value: `${patient.age} yrs · ${patient.gender}` },
                { label: 'Blood Group',  value: patient.bloodGroup  },
                { label: 'Birth Date',   value: patient.birthDate   },
              ].map(({ label, value }) => (
                <div key={label} className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                  <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
                  <p className="text-[13px] font-black text-slate-800">{value}</p>
                </div>
              ))}
            </div>
          </section>

          <div className="border-t border-slate-100" />

          {/* Section 2: Visit Details */}
          <section>
            <div className="flex items-center gap-2 mb-3">
              <Activity className="w-4 h-4 text-slate-400" />
              <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Visit Details</h3>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {[
                { label: 'Visit Type',       value: visit.visitType === 'online' ? 'Online (Video)' : 'Offline (OPD)'     },
                { label: 'Purpose',          value: visit.purpose.charAt(0).toUpperCase() + visit.purpose.slice(1)         },
                { label: 'Appointment',      value: visit.appointmentTime || '—'                                           },
                { label: 'Payment',          value: visit.paymentStatus.charAt(0).toUpperCase() + visit.paymentStatus.slice(1) },
              ].map(({ label, value }) => (
                <div key={label} className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                  <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
                  <p className="text-[13px] font-black text-slate-800">{value}</p>
                </div>
              ))}
            </div>
          </section>

          <div className="border-t border-slate-100" />

          {/* Section 3: Diagnosis + Procedure */}
          <section>
            <div className="flex items-center gap-2 mb-3">
              <FileText className="w-4 h-4 text-slate-400" />
              <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Diagnosis & Procedure</h3>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div className="bg-slate-50 rounded-xl p-4 border border-slate-100">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5">Primary Diagnosis</p>
                <p className="text-[13px] font-bold text-slate-800">{prescription.diagnosis || patient.diagnosis}</p>
              </div>
              <div className="bg-slate-50 rounded-xl p-4 border border-slate-100">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5">Procedure</p>
                <p className="text-[13px] font-bold text-slate-800">{patient.procedure}</p>
              </div>
            </div>
          </section>

          {/* Section 4: Prescriptions */}
          {prescription.medicines.length > 0 && (
            <>
              <div className="border-t border-slate-100" />
              <section>
                <div className="flex items-center gap-2 mb-3">
                  <Pill className="w-4 h-4 text-teal-500" />
                  <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Prescribed Medicines</h3>
                </div>
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-teal-50 text-[10px] font-bold text-teal-600 uppercase tracking-widest">
                        <th className="px-4 py-2.5 rounded-tl-xl">#</th>
                        <th className="px-4 py-2.5">Medicine</th>
                        <th className="px-4 py-2.5">Dosage</th>
                        <th className="px-4 py-2.5">Frequency</th>
                        <th className="px-4 py-2.5 rounded-tr-xl">Duration</th>
                      </tr>
                    </thead>
                    <tbody>
                      {prescription.medicines.map((med, i) => (
                        <tr key={med.id} className="border-b border-slate-100 last:border-0 text-[13px]">
                          <td className="px-4 py-3 text-slate-400 font-bold">{i + 1}</td>
                          <td className="px-4 py-3 font-black text-slate-800">{med.name}</td>
                          <td className="px-4 py-3 font-medium text-slate-600">{med.dosage}</td>
                          <td className="px-4 py-3 font-medium text-slate-600">{med.frequency}</td>
                          <td className="px-4 py-3 font-medium text-slate-600">{med.duration}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </section>
            </>
          )}

          {/* Section 5: Tests */}
          {prescription.tests.length > 0 && (
            <>
              <div className="border-t border-slate-100" />
              <section>
                <div className="flex items-center gap-2 mb-3">
                  <FlaskConical className="w-4 h-4 text-purple-500" />
                  <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Recommended Tests</h3>
                </div>
                <div className="flex flex-wrap gap-2">
                  {prescription.tests.map(t => (
                    <span key={t} className="text-[12px] font-bold text-purple-700 bg-purple-50 border border-purple-100 px-3 py-1 rounded-xl">
                      {t}
                    </span>
                  ))}
                </div>
              </section>
            </>
          )}

          {/* Section 6: Instructions + Follow-up */}
          {(prescription.instructions || prescription.followUpDate) && (
            <>
              <div className="border-t border-slate-100" />
              <section>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {prescription.instructions && (
                    <div>
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Patient Instructions</p>
                      <p className="text-[13px] font-medium text-slate-700 bg-amber-50 border border-amber-100 rounded-xl p-3">
                        {prescription.instructions}
                      </p>
                    </div>
                  )}
                  {prescription.followUpDate && (
                    <div>
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Follow-up Scheduled</p>
                      <div className="flex items-center gap-3 bg-blue-50 border border-blue-100 rounded-xl p-3">
                        <Calendar className="w-5 h-5 text-blue-500 shrink-0" />
                        <p className="text-[13px] font-black text-blue-700">
                          {new Date(prescription.followUpDate).toLocaleDateString('en-IN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              </section>
            </>
          )}

          {/* Section 7: Cost Summary */}
          <div className="border-t border-slate-100" />
          <section>
            <div className="flex items-center gap-2 mb-3">
              <DollarSign className="w-4 h-4 text-slate-400" />
              <h3 className="font-black text-slate-700 text-[13px] uppercase tracking-widest">Cost Estimation</h3>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              <div className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-1">Est. Cost Range</p>
                <p className="text-[14px] font-black text-teal-600">{fmtCost(patient.costMin, patient.costMax)}</p>
              </div>
              <div className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-1">Urgency</p>
                <p className="text-[13px] font-black text-slate-800">{patient.urgency}</p>
              </div>
              <div className="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest mb-1">Payment Status</p>
                <p className="text-[13px] font-black text-slate-800 capitalize">{visit.paymentStatus}</p>
              </div>
            </div>
          </section>

          {/* Footer */}
          <div className="border-t border-slate-100 pt-4 flex items-center justify-between">
            <p className="text-[11px] text-slate-400 font-medium">Generated by SanjivaniAI · {reportDate}</p>
            <div className="flex items-center gap-1.5 text-[11px] font-bold text-emerald-600">
              <CheckCircle2 className="w-3.5 h-3.5" /> Report Complete
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
