import { useState } from 'react';
import { mockEmergencies } from '../data/mockEmergencies';
import type { Emergency } from '../types/emergency';
import { EmergencyCard } from '../components/emergency/EmergencyCard';
import { ActiveEmergencyPanel } from '../components/emergency/ActiveEmergencyPanel';
import { MapPanel } from '../components/emergency/MapPanel';
import { AIEmergencyAssistant } from '../components/emergency/AIEmergencyAssistant';
import { AlertTriangle, Wifi, ShieldAlert, ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function EmergencyAlerts() {
  const navigate = useNavigate();
  const [feed, setFeed] = useState<Emergency[]>(mockEmergencies);
  const [activeCase, setActiveCase] = useState<Emergency | null>(null);

  const handleAccept = (id: string) => {
     const target = feed.find(e => e.id === id);
     if(target) {
        setActiveCase(target);
        setFeed(prev => prev.filter(e => e.id !== id));
     }
  };

  const handleReject = (id: string) => {
     setFeed(prev => prev.filter(e => e.id !== id));
  };

  return (
    <div className="bg-[#F9FBFF] min-h-[calc(100vh-80px)] md:min-h-screen text-slate-800 font-sans p-3 sm:p-4 md:p-6 lg:p-8 flex flex-col">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div className="flex items-center gap-3">
          <button 
            onClick={() => navigate(-1)} 
            className="p-2 sm:mr-2 bg-white hover:bg-slate-100 rounded-full text-slate-600 transition-colors shadow-sm border border-slate-200 flex-shrink-0"
            title="Go Back"
          >
            <ArrowLeft className="w-5 h-5 md:w-6 md:h-6" />
          </button>
          <div className="bg-red-50 p-2.5 rounded-xl border border-red-100">
             <ShieldAlert className="w-6 h-6 md:w-8 md:h-8 text-red-600 animate-pulse" />
          </div>
          <div>
            <h1 className="text-xl md:text-2xl lg:text-3xl font-black text-slate-900 tracking-wide">SOS COMMAND CENTER</h1>
            <p className="text-slate-500 text-xs md:text-sm font-medium mt-0.5">Real-time Emergency Dispatch & Consultation</p>
          </div>
        </div>
        
        {/* Status Indicator */}
        <div className="flex items-center gap-3 bg-white border border-slate-200 px-4 py-2.5 rounded-full shadow-sm self-start sm:self-auto">
          <div className="relative flex h-2.5 w-2.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
          </div>
          <span className="text-sm font-bold text-slate-700 flex items-center gap-2">
            <Wifi className="w-4 h-4 text-emerald-500" />
            System Online
          </span>
        </div>
      </div>

      <div className="flex-1 flex flex-col lg:flex-row gap-6 min-h-0">
         
         {/* LEFT COLUMN: Feed */}
         <div className="w-full lg:w-[320px] xl:w-[380px] flex flex-col gap-4 h-[350px] lg:h-auto overflow-y-auto custom-scrollbar shrink-0 pr-1">
           <h2 className="text-xs md:text-sm border-b border-slate-200 pb-3 font-bold text-slate-500 uppercase tracking-widest flex justify-between items-center bg-[#F9FBFF] sticky top-0 z-10">
             <span className="flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-orange-500" />
                Incoming Alerts
             </span>
             <span className="bg-red-600 text-white px-2.5 py-0.5 rounded-full text-[10px] shadow-sm">
               {feed.length}
             </span>
           </h2>

           <div className="space-y-4 pb-safe lg:pb-4 flex-1">
             {feed.length === 0 && !activeCase && (
               <div className="flex flex-col items-center justify-center h-40 text-slate-400">
                  <ShieldAlert className="w-10 h-10 mb-2" />
                  <p className="text-sm font-medium border border-slate-200 px-4 py-1.5 rounded-full bg-white">No active emergencies.</p>
               </div>
             )}
             {feed.map(em => (
               <EmergencyCard key={em.id} emergency={em} onAccept={handleAccept} onReject={handleReject} />
             ))}
           </div>
         </div>

         {/* MAIN WORKSPACE */}
         {activeCase ? (
           <div className="flex-1 flex flex-col xl:flex-row gap-6 min-h-0 animate-in fade-in zoom-in-95 duration-300 h-auto">
             
             {/* Center: Video & Action */}
             <div className="flex-1 min-h-[500px] xl:min-h-0">
                <ActiveEmergencyPanel emergency={activeCase} />
             </div>

             {/* Right: Map & AI */}
             <div className="w-full xl:w-[350px] xl:h-full flex flex-col gap-6">
                <MapPanel location={activeCase.location} distance={activeCase.distance} />
                <AIEmergencyAssistant />
             </div>

           </div>
         ) : (
            <div className="flex-1 hidden lg:flex flex-col items-center justify-center border-2 border-dashed border-slate-300 rounded-3xl bg-white shadow-sm">    
              <div className="relative mb-6">
                <div className="absolute inset-0 bg-red-100 blur-xl rounded-full"></div>
                <div className="bg-slate-50 border border-slate-200 p-6 rounded-full relative z-10">
                  <ShieldAlert className="w-12 h-12 text-slate-400" />
                </div>
              </div>
              <h3 className="text-xl font-bold text-slate-700">Standby for emergency signals</h3>
            </div>
         )}

      </div>

    </div>
  );
}