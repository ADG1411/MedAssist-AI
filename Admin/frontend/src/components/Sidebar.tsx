import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, Users, FileText, Share2, 
  CircleDollarSign, Cpu, BarChart3, Siren, Settings, LogOut
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';
import logo from '../assets/logo.svg';

const navItems = [
  { name: 'Dashboard', path: '/', icon: LayoutDashboard },
  { name: 'Users', path: '/users', icon: Users },
  { name: 'Cases', path: '/cases', icon: FileText },
  { name: 'Referrals', path: '/referrals', icon: Share2 },
  { name: 'Earnings', path: '/earnings', icon: CircleDollarSign },
  { name: 'AI Control', path: '/ai-control', icon: Cpu },
  { name: 'Analytics', path: '/analytics', icon: BarChart3 },
  { name: 'Emergency', path: '/emergency', icon: Siren, isAlert: true },
  { name: 'Settings', path: '/settings', icon: Settings },
];

export const Sidebar: React.FC = () => {
  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      toast.success('Logged out successfully');
    } catch (error: any) {
      toast.error(error.message || 'Error logging out');
    }
  };

  return (
    <aside className="w-64 bg-white border-r border-slate-200 min-h-screen flex flex-col pt-6 pb-4 shrink-0 transition-all">
      <div className="px-6 pb-6 border-b border-slate-100 flex items-center gap-3">
        <img src={logo} alt="MedAssist Logo" className="h-8 w-8 rounded-lg shadow-sm" />
        <span className="text-xl font-bold bg-gradient-to-r from-teal-600 to-indigo-600 bg-clip-text text-transparent tracking-tight">MedAssist.</span>
      </div>
      
      <nav className="flex-1 mt-6 px-4 overflow-y-auto hidden-scrollbar">
        <ul className="space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <li key={item.name}>
                <NavLink
                  to={item.path}
                  className={({ isActive }) =>
                    `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
                      isActive 
                        ? 'bg-teal-50 text-teal-700 shadow-sm ring-1 ring-teal-600/10' 
                        : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900 group'
                    }`
                  }
                >
                  <Icon className="h-5 w-5 opacity-80" />
                  <span className="flex-1">{item.name}</span>
                  {item.isAlert && (
                    <span className="h-2 w-2 rounded-full bg-rose-500 shadow-[0_0_8px_rgba(244,63,94,0.8)] animate-pulse"></span>
                  )}
                </NavLink>
              </li>
            );
          })}
        </ul>
      </nav>
      
      <div className="px-4 pt-4 border-t border-slate-100 space-y-2">
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-semibold rounded-lg bg-slate-50 text-slate-700 hover:bg-rose-50 hover:text-rose-600 transition-colors border border-slate-200 hover:border-rose-200"
        >
          <LogOut className="h-4 w-4" />
          Log out
        </button>
        <div className="text-xs text-slate-400 font-medium tracking-wider text-center pt-2">
          Admin Portal v2.1
        </div>
      </div>
    </aside>
  );
};
