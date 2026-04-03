import { Sparkles, TrendingUp, AlertTriangle, Clock } from 'lucide-react';

export const AIInsights = () => {
  return (
    <div className="bg-gradient-to-br from-indigo-900 via-slate-900 to-slate-800 rounded-[1.5rem] p-6 shadow-xl text-white relative overflow-hidden h-full border border-slate-700/50">
      <div className="absolute top-0 right-0 w-64 h-64 bg-brand-blue rounded-full filter blur-[80px] opacity-20 pointer-events-none -mr-20 -mt-20"></div>
      <div className="absolute bottom-0 left-0 w-64 h-64 bg-purple-600 rounded-full filter blur-[80px] opacity-20 pointer-events-none -ml-20 -mb-20"></div>
      
      <div className="relative z-10">
        <h3 className="flex items-center gap-2 text-lg font-black text-white mb-6">
          <Sparkles className="w-5 h-5 text-blue-400" /> AI Practice Insights
        </h3>
        
        <div className="space-y-4">
          <div className="bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/10 hover:bg-white/15 transition-colors group">
            <div className="flex gap-3">
              <div className="bg-blue-500/20 p-2 rounded-xl h-fit">
                 <TrendingUp className="w-5 h-5 text-blue-300" />
              </div>
              <div>
                <h4 className="text-[14px] font-bold text-blue-100 mb-1">Patient Load Increased</h4>
                <p className="text-[13px] text-slate-300 font-medium leading-relaxed">
                  Your patient load increased by <span className="text-white font-bold">20%</span> this week. Most cases are related to Diabetes & Hypertension.
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/10 hover:bg-white/15 transition-colors group">
            <div className="flex gap-3">
              <div className="bg-purple-500/20 p-2 rounded-xl h-fit">
                 <Clock className="w-5 h-5 text-purple-300" />
              </div>
              <div>
                <h4 className="text-[14px] font-bold text-purple-100 mb-1">Schedule Optimization</h4>
                <p className="text-[13px] text-slate-300 font-medium leading-relaxed">
                  You are spending <span className="text-white font-bold">15% more time</span> per patient. Suggestion: Add more buffer slots on Mondays to prevent delays.
                </p>
                <button className="mt-3 bg-white/20 hover:bg-white/30 text-white text-[12px] font-bold px-4 py-2 rounded-lg transition-colors">
                  Adjust Monday Slots
                </button>
              </div>
            </div>
          </div>

          <div className="bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/10 hover:bg-white/15 transition-colors group">
            <div className="flex gap-3">
              <div className="bg-amber-500/20 p-2 rounded-xl h-fit">
                 <AlertTriangle className="w-5 h-5 text-amber-300" />
              </div>
              <div>
                <h4 className="text-[14px] font-bold text-amber-100 mb-1">Predictive Alert</h4>
                <p className="text-[13px] text-slate-300 font-medium leading-relaxed">
                  High chance of emergency cases tomorrow due to sudden weather drop. Ensure ER availability.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};