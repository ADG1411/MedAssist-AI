import React from 'react';
import { Bell, Search, UserCircle } from 'lucide-react';

export const Topbar: React.FC = () => {
  return (
    <header className="bg-white/80 backdrop-blur-md shadow-sm ring-1 ring-slate-200 h-16 w-full flex items-center justify-between px-8 z-10 sticky top-0 transition-all">
      <div className="flex-1 max-w-xl relative group">
        <label htmlFor="search" className="sr-only">Search</label>
        <input
          id="search"
          type="search"
          placeholder="Search patients, doctors, AI logs or cases... (Press '/')"
          className="w-full bg-slate-50/50 hover:bg-slate-100 text-sm border border-slate-200 rounded-xl py-2 pl-10 pr-4 outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all shadow-inner text-slate-800 placeholder-slate-400"
        />
        <Search className="h-4 w-4 text-slate-400 absolute left-3.5 top-1/2 transform -translate-y-1/2 group-focus-within:text-teal-500 transition-colors" />
      </div>

      <div className="flex items-center gap-6 ml-4">
        <button className="relative text-slate-400 hover:text-slate-600 transition-colors p-1.5 hover:bg-slate-100 rounded-full">
          <span className="sr-only">View notifications</span>
          <Bell className="h-5 w-5" />
          <span className="absolute top-1 right-1 h-2 w-2 rounded-full border-2 border-white bg-rose-500"></span>
        </button>

        <div className="flex items-center gap-3 border-l border-slate-200 pl-6 cursor-pointer group">
          <div className="text-right hidden sm:block">
            <p className="text-sm font-semibold text-slate-800 leading-none group-hover:text-teal-600 transition-colors">Admin Super</p>
            <p className="text-[11px] text-teal-600 font-medium mt-1 tracking-wide uppercase">System Owner</p>
          </div>
          <div className="h-10 w-10 rounded-full bg-gradient-to-br from-teal-500 to-emerald-400 shadow-md flex items-center justify-center text-white ring-2 ring-white group-hover:scale-105 transition-transform">
            <UserCircle className="h-6 w-6 opacity-90" />
          </div>
        </div>
      </div>
    </header>
  );
};
