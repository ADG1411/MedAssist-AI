import { Mic, Camera, PhoneOff, Activity, Heart, Wind, Droplet } from 'lucide-react';
import type { Emergency } from '../../types/emergency';

export const ActiveEmergencyPanel = ({ emergency }: { emergency: Emergency }) => {
  return (
    <div className="flex-1 flex flex-col h-full bg-white rounded-2xl md:rounded-3xl overflow-hidden border border-slate-200 shadow-sm relative">
       {/* Main Video Area (Patient) */}
       <div className="flex-1 relative bg-slate-900 flex flex-col items-center justify-center min-h-[400px]">
          <div className="absolute inset-0 opacity-30 bg-[url('https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=2070&auto=format&fit=crop')] bg-cover bg-center"></div>
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/30"></div>
          
          <div className="relative z-10 text-center">
            <Activity className="w-12 h-12 md:w-16 md:h-16 text-red-500 mx-auto mb-2 md:mb-4 opacity-70 animate-pulse" />
            <p className="text-red-400 font-bold tracking-widest uppercase text-xs md:text-base">Connecting to First Responder...</p>
            <p className="text-white font-bold text-xl md:text-2xl mt-2">{emergency.patientName}</p>
          </div>

          {/* Patient Vitals Overlay */}
          {emergency.vitals && (
            <div className="absolute top-4 left-4 bg-black/60 backdrop-blur-md border border-slate-700 p-2 md:p-3 rounded-xl flex gap-2 md:gap-4 text-white scale-90 md:scale-100 origin-top-left">
              <div className="text-center min-w-[50px]">
                <Heart className="w-4 h-4 md:w-5 md:h-5 text-red-500 mx-auto mb-1 animate-pulse" />
                <div className="text-lg md:text-xl font-bold">{emergency.vitals.heartRate}</div>
                <div className="text-[10px] text-slate-400">BPM</div>
              </div>
              <div className="w-px bg-slate-700"></div>
              <div className="text-center min-w-[50px]">
                <Activity className="w-4 h-4 md:w-5 md:h-5 text-cyan-400 mx-auto mb-1" />
                <div className="text-lg md:text-xl font-bold">{emergency.vitals.oxygen}<span className="text-sm">%</span></div>
                <div className="text-[10px] text-slate-400">SpO2</div>
              </div>
            </div>
          )}

          {/* Timer & Status */}
          <div className="absolute top-4 right-4 bg-red-600 px-3 py-1.5 rounded-full text-white text-xs font-bold flex items-center gap-2 shadow-lg">
             <span className="w-2 h-2 rounded-full bg-white animate-pulse"></span>
             REC 00:14
          </div>

          {/* Self Video PIP */}
          <div className="absolute bottom-24 md:bottom-28 right-4 w-24 h-32 md:w-32 md:h-44 bg-slate-800 rounded-xl overflow-hidden border-2 border-slate-600 shadow-lg z-20">
             <img src="https://ui-avatars.com/api/?name=Dr.+Sarah&background=1A6BFF&color=fff" className="w-full h-full object-cover" alt="Doctor" />
          </div>

          {/* Call Controls */}
          <div className="absolute bottom-4 md:bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 md:gap-4 bg-black/80 backdrop-blur-md px-4 md:px-6 py-2 md:py-3 rounded-full border border-slate-700 z-20">
            <button className="p-2.5 md:p-3 bg-slate-700 hover:bg-slate-600 rounded-full text-white transition-colors"><Mic className="w-4 h-4 md:w-5 md:h-5" /></button>
            <button className="p-2.5 md:p-3 bg-slate-700 hover:bg-slate-600 rounded-full text-white transition-colors"><Camera className="w-4 h-4 md:w-5 md:h-5" /></button>
            <button className="px-4 py-2 md:px-6 md:py-2.5 bg-red-600 hover:bg-red-700 font-bold rounded-full text-white transition-colors shadow-lg flex items-center gap-2 text-sm md:text-base">
              <PhoneOff className="w-4 h-4 md:w-5 md:h-5" /> <span className="hidden sm:inline">End Call</span>
            </button>
          </div>
       </div>

       {/* Quick Instructions Bottom Bar */}
       <div className="h-20 bg-white border-t border-slate-200 px-4 md:px-6 flex items-center gap-2 md:gap-3 overflow-x-auto hide-scrollbar z-30">
         <span className="text-[10px] md:text-xs text-slate-400 font-bold uppercase tracking-wider shrink-0 mr-1 md:mr-2">Quick Commands:</span>

         <button className="shrink-0 flex items-center gap-2 bg-red-50 text-red-600 border border-red-100 hover:bg-red-100 px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-bold transition-colors">
            <Heart className="w-4 h-4" /> Start CPR
         </button>
         <button className="shrink-0 flex items-center gap-2 bg-slate-50 text-slate-600 border border-slate-200 hover:bg-slate-100 px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-bold transition-colors">
            <Wind className="w-4 h-4" /> Clear Airway
         </button>
         <button className="shrink-0 flex items-center gap-2 bg-slate-50 text-slate-600 border border-slate-200 hover:bg-slate-100 px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-bold transition-colors">
            <Droplet className="w-4 h-4" /> Apply Pressure
         </button>
       </div>
    </div>
  );
};