import React, { useState } from 'react';
import { Settings2, Save, Key, Shield, Globe, Bell } from 'lucide-react';

export const Settings: React.FC = () => {
  const [activeTab, setActiveTab] = useState('General Setup');

  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row justify-between mb-8 gap-4">
         <div>
            <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight flex items-center gap-3">
               <span className="p-2 bg-slate-100 text-slate-600 rounded-[1.25rem]"><Settings2 className="h-6 w-6 stroke-[2.5]" /></span>
               System Configuration
            </h1>
            <p className="text-slate-500 font-medium text-sm mt-3 ml-[3.25rem]">Global settings, security rules, and commission rates</p>
         </div>
         <button className="bg-teal-600 hover:bg-teal-700 text-white font-bold px-5 py-2.5 rounded-xl shadow-sm text-sm transition-all focus:ring-4 focus:ring-teal-500/20 active:scale-95 flex items-center gap-2">
            <Save className="h-4 w-4" /> Save Changes
         </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Navigation Sidebar */}
        <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-200/60 lg:col-span-1 space-y-1 h-fit">
          <SectionItem icon={Globe} label="General Setup" active={activeTab === 'General Setup'} onClick={() => setActiveTab('General Setup')} />
          <SectionItem icon={Key} label="API Keys" active={activeTab === 'API Keys'} onClick={() => setActiveTab('API Keys')} />
          <SectionItem icon={Shield} label="Security & ROLES" active={activeTab === 'Security & ROLES'} onClick={() => setActiveTab('Security & ROLES')} />
          <SectionItem icon={Bell} label="Notifications" active={activeTab === 'Notifications'} onClick={() => setActiveTab('Notifications')} />
        </div>

        {/* Content Form */}
        <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-200/60 lg:col-span-3">
           {activeTab === 'General Setup' && (
             <div className="animate-in fade-in duration-300">
               <h2 className="text-xl font-bold tracking-tight text-slate-800 border-b border-slate-100 pb-4 mb-6">Financial & Business Rules</h2>
               
               <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
                  <div>
                     <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Default Platform Commission (%)</label>
                     <input type="number" defaultValue="15" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-700 font-semibold focus:ring-2 focus:ring-teal-500/20 outline-none focus:border-teal-500 transition" />
                     <p className="text-xs font-medium text-slate-400 mt-2">Percentage deducted from doctor consultations automatically.</p>
                  </div>
                  
                  <div>
                     <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Partner Lab Commission (%)</label>
                     <input type="number" defaultValue="10" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-700 font-semibold focus:ring-2 focus:ring-teal-500/20 outline-none focus:border-teal-500 transition" />
                  </div>
               </div>
             </div>
           )}

           {activeTab === 'API Keys' && (
             <div className="animate-in fade-in duration-300">
               <h2 className="text-xl font-bold tracking-tight text-slate-800 border-b border-slate-100 pb-4 mb-6">API & External Services</h2>

               <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-6">
                  <div>
                     <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Supabase URL</label>
                     <input type="text" defaultValue="https://xyz.supabase.co" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-700 font-mono text-sm focus:ring-2 focus:ring-teal-500/20 outline-none focus:border-teal-500 transition" />
                  </div>
                  
                  <div>
                     <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">OpenAI Key Config</label>
                     <input type="password" defaultValue="sk-xxxxxxx-xxxxxxxx-x" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-700 font-mono text-sm focus:ring-2 focus:ring-teal-500/20 outline-none focus:border-teal-500 transition" />
                     <p className="text-xs font-medium text-emerald-500 mt-2 flex items-center gap-1">Connected actively.</p>
                  </div>
               </div>
             </div>
           )}

           {activeTab === 'Security & ROLES' && (
             <div className="animate-in fade-in duration-300">
               <h2 className="text-xl font-bold tracking-tight text-slate-800 border-b border-slate-100 pb-4 mb-6">Security & ROLES</h2>
               <div className="text-slate-500 text-sm">
                 <p className="mb-4">Configure authentication providers and role-based access control here.</p>
                 <label className="flex items-center gap-2 cursor-pointer">
                   <input type="checkbox" className="rounded text-teal-600 focus:ring-teal-500 h-4 w-4" defaultChecked />
                   <span className="font-semibold text-slate-700">Require Two-Factor Authentication for Admins</span>
                 </label>
               </div>
             </div>
           )}

           {activeTab === 'Notifications' && (
             <div className="animate-in fade-in duration-300">
               <h2 className="text-xl font-bold tracking-tight text-slate-800 border-b border-slate-100 pb-4 mb-6">System Notifications</h2>
               <div className="text-slate-500 text-sm space-y-4">
                 <label className="flex items-center gap-2 cursor-pointer">
                   <input type="checkbox" className="rounded text-teal-600 focus:ring-teal-500 h-4 w-4" defaultChecked />
                   <span className="font-semibold text-slate-700">Email alerts for new doctors</span>
                 </label>
                 <label className="flex items-center gap-2 cursor-pointer">
                   <input type="checkbox" className="rounded text-teal-600 focus:ring-teal-500 h-4 w-4" defaultChecked />
                   <span className="font-semibold text-slate-700">Daily financial summary</span>
                 </label>
               </div>
             </div>
           )}
        </div>
      </div>
    </div>
  );
};

const SectionItem: React.FC<any> = ({icon: Icon, label, active, onClick}) => (
  <button 
    onClick={onClick}
    className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all ${
    active ? 'bg-teal-50 text-teal-700 shadow-sm ring-1 ring-teal-500/10' : 'text-slate-500 hover:text-slate-800 hover:bg-slate-50'
  }`}>
    <Icon className={`h-5 w-5 ${active ? 'text-teal-600' : 'text-slate-400'}`} /> {label}
  </button>
);
