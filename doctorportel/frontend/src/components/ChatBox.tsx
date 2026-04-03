import { useState } from 'react';
import { Send, Mic, Paperclip, Video, CheckCircle, FileText, CheckCheck } from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';

export const ChatBox = () => {
  const [inputStr, setInputStr] = useState('');

  return (
    <div className="flex-1 flex flex-col h-full bg-white relative min-w-0">
      {/* Top Action Bar */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-white z-10">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Consultation</h2>
          <p className="text-xs font-semibold text-emerald-500 flex items-center gap-1">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" /> Patient Online
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button className="flex items-center gap-2 px-3 py-2 bg-slate-50 hover:bg-slate-100 text-slate-700 font-semibold rounded-lg text-sm transition-colors border border-slate-200">
            <Video className="w-4 h-4 text-brand-blue" />
            <span className="hidden sm:inline">Start Video</span>
          </button>
          <button className="flex items-center gap-2 px-3 py-2 bg-brand-blue hover:bg-brand-blue/90 text-white font-semibold rounded-lg text-sm shadow-sm transition-colors">
            <CheckCircle className="w-4 h-4" />
            <span className="hidden sm:inline">Complete</span>
          </button>
        </div>
      </div>

      {/* Chat Messages Area */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar bg-slate-50/50">
        
        {/* Date Divider */}
        <div className="flex justify-center">
          <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 bg-slate-100 rounded-full px-3 py-1">
            Today
          </span>
        </div>

        {/* Patient Message */}
        <div className="flex justify-start">
          <div className="max-w-[80%] bg-white border border-slate-200 rounded-2xl rounded-tl-sm p-4 shadow-sm">
            <p className="text-sm font-medium text-slate-700">
              Hi doctor, I am feeling a bit dizzy today and my BP seems higher than usual. I also uploaded my recent blood work reports.
            </p>
            <p className="text-[10px] text-slate-400 mt-2 font-semibold">10:30 AM</p>
          </div>
        </div>

        {/* Report Block (Inline) */}
        <div className="flex justify-start">
          <div className="max-w-[80%] bg-white border border-slate-200 rounded-2xl p-3 shadow-sm flex items-center gap-3">
             <div className="bg-red-50 p-2 rounded-lg text-red-500">
               <FileText className="w-5 h-5" />
             </div>
             <div>
               <p className="text-sm font-bold text-slate-800">Blood_Work_Oct.pdf</p>
               <p className="text-xs text-slate-500">2.4 MB • Uploaded via App</p>
             </div>
          </div>
        </div>

        {/* Doctor Message */}
        <div className="flex justify-end">
          <div className="max-w-[80%] bg-brand-blue text-white rounded-2xl rounded-tr-sm p-4 shadow-md shadow-brand-blue/20">
            <p className="text-sm font-medium">
              Hello John. I am reviewing your blood work now. Let's do a quick check of your current BP reading if you have the monitor handy.
            </p>
            <div className="flex items-center justify-end gap-1 mt-2">
              <p className="text-[10px] text-brand-light font-semibold">10:35 AM</p>
              <CheckCheck className="w-3 h-3 text-brand-light" />
            </div>
          </div>
        </div>

        {/* Prescription Block (Inline) */}
        <div className="flex justify-end">
          <div className="max-w-[80%] bg-amber-50 border border-amber-100 rounded-2xl rounded-tr-sm p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-2">
              <span className="bg-amber-100 text-amber-700 text-xs font-bold px-2 py-0.5 rounded-md">Rx</span>
              <span className="text-sm font-bold text-slate-800">Suggested Medication</span>
            </div>
            <div className="bg-white rounded-xl p-3 border border-amber-100 mb-2">
               <p className="text-sm font-bold text-slate-800">Lisinopril 10mg</p>
               <p className="text-xs font-medium text-slate-500">1 tablet • Morning • After food</p>
            </div>
            <button className="text-xs font-bold text-amber-700 hover:text-amber-800 transition-colors">
              + Add another medicine
            </button>
          </div>
        </div>

      </div>

      {/* Bottom Input Area */}
      <div className="p-4 bg-white border-t border-slate-100">
        <div className="flex items-end gap-2 bg-slate-50 relative border border-slate-200 rounded-2xl p-2 transition-all focus-within:ring-2 focus-within:ring-brand-blue/20 focus-within:border-brand-blue/50 shadow-sm">
          
          <button className="p-2 text-slate-400 hover:text-brand-blue hover:bg-brand-blue/10 rounded-xl transition-colors shrink-0 mb-1">
            <Paperclip className="w-5 h-5" />
          </button>
          
          <textarea
            value={inputStr}
            onChange={(e) => setInputStr(e.target.value)}
            placeholder="Type your diagnosis or start writing a prescription (@med...)"
            className="flex-1 max-h-32 min-h-[44px] bg-transparent resize-none outline-none py-2.5 px-2 text-sm text-slate-700 font-medium custom-scrollbar"
            rows={1}
          />
          
          <div className="flex items-center gap-1 shrink-0 mb-1">
            <button className="p-2 text-slate-400 hover:text-brand-blue hover:bg-brand-blue/10 rounded-xl transition-colors">
              <Mic className="w-5 h-5" />
            </button>
            <button 
              className={cn(
                "p-2 rounded-xl transition-all shadow-sm",
                inputStr.trim().length > 0 
                  ? "bg-brand-blue text-white hover:bg-brand-blue/90" 
                  : "bg-slate-200 text-slate-400 cursor-not-allowed"
              )}
            >
              <Send className="w-5 h-5 ml-0.5" />
            </button>
          </div>

        </div>
        
        {/* Live AI Copilot Hint */}
        <div className="mt-2 px-2 flex justify-between items-center">
           <div className="flex items-center gap-2">
             <div className="w-1.5 h-1.5 rounded-full bg-brand-blue animate-pulse" />
             <span className="text-xs font-bold text-brand-blue">AI Copilot Active</span>
           </div>
           <span className="text-[10px] font-semibold text-slate-400 uppercase tracking-widest">Shift+Enter for newline</span>
        </div>
      </div>
    </div>
  );
};