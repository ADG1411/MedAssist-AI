import { Bot } from 'lucide-react';

export const AITypingIndicator = () => {
  return (
    <div className="flex w-full mt-2 space-x-4 max-w-3xl mx-auto self-start">
      <div className="flex-shrink-0 h-9 w-9 rounded-2xl bg-gradient-to-br from-indigo-500 to-cyan-400 flex items-center justify-center shadow-lg shadow-indigo-200 mt-1 animate-pulse">
        <Bot className="h-5 w-5 text-white" />
      </div>

      <div className="flex flex-col space-y-2 text-sm max-w-[85%] items-start">
        <div className="px-5 py-4 rounded-2xl bg-white text-slate-700 border border-slate-200/60 rounded-tl-sm shadow-sm flex items-center gap-1.5 h-[46px]">
          <span className="w-1.5 h-1.5 bg-indigo-500 rounded-full animate-bounce [animation-delay:-0.3s]"></span>
          <span className="w-1.5 h-1.5 bg-indigo-400 rounded-full animate-bounce [animation-delay:-0.15s]"></span>
          <span className="w-1.5 h-1.5 bg-indigo-300 rounded-full animate-bounce"></span>
        </div>
      </div>
    </div>
  );
};