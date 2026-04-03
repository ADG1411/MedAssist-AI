import React from 'react';
import { Siren, Activity, PhoneCall, AlertTriangle, ShieldAlert } from 'lucide-react';

const liveEmergencies = [
  { id: '#EMG-9021', patient: 'Unknown Male (Trauma)', location: 'Sector 4, Main St', status: 'Ambulance Dispatched', time: 'Just now', eta: '4 min' },
  { id: '#EMG-9020', patient: 'Sarah Jenkins (Cardiac)', location: 'Remote Consult', status: 'Doctor Assigned', time: '2 mins ago', eta: 'Live' },
];

export const Emergency: React.FC = () => {
  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight flex items-center gap-3">
             <span className="p-2 bg-rose-100 text-rose-600 rounded-[1.25rem] ring-4 ring-rose-50 animate-pulse"><Siren className="h-6 w-6 stroke-[2.5]" /></span>
             Emergency Command
          </h1>
          <p className="text-slate-500 font-medium text-sm mt-3 ml-[3.25rem]">Central command for critical response and escalation</p>
        </div>
        <div className="flex gap-3">
          <button className="bg-rose-600 hover:bg-rose-700 text-white px-5 py-2.5 rounded-xl font-bold transition shadow-sm ring-1 ring-rose-500/20 flex items-center gap-2">
            <PhoneCall className="h-4 w-4" /> Broadcast Alert
          </button>
        </div>
      </div>

      <div className="bg-rose-50 border border-rose-200 p-6 rounded-2xl mb-8 flex justify-between items-center shadow-inner relative overflow-hidden">
         <div className="absolute top-0 right-0 w-64 h-64 bg-rose-500 rounded-full blur-[80px] opacity-20 -mr-10 -mt-10"></div>
         <div>
            <h2 className="text-xl font-bold text-rose-900 flex items-center gap-2">
              <AlertTriangle className="h-5 w-5" /> 2 Active Critical Escalations
            </h2>
            <p className="text-rose-700 text-sm font-medium mt-1">Average response time currently at 1.2 minutes. System operating normally.</p>
         </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200/60 overflow-hidden h-[500px] flex flex-col">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex justify-between items-center">
            <h2 className="text-base font-bold text-slate-800">Live Incident Feed</h2>
             <span className="flex h-2 w-2 relative">
               <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
               <span className="relative inline-flex rounded-full h-2 w-2 bg-rose-500"></span>
             </span>
          </div>
          <div className="p-6 flex-1 overflow-y-auto space-y-4">
             {liveEmergencies.map((emg, i) => (
               <div key={i} className="border border-slate-200 rounded-xl p-4 bg-white shadow-sm ring-1 ring-slate-100/50 hover:border-rose-300 transition-colors">
                  <div className="flex justify-between items-start mb-3">
                     <div className="flex items-center gap-2">
                        <span className="font-mono text-sm font-black text-rose-700">{emg.id}</span>
                        <span className="bg-rose-100 text-rose-800 text-[10px] uppercase font-bold tracking-widest px-2 py-0.5 rounded flex items-center gap-1">
                          <Activity className="h-3 w-3" /> {emg.status}
                        </span>
                     </div>
                     <span className="text-xs font-bold text-slate-400">{emg.time}</span>
                  </div>
                  <h3 className="font-bold text-slate-800">{emg.patient}</h3>
                  <p className="text-sm font-medium text-slate-500 flex items-center gap-1.5 mt-1">
                    <ShieldAlert className="h-3.5 w-3.5 text-slate-400" /> {emg.location}
                  </p>
                  
                  <div className="flex justify-between items-center mt-4 pt-4 border-t border-slate-100">
                     <span className="text-sm font-bold text-slate-600 bg-slate-100 px-3 py-1 rounded">ETA: {emg.eta}</span>
                     <button className="text-white bg-slate-900 hover:bg-slate-800 px-4 py-1.5 rounded-lg text-xs font-bold transition shadow">Assign Doctor</button>
                  </div>
               </div>
             ))}
          </div>
        </div>

        <div className="bg-slate-100 rounded-2xl border border-slate-200/80 shadow-inner h-[500px] flex items-center justify-center relative overflow-hidden">
          {/* Mock Map View */}
          <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>
          <div className="text-center relative z-10 p-8">
             <div className="h-16 w-16 bg-white rounded-full flex items-center justify-center mx-auto shadow-md mb-4 ring-4 ring-white/50 border border-slate-200">
               <Activity className="h-8 w-8 text-teal-600" />
             </div>
             <h3 className="text-lg font-bold text-slate-800">Map Integration Disabled</h3>
             <p className="text-sm font-medium text-slate-500 mt-2">Connect Google Maps or Mapbox API in Settings to view live ambulance tracking.</p>
             <button className="mt-6 px-5 py-2 bg-white text-slate-700 text-sm font-bold shadow-sm rounded-xl border border-slate-200 hover:bg-slate-50 transition">Configure Map API</button>
          </div>
        </div>
      </div>
    </div>
  );
};
