import React, { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { SidebarLeftIcon } from '@hugeicons/core-free-icons';
import { HugeiconsIcon } from '@hugeicons/react';
import { motion, AnimatePresence } from 'framer-motion';
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
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);
  const [isOpen, setIsOpen] = useState<boolean>(true);
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      toast.success('Logged out successfully');
    } catch (error: any) {
      toast.error(error.message || 'Error logging out');
    }
  };

  const selectedIndex = navItems.findIndex(item => item.path === location.pathname);

  return (
    <motion.aside
      animate={{ width: isOpen ? 240 : 64 }}
      transition={{ type: 'spring', bounce: 0.4, duration: 0.8 }}
      className={`h-screen border-r border-slate-200 shadow-sm shrink-0 flex flex-col transition-colors duration-900 ease-out 
         ${isOpen ? 'bg-slate-50 dark:bg-neutral-800' : 'bg-white'}
      `}
    >
      <div className={`flex items-center w-full h-16 pt-4 mb-4 ${isOpen ? 'justify-between px-6' : 'justify-center'} text-slate-800 p-2 shrink-0 border-b border-transparent`}>
        <AnimatePresence>
          {isOpen ? (
            <motion.div initial={{ opacity: 0, scale: 0.8, width: 0 }} animate={{ opacity: 1, scale: 1, width: 'auto' }} exit={{ opacity: 0, scale: 0.8, width: 0, display: 'none' }} transition={{ duration: 0.2 }} className="flex items-center gap-3 overflow-hidden origin-left">
               <img src={logo} alt="MedAssist Logo" className="h-7 w-7 rounded-md shadow-sm shrink-0" />
               <span className="text-lg font-bold bg-gradient-to-r from-teal-600 to-indigo-600 bg-clip-text text-transparent tracking-tight whitespace-nowrap">MedAssist.</span>
            </motion.div>
          ) : (
            <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.8 }} transition={{ duration: 0.2 }} className="flex items-center justify-center cursor-pointer py-1 rounded-xl" onClick={() => setIsOpen(true)}>
              <img src={logo} alt="MedAssist Logo" className="h-6 w-6 rounded-md shadow-sm opacity-80" />
            </motion.div>
          )}
        </AnimatePresence>

        <motion.div layout className="shrink-0 flex items-center justify-center">
          {isOpen && (
             <HugeiconsIcon
               icon={SidebarLeftIcon}
               className="size-5 cursor-pointer text-slate-400 hover:text-slate-700 transition-colors"
               onClick={() => setIsOpen(false)}
             />
          )}
        </motion.div>
      </div>

      <div className="flex-1 w-full relative z-10 px-3">
        <ul className="space-y-2 mt-2" onMouseLeave={() => setHoveredIndex(null)}>
          {navItems.map((item, index) => {
            const Icon = item.icon;
            const isSelected = selectedIndex === index;
            return (
              <li key={item.name} className="relative cursor-pointer" onMouseEnter={() => setHoveredIndex(index)} onClick={() => navigate(item.path)}>
                <AnimatePresence>
                  {isSelected && (
                    <motion.div className="absolute inset-0 z-0 bg-white ring-1 ring-slate-200/50 shadow-[0_1px_3px_rgb(0_0_0_/_0.05)] rounded-lg" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.2, ease: 'easeOut' }} />
                  )}
                </AnimatePresence>
                <div className={`relative z-10 flex items-center px-3 py-2.5 rounded-lg overflow-hidden ${isSelected ? 'text-teal-700 font-medium' : 'text-slate-600 hover:text-slate-900'}`}>
                  <Icon className={`h-5 w-5 shrink-0 ${isSelected ? 'opacity-100' : 'opacity-80'}`} />
                  <AnimatePresence>
                    {isOpen && (
                      <motion.span initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10, display: 'none' }} transition={{ duration: 0.2 }} className="ml-3 whitespace-nowrap overflow-hidden text-sm">{item.name}</motion.span>
                    )}
                  </AnimatePresence>
                </div>
                <AnimatePresence>
                  {hoveredIndex === index && !isSelected && (
                    <motion.span layoutId="sidebar-hover-bg" className="absolute inset-0 z-0 bg-slate-200/50 rounded-lg pointer-events-none" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ type: 'spring', stiffness: 350, damping: 30 }} />
                  )}
                </AnimatePresence>
              </li>
            );
          })}
        </ul>
      </div>

      <AnimatePresence>
        {isOpen && (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20, display: 'none' }} className="px-4 py-4 mt-auto border-t border-slate-200 space-y-2 overflow-hidden whitespace-nowrap origin-bottom">
            <button onClick={handleLogout} className="w-full flex items-center justify-center gap-2 px-4 py-2.5 text-sm font-semibold rounded-lg bg-white text-slate-700 hover:bg-rose-50 hover:text-rose-600 transition-colors shadow-sm ring-1 ring-slate-200/60">
              <LogOut className="h-4 w-4" /> Log out
            </button>
          </motion.div>
        )}
      </AnimatePresence>
      {!isOpen && (
          <div className="py-4 mt-auto border-t border-slate-200 flex justify-center w-full px-2">
            <button onClick={handleLogout} title="Logout" className="flex items-center justify-center w-full h-10 rounded-lg bg-white text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors ring-1 ring-slate-200/60">
              <LogOut className="h-5 w-5" />
            </button>
          </div>
      )}
    </motion.aside>
  );
};
