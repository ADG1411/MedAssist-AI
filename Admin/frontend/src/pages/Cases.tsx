import React, { useState } from 'react';
import { Search, Filter, AlertTriangle, ArrowRight, UserCircle, Activity } from 'lucide-react';

const activeCases = [
  { id: '#CAS-1109', patient: 'Mark Williams', doctor: 'Dr. Sarah Jenkins', status: 'In Progress', priority: 'Critical', time: '10 mins ago', type: 'Cardiology' },
  { id: '#CAS-1110', patient: 'Emily Chen', doctor: 'Dr. Alan Turing', status: 'Open', priority: 'High', time: '1 hr ago', type: 'Neurology' },
  { id: '#CAS-1111', patient: 'David Cho', doctor: 'Unassigned', status: 'Pending', priority: 'Medium', time: '2 hrs ago', type: 'General' },
  { id: '#CAS-1112', patient: 'Anna Lee', doctor: 'Dr. Sarah Jenkins', status: 'Resolved', priority: 'Normal', time: 'Yesterday', type: 'Dermatology' },
];

export const Cases: React.FC = () => {
  const [filter, setFilter] = useState('All');

  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight">Case Management</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Live overview of AI-assisted medical consultations</p>
        </div>
        <div className="flex gap-3">
           <div className="relative">
             <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
             <input type="text" placeholder="Search cases..." className="pl-9 pr-4 py-2 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none text-sm w-64 shadow-sm" />
           </div>
           <button className="bg-white border border-slate-200 text-slate-700 px-4 py-2 rounded-xl shadow-sm hover:bg-slate-50 transition flex items-center gap-2 text-sm font-medium">
             <Filter className="h-4 w-4" /> Filter
           </button>
        </div>
      </div>

      <div className="flex gap-4 mb-6 overflow-x-auto pb-2">
        {['All', 'Critical', 'Unassigned', 'In Progress', 'Resolved'].map(tab => (
          <button 
            key={tab} 
            onClick={() => setFilter(tab)}
            className={`px-5 py-2 rounded-full text-sm font-bold whitespace-nowrap transition-all ${filter === tab ? 'bg-teal-600 text-white shadow-md' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}`}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {activeCases.map((c, i) => (
          <div key={i} className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm hover:shadow-md transition-all group">
            <div className="flex justify-between items-start mb-4">
              <div className="flex items-center gap-2">
                <span className="font-mono text-sm font-bold text-slate-700">{c.id}</span>
                <span className={`text-[10px] uppercase tracking-wider font-extrabold px-2.5 py-1 rounded-md ${
                  c.priority === 'Critical' ? 'bg-rose-100 text-rose-700 ring-1 ring-rose-500/30' : 
                  c.priority === 'High' ? 'bg-orange-100 text-orange-700 ring-1 ring-orange-500/30' : 
                  'bg-teal-100 text-teal-700 ring-1 ring-teal-500/30'
                }`}>{c.priority}</span>
              </div>
              <span className="text-xs font-semibold text-slate-400">{c.time}</span>
            </div>
            
            <div className="space-y-3 mb-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-slate-100 rounded-lg text-slate-500"><UserCircle className="h-5 w-5" /></div>
                <div>
                  <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Patient</p>
                  <p className="text-sm font-bold text-slate-800">{c.patient}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="p-2 bg-slate-100 rounded-lg text-slate-500"><Activity className="h-5 w-5" /></div>
                <div>
                  <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Assigned To</p>
                  <p className={`text-sm font-bold ${c.doctor === 'Unassigned' ? 'text-rose-500' : 'text-slate-800'}`}>{c.doctor}</p>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-4 border-t border-slate-100">
               <span className="text-sm font-medium text-slate-500 bg-slate-50 px-3 py-1 rounded-lg border border-slate-200">{c.type}</span>
               <button className="text-teal-600 hover:text-teal-700 text-sm font-bold flex items-center gap-1 group-hover:underline">
                 View Detail <ArrowRight className="h-4 w-4" />
               </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
