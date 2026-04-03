import React from 'react';
import { Download, ChevronRight, Hash, Hospital, Activity } from 'lucide-react';

const mockReferrals = [
  { refId: 'REF-3021', caseId: 'CAS-1109', from: 'Dr. Sarah Jenkins', to: 'City General Hospital', type: 'MRI Scan', status: 'Booked', date: 'Oct 24, 2026' },
  { refId: 'REF-3020', caseId: 'CAS-1106', from: 'Dr. Alan Turing', to: 'Apex Labs', type: 'Blood Panel', status: 'Completed', date: 'Oct 23, 2026' },
  { refId: 'REF-3019', caseId: 'CAS-1099', from: 'Dr. Emily Chen', to: 'Riverside Clinic', type: 'Surgery', status: 'Pending', date: 'Oct 22, 2026' },
];

export const Referrals: React.FC = () => {
  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight">Referrals & Partner Bookings</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Track patient handoffs between doctors and lab/hospital partners</p>
        </div>
        <button className="bg-teal-600 hover:bg-teal-700 text-white px-5 py-2.5 rounded-xl text-sm font-medium transition flex items-center gap-2">
          <Download className="h-4 w-4" /> Export Report
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
            <div className="p-4 bg-teal-50 text-teal-600 rounded-[1.25rem]"><Activity className="h-6 w-6 stroke-[2]" /></div>
            <div>
              <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">Total Referrals</p>
              <p className="text-3xl font-extrabold text-slate-800 tabular-nums">1,402</p>
            </div>
         </div>
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
            <div className="p-4 bg-emerald-50 text-emerald-600 rounded-[1.25rem]"><Hospital className="h-6 w-6 stroke-[2]" /></div>
            <div>
              <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">Conversion Rate</p>
              <p className="text-3xl font-extrabold text-slate-800 tabular-nums">68.4%</p>
            </div>
         </div>
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
            <div className="p-4 bg-purple-50 text-purple-600 rounded-[1.25rem]"><Hash className="h-6 w-6 stroke-[2]" /></div>
            <div>
              <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">Active Partners</p>
              <p className="text-3xl font-extrabold text-slate-800 tabular-nums">48</p>
            </div>
         </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200/60 overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-slate-50 border-b border-slate-100">
             <tr className="text-slate-500 font-bold uppercase tracking-wider text-[11px]">
               <th className="px-6 py-4">Ref ID</th>
               <th className="px-6 py-4">Origin Case</th>
               <th className="px-6 py-4">Referred By</th>
               <th className="px-6 py-4">Partner Destination</th>
               <th className="px-6 py-4">Service Type</th>
               <th className="px-6 py-4">Status</th>
               <th className="px-6 py-4"></th>
             </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {mockReferrals.map((r, i) => (
               <tr key={i} className="hover:bg-slate-50/50 transition cursor-pointer group">
                  <td className="px-6 py-4 text-sm font-mono font-bold text-slate-600">{r.refId}</td>
                  <td className="px-6 py-4 text-sm font-bold text-teal-600 hover:underline">{r.caseId}</td>
                  <td className="px-6 py-4 text-sm font-semibold text-slate-800">{r.from}</td>
                  <td className="px-6 py-4 text-sm font-semibold text-slate-600">{r.to}</td>
                  <td className="px-6 py-4 text-sm font-medium text-slate-500">{r.type}</td>
                  <td className="px-6 py-4">
                     <span className={`px-2.5 py-1 rounded-md text-[10px] uppercase font-extrabold tracking-widest ${
                       r.status === 'Completed' ? 'bg-emerald-100 text-emerald-700 ring-1 ring-emerald-500/20' :
                       r.status === 'Booked' ? 'bg-blue-100 text-blue-700 ring-1 ring-blue-500/20' :
                       'bg-amber-100 text-amber-700 ring-1 ring-amber-500/20'
                     }`}>
                       {r.status}
                     </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button className="p-1.5 text-slate-400 hover:text-slate-800 bg-slate-100 hover:bg-slate-200 rounded transition"><ChevronRight className="h-4 w-4" /></button>
                  </td>
               </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
