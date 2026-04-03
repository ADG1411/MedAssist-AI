import { Sparkles, ArrowRight } from 'lucide-react';

export const AIAssistant = () => {
  return (
    <div className="bg-gradient-to-br from-brand-blue to-purple-600 rounded-3xl p-6 text-white shadow-md relative overflow-hidden mt-6">
      <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full blur-2xl -translate-y-1/2 translate-x-1/2"></div>
      
      <div className="flex items-center gap-2 mb-4 relative z-10">
        <Sparkles className="w-5 h-5 text-amber-300" />
        <h3 className="font-bold text-lg">AI Assistant</h3>
      </div>
      
      <p className="text-sm text-blue-100 mb-5 relative z-10">
        Complete these suggestions to boost your profile visibility by 40%.
      </p>

      <div className="space-y-3 relative z-10">
        <button className="w-full bg-white/10 hover:bg-white/20 border border-white/20 p-3 rounded-xl flex items-center justify-between text-left transition-colors group text-sm">
          <span className="font-medium">Add profile intro video</span>
          <ArrowRight className="w-4 h-4 text-white/50 group-hover:text-white transition-colors" />
        </button>
        <button className="w-full bg-white/10 hover:bg-white/20 border border-white/20 p-3 rounded-xl flex items-center justify-between text-left transition-colors group text-sm">
          <span className="font-medium">Upload missing certificate</span>
          <ArrowRight className="w-4 h-4 text-white/50 group-hover:text-white transition-colors" />
        </button>
      </div>
    </div>
  );
};