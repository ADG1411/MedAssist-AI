import React, { useState } from 'react';
import { 
  Bot, BrainCircuit, Settings2, SlidersHorizontal, Activity, AlertTriangle, ShieldCheck, TerminalSquare
} from 'lucide-react';

const mockLogs = [
  { id: 1, time: '10:04:12 AM', level: 'INFO', event: 'Diagnostics prompt triggered for CASE-1109' },
  { id: 2, time: '09:42:01 AM', level: 'WARN', event: 'High token usage detected in referral summary generation' },
  { id: 3, time: '08:15:33 AM', level: 'ERROR', event: 'Failed to access external radiology knowledge base API' },
  { id: 4, time: '07:22:50 AM', level: 'INFO', event: 'System prompt cache flushed and re-warmed' },
];

export const AIControl: React.FC = () => {
  const [model, setModel] = useState('gpt-4-turbo');
  const [temperature, setTemperature] = useState(0.4);
  const [activeTab, setActiveTab] = useState('Prompts');

  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight">AI Control Center</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Manage core models, system prompts, and monitor AI behavior</p>
        </div>
        <div className="flex items-center gap-3">
          <span className="bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full text-xs font-extrabold uppercase tracking-widest flex items-center gap-2 ring-1 ring-emerald-500/30">
            <span className="h-2 w-2 rounded-full bg-emerald-500 relative">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            </span>
            System Stable
          </span>
          <button className="bg-slate-800 hover:bg-slate-900 text-white font-semibold px-5 py-2.5 rounded-xl shadow-md shadow-slate-900/20 text-sm transition-all focus:ring-4 focus:ring-slate-500/20 active:scale-95 flex items-center gap-2">
            <BrainCircuit className="h-4 w-4 text-emerald-400" /> Apply Config
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column - Core Config */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200/60 transition-shadow hover:shadow-md">
            <h2 className="text-lg font-bold tracking-tight text-slate-800 flex items-center gap-2.5 mb-6">
              <SlidersHorizontal className="h-5 w-5 text-teal-600" /> Core Engine Settings
            </h2>
            
            <div className="space-y-5">
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Active Model</label>
                <select 
                  value={model} 
                  onChange={(e) => setModel(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 focus:ring-2 focus:ring-teal-500/20 outline-none transition focus:border-teal-500"
                >
                  <optgroup label="Patient Side Models">
                    <option value="gpt-4-turbo">GPT-4 Turbo (Patient Primary)</option>
                    <option value="gpt-3.5-turbo">GPT-3.5 Turbo (Patient Fallback)</option>
                    <option value="claude-3-opus">Claude 3 Opus (Patient Specialist)</option>
                  </optgroup>
                  <optgroup label="Doctor Side Models">
                    <option value="kimi-k-2.5">Kimi K 2.5 (Doctor Working Model)</option>
                    <option value="step-3-fast">Step 3 Fast (Doctor Working Model)</option>
                  </optgroup>
                </select>
              </div>
              
              <div>
                <div className="flex justify-between items-center mb-2">
                  <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest">Temperature</label>
                  <span className="text-xs font-bold text-teal-600 bg-teal-50 px-2 py-0.5 rounded-md">{temperature}</span>
                </div>
                <input 
                  type="range" 
                  min="0" max="1" step="0.1" 
                  value={temperature} 
                  onChange={(e) => setTemperature(parseFloat(e.target.value))}
                  className="w-full h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-teal-600 focus:outline-none focus:ring-2 focus:ring-teal-500/30"
                />
                <div className="flex justify-between text-xs text-slate-400 mt-1 font-medium px-1">
                  <span>Precise</span>
                  <span>Creative</span>
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Safety Rails</label>
                <div className="flex items-center justify-between p-3 rounded-xl border border-slate-200 bg-slate-50">
                  <div className="flex items-center gap-2 text-sm font-semibold text-slate-700">
                    <ShieldCheck className="h-4 w-4 text-emerald-500" /> Strict Medical Output
                  </div>
                  <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in flex-shrink-0">
                      <input type="checkbox" name="toggle" id="toggle1" checked readOnly className="toggle-checkbox absolute block w-5 h-5 rounded-full bg-white border-4 appearance-none cursor-pointer border-emerald-500 translate-x-5 transition-transform" style={{top: -2}}/>
                      <label htmlFor="toggle1" className="toggle-label block overflow-hidden h-4 rounded-full bg-emerald-200 cursor-pointer"></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div className="bg-slate-900 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-slate-800 via-slate-900 to-black p-6 rounded-2xl shadow-lg border border-slate-700/50 text-white overflow-hidden relative">
            <Bot className="absolute -bottom-6 -right-6 h-32 w-32 text-slate-800 opacity-50" />
            <h2 className="text-lg font-bold tracking-tight flex items-center gap-2.5 mb-6 relative z-10 text-emerald-400">
              <TerminalSquare className="h-5 w-5" /> Live Monitor
            </h2>
            <div className="space-y-4 relative z-10">
              <div className="flex justify-between items-center bg-slate-800/50 p-3 rounded-xl backdrop-blur-sm border border-slate-700/50 ring-1 ring-inset ring-white/5">
                <span className="text-slate-400 text-sm font-medium flex items-center gap-2"><Activity className="h-4 w-4" /> Avg Latency</span>
                <span className="text-emerald-400 font-extrabold text-sm font-mono ring-1 ring-emerald-500/30 bg-emerald-500/10 px-2 py-0.5 rounded-md">842ms</span>
              </div>
              <div className="flex justify-between items-center bg-slate-800/50 p-3 rounded-xl backdrop-blur-sm border border-slate-700/50 ring-1 ring-inset ring-white/5">
                <span className="text-slate-400 text-sm font-medium">99th Percentile</span>
                <span className="text-amber-400 font-extrabold text-sm font-mono ring-1 ring-amber-500/30 bg-amber-500/10 px-2 py-0.5 rounded-md">1.94s</span>
              </div>
              <div className="flex justify-between items-center bg-slate-800/50 p-3 rounded-xl backdrop-blur-sm border border-slate-700/50 ring-1 ring-inset ring-white/5">
                <span className="text-slate-400 text-sm font-medium">Tokens / Min</span>
                <span className="text-blue-400 font-extrabold text-sm font-mono ring-1 ring-blue-500/30 bg-blue-500/10 px-2 py-0.5 rounded-md">45,210</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column - Prompts & Logs */}
        <div className="lg:col-span-2 flex flex-col h-full bg-white rounded-2xl shadow-sm border border-slate-200/60 overflow-hidden">
          <div className="flex bg-slate-50/80 border-b border-slate-100 p-2 gap-2">
            {['Prompts', 'Diagnostics', 'Logs'].map(tab => (
              <button 
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`py-2.5 px-6 rounded-xl text-sm font-bold transition-all flex items-center gap-2 ${
                  activeTab === tab 
                    ? 'bg-white text-slate-800 shadow-sm ring-1 ring-slate-200/50' 
                    : 'text-slate-500 hover:text-slate-700 hover:bg-slate-200/50'
                }`}
              >
                {tab === 'Prompts' && <Settings2 className="h-4 w-4" />}
                {tab === 'Logs' && <AlertTriangle className="h-4 w-4" />}
                {tab}
              </button>
            ))}
          </div>

          <div className="p-6 flex-1 bg-white">
            {activeTab === 'Prompts' && (
              <div className="h-full flex flex-col">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-base font-bold text-slate-800">Master Diagnostic System Prompt</h3>
                  <span className="text-xs font-bold text-slate-500 bg-slate-100 px-2.5 py-1 rounded-md tracking-wider uppercase">v2.4.1 Active</span>
                </div>
                <textarea 
                  className="w-full flex-1 min-h-[300px] p-5 bg-slate-50 border border-slate-200 rounded-xl text-slate-700 text-sm font-mono focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none leading-relaxed shadow-inner"
                  defaultValue={`You are MedAssist AI, an expert medical diagnostic assistant.
Your primary role is to assist credentialed doctors by providing differential diagnoses and suggesting relevant investigations based on patient symptoms.

CRITICAL RULES:
1. Always emphasize that your output is for informational purposes.
2. Never override a human doctor's judgment.
3. Structure responses with clearly labeled Markdown sections.
4. Output risk assessments strictly as: LOW, MODERATE, HIGH, or CRITICAL.

Context provided will include patient age, gender, vital signs, and recent history. 
Always remain objective, clinical, and precise.`}
                />
              </div>
            )}
            
            {activeTab === 'Logs' && (
              <div className="h-full">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-base font-bold text-slate-800">Recent AI Events</h3>
                  <button className="text-xs font-bold text-slate-500 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-md transition uppercase tracking-wider">Flush Logs</button>
                </div>
                <div className="space-y-3">
                  {mockLogs.map(log => (
                    <div key={log.id} className="flex gap-4 p-4 bg-slate-50 border border-slate-100 rounded-xl hover:shadow-sm transition">
                       <span className="text-xs font-mono text-slate-400 mt-0.5 w-[75px] shrink-0">{log.time}</span>
                       <span className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold tracking-widest h-fit shrink-0 mt-0.5 ${
                         log.level === 'ERROR' ? 'bg-rose-100 text-rose-700 ring-1 ring-rose-500/20' : 
                         log.level === 'WARN' ? 'bg-amber-100 text-amber-700 ring-1 ring-amber-500/20' : 
                         'bg-emerald-100 text-emerald-700 ring-1 ring-emerald-500/20'
                       }`}>
                         {log.level}
                       </span>
                       <span className="text-sm font-medium text-slate-700">{log.event}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
