import { Zap, Calendar, AlertTriangle, FileText, History } from 'lucide-react';

interface Props {
  onSelect: (prompt: string) => void;
}

const SUGGESTIONS = [
  {
    text: "What is my schedule looking like today?",
    icon: <Calendar className="w-5 h-5 text-blue-500" />,
    title: "Schedule"
  },
  {
    text: "Are there any critical SOS alerts right now?",
    icon: <AlertTriangle className="w-5 h-5 text-red-500" />,
    title: "Critical Alerts"
  },
  {
    text: "Draft a prescription for paracetamol 500mg.",
    icon: <FileText className="w-5 h-5 text-emerald-500" />,
    title: "Prescription"
  },
  {
    text: "Show me the patient history for Suresh Patel.",
    icon: <History className="w-5 h-5 text-purple-500" />,
    title: "Patient History"
  }
];

export const PromptSuggestions = ({ onSelect }: Props) => {
  return (
    <div className="w-full max-w-2xl mt-8">
      <div className="flex items-center justify-center gap-2 text-xs font-bold text-slate-400 mb-6 px-1 uppercase tracking-widest">
        <Zap className="w-3.5 h-3.5 text-amber-500" />
        <span>Suggested Actions</span>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {SUGGESTIONS.map((suggestion, i) => (
          <button
            key={i}
            onClick={() => onSelect(suggestion.text)}
            className="flex flex-col items-start text-left bg-white border border-slate-200/60 hover:border-indigo-300 hover:shadow-md hover:shadow-indigo-500/5 rounded-2xl p-4 transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-indigo-500/30 group"
          >
            <div className="bg-slate-50 p-2 rounded-xl mb-3 group-hover:scale-110 transition-transform">
               {suggestion.icon}
            </div>
            <span className="font-semibold text-slate-700 mb-1">{suggestion.title}</span>
            <span className="text-xs text-slate-500 line-clamp-1">{suggestion.text}</span>
          </button>
        ))}
      </div>
    </div>
  );
};