import { PatientInfoPanel } from '../components/PatientInfoPanel';
import { ChatBox } from '../components/ChatBox';
import { AIInsightPanel } from '../components/AIInsightPanel';
import { ChevronLeft, Focus } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const TicketCaseView = () => {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-[calc(100vh-80px)] md:h-screen w-full bg-slate-100 animate-in fade-in duration-500">
      
      {/* Top Header Bar */}
      <div className="h-16 shrink-0 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-6 shadow-sm z-20">
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate(-1)}
            className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-500 transition-colors"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <div className="flex flex-col">
            <h1 className="text-lg font-bold text-slate-800 leading-tight">Case #4902-1X</h1>
            <p className="text-xs text-slate-500 font-medium">Started 10 mins ago • High Priority</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Focus Mode Button */}
          <button className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 font-semibold text-sm transition-colors">
            <Focus className="w-4 h-4" /> Focus Mode
          </button>
          
          <button className="px-4 py-1.5 bg-slate-900 text-white rounded-lg font-bold text-sm hover:bg-slate-800 transition-colors shadow-soft">
            Save Draft
          </button>
        </div>
      </div>

      {/* 3-Column Workspace Layout */}
      <div className="flex-1 flex flex-col md:flex-row min-h-0 overflow-hidden">
        
        {/* LEFT COLUMN: Patient Context */}
        <div className="hidden md:flex flex-col h-full z-10 transition-all duration-300">
          <PatientInfoPanel />
        </div>

        {/* CENTER COLUMN: Chat & Consult */}
        <div className="flex-1 flex flex-col min-w-0 h-full shadow-[0_0_40px_-15px_rgba(0,0,0,0.1)] z-20">
          <ChatBox />
        </div>

        {/* RIGHT COLUMN: AI Intelligence */}
        <div className="hidden lg:flex flex-col h-full z-10 transition-all duration-300">
          <AIInsightPanel />
        </div>

      </div>
    
    </div>
  );
};

export default TicketCaseView;