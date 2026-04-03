import { AlertOctagon, Brain, Zap } from 'lucide-react';

export const AIEmergencyAssistant = () => {
  return (
    <div className="bg-white rounded-2xl border border-slate-200 p-4 flex flex-col flex-1 min-h-[250px] lg:h-1/2 relative overflow-hidden shadow-sm">
       {/* Background subtle glow */}
       <div className="absolute -top-10 -right-10 w-32 h-32 bg-purple-50 blur-[50px] rounded-full pointer-events-none"></div>

       <div className="flex items-center gap-2 mb-4 border-b border-slate-200 pb-3 relative z-10">
          <Brain className="w-5 h-5 text-purple-600" />
          <h3 className="text-slate-800 font-bold text-sm md:text-base">AI Medical Co-Pilot</h3>
          <span className="ml-auto flex h-2 w-2 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-purple-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-purple-500"></span>
          </span>
       </div>

       <div className="flex-1 overflow-y-auto space-y-3 pr-2 custom-scrollbar relative z-10">

         <div className="bg-red-50 border border-red-100 p-3.5 rounded-xl hover:bg-red-100 transition-colors">
            <div className="flex gap-3 items-start text-red-600">
               <AlertOctagon className="w-5 h-5 mt-0.5 shrink-0" />
               <div>
                 <p className="font-bold text-sm">Critical Airway Risk Detected</p>
                 <p className="text-xs text-red-500 mt-1.5 leading-relaxed">    
                   Patient oxygen dropping rapidly. Instruct bystander to clear airway immediately by tilting head back.
                 </p>
               </div>
            </div>
         </div>

<div className="bg-purple-50 border border-purple-100 p-3.5 rounded-xl hover:bg-purple-100 transition-colors">
            <div className="flex gap-3 items-start text-purple-600">
               <Zap className="w-5 h-5 mt-0.5 shrink-0" />
               <div>
                 <p className="font-bold text-sm">Protocol Suggestion</p>
                 <p className="text-xs text-purple-600 mt-1.5 leading-relaxed"> 
                   High probability of cardiac event based on vitals. Nearest known public defibrillator is 200m away at Mall Entrance.
                 </p>
               </div>
            </div>
         </div>

       </div>
    </div>
  );
};