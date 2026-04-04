import { useState, useEffect } from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Settings, User, Bell, Bot, PieChart, Menu, X, Clipboard, QrCode, Video, Moon, Trash2, LogOut, UserCog, Loader2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { getProfile } from '../services/doctorProfileService';

// Simple utility for Tailwind class merging
// eslint-disable-next-line react-refresh/only-export-components
export function cn(...inputs: (string | undefined | null | false)[]) {
  return twMerge(clsx(inputs));
}

const SIDEBAR_ITEMS = [
  { name: 'Dashboard',    path: '/dashboard',            icon: LayoutDashboard },
  { name: 'Analytics',    path: '/dashboard/analytics',  icon: PieChart        },
  { name: 'Patients',     path: '/dashboard/patients',   icon: Users           },
  { name: 'Profile',      path: '/dashboard/profile',    icon: User            },
  { name: 'AI Assistant', path: '/dashboard/ai',         icon: Bot             },
  { name: 'Profile Setup', path: '/dashboard/profile-setup', icon: UserCog     },
  { name: 'Case Workflow', path: '/dashboard/case',        icon: Clipboard       },
  { name: 'Live Bookings', path: '/dashboard/live-bookings', icon: Video          },
  { name: 'Scan QR',      path: '/dashboard/scan',        icon: QrCode          },
];

const BOTTOM_NAV = [
  { name: 'Home',     path: '/dashboard',           icon: LayoutDashboard },
  { name: 'Patients', path: '/dashboard/patients',  icon: Users           },
  { name: 'Bookings', path: '/dashboard/live-bookings', icon: Video        },
  { name: 'AI',       path: '/dashboard/ai',        icon: Bot             },
  { name: 'Profile',  path: '/dashboard/profile',   icon: User            },
];

const PAGE_TITLES: Record<string, string> = {
  '/dashboard':            'Dashboard',
  '/dashboard/analytics':  'Analytics',
  '/dashboard/patients':   'Patients',
  '/dashboard/profile':    'Profile',
  '/dashboard/ai':         'AI Assistant',
  '/dashboard/today':      'Today',
  '/dashboard/sos':        'Emergency',
  '/dashboard/prescription': 'Prescription',
  '/dashboard/case':         'Case Workflow',
  '/dashboard/profile-setup': 'Profile Setup',
  '/dashboard/live-bookings': 'Live Bookings',
  '/dashboard/scan':         'Universal Scanner',
};

const DashboardLayout = () => {
  const [isSidebarOpen, setSidebarOpen] = useState(false);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  
  const [isCheckingProfile, setIsCheckingProfile] = useState(true);
  const [isNewUser, setIsNewUser] = useState(false);
  
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    setIsDarkMode(document.documentElement.classList.contains('dark'));
  }, []);

  // Check profile completion to identify completely new users
  useEffect(() => {
    getProfile()
      .then((profile) => {
        const _isNew = profile.completion_percent === 0;
        setIsNewUser(_isNew);
        // Force completely new users to go through the setup wizard exactly once
        if (_isNew && location.pathname !== '/dashboard/profile-setup') {
          navigate('/dashboard/profile-setup', { replace: true });
        }
      })
      .catch(console.error)
      .finally(() => {
        setIsCheckingProfile(false);
      });
  }, [location.pathname, navigate]);

  const toggleDarkMode = () => {
    const isDark = document.documentElement.classList.toggle('dark');
    setIsDarkMode(isDark);
  };

  const handleClearCache = () => {
    localStorage.clear();
    sessionStorage.clear();
    alert("System cache wiped successfully. Restoring session.");
    window.location.reload();
  };
  
  const pageTitle = PAGE_TITLES[location.pathname] || location.pathname.split('/').pop() || 'Dashboard';

  if (isCheckingProfile) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center font-sans">
        <Loader2 className="w-8 h-8 animate-spin text-brand-blue" />
      </div>
    );
  }

  // If completely new, only show the setup wizard
  // If returning, show all standard links but hide the one-time setup wizard
  const navItems = isNewUser
    ? SIDEBAR_ITEMS.filter(item => item.path === '/dashboard/profile-setup')
    : SIDEBAR_ITEMS.filter(item => item.path !== '/dashboard/profile-setup');
    
  const bottomNavItems = isNewUser 
    ? BOTTOM_NAV.filter(item => item.path === '/dashboard/profile-setup') 
    : BOTTOM_NAV;

  return (
    <div className="min-h-screen bg-slate-50 flex overflow-hidden font-sans">

      {/* ── Mobile Backdrop ── */}
      <div
        className={cn(
          'fixed inset-0 bg-slate-900/60 z-40 md:hidden transition-opacity duration-300',
          isSidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        )}
        onClick={() => setSidebarOpen(false)}
      />

      {/* ── Sidebar ── */}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-50 w-[270px] bg-white border-r border-slate-200 flex flex-col transition-transform duration-300 ease-in-out',
          'md:translate-x-0 md:static md:z-auto',
          isSidebarOpen ? 'translate-x-0 shadow-2xl' : '-translate-x-full md:translate-x-0'
        )}
      >
        {/* Logo + Close (mobile) */}
        <div className="flex items-center justify-between h-16 md:h-32 md:flex-col px-4 md:px-0 md:items-center md:justify-center border-b border-slate-100 bg-white/50 shrink-0">
          <div className="flex items-center gap-3 md:flex-col md:gap-1">
            <img src="/logo.svg" alt="MedAssist" className="h-9 w-9 md:h-12 md:w-12 object-contain" />
            <span className="font-bold text-lg md:text-xl text-[#0A2540] tracking-tight">MedAssist</span>
          </div>
          <button
            onClick={() => setSidebarOpen(false)}
            className="md:hidden p-2 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-xl transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Nav Items */}
        <div className="flex-1 py-4 overflow-y-auto">
          <nav className="space-y-0.5 px-3">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.path;
              return (
                <Link
                  key={item.name}
                  to={item.path}
                  onClick={() => setSidebarOpen(false)}
                  className={cn(
                    'flex items-center px-3 py-3 rounded-xl transition-all duration-200 group text-[15px] font-medium',
                    isActive
                      ? 'bg-brand-blue text-white shadow-soft'
                      : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
                  )}
                >
                  <Icon className={cn('mr-3 h-5 w-5 shrink-0', isActive ? 'text-white' : 'text-slate-400 group-hover:text-brand-blue')} />
                  {item.name}
                  {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-white/80" />}
                </Link>
              );
            })}
          </nav>


        </div>

        {/* Doctor Identity */}
        <div className="p-4 border-t border-slate-100 shrink-0">
          <div className="flex items-center gap-3 px-2 py-2 hover:bg-slate-50 cursor-pointer rounded-xl transition-colors">
            <div className="w-10 h-10 rounded-full bg-slate-200 border-2 border-white shadow-sm overflow-hidden shrink-0">
              <img src="https://ui-avatars.com/api/?name=Dr.+Smith&background=1A6BFF&color=fff" className="w-full h-full object-cover" alt="Dr Smith" />
            </div>
            <div className="min-w-0">
              <p className="text-sm font-bold text-slate-800 truncate">Dr. Smith</p>
              <p className="text-xs text-slate-500 truncate">Cardiologist</p>
            </div>
          </div>
        </div>
      </aside>

      {/* ── Main Content ── */}
      <main className="flex-1 flex flex-col min-h-screen min-w-0 bg-[#F9FBFF] pb-[72px] md:pb-0 overflow-hidden">

        {/* Top Navbar */}
        {location.pathname !== '/dashboard/ai' && (
          <header className="h-14 md:h-16 bg-white/90 backdrop-blur-md border-b border-slate-200 flex items-center px-4 md:px-8 justify-between shrink-0 sticky top-0 z-30">
            <div className="flex items-center gap-3">
              {/* Hamburger (mobile) */}
              <button
                onClick={() => setSidebarOpen(true)}
                className="md:hidden p-2 -ml-1 text-slate-500 hover:bg-slate-100 rounded-xl transition-colors"
              >
                <Menu className="h-5 w-5" />
              </button>
              <h1 className="text-[16px] md:text-lg font-bold text-slate-800 capitalize">{pageTitle}</h1>
            </div>

            <div className="flex items-center gap-2 relative">
              <button 
                onClick={() => { setIsNotificationOpen(!isNotificationOpen); setIsSettingsOpen(false); }}
                className="relative p-2 text-slate-500 hover:bg-slate-100 rounded-xl transition-colors"
              >
                <Bell className="h-5 w-5" />
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 border border-white rounded-full" />
              </button>

              {/* Notification Dropdown */}
              <AnimatePresence>
                {isNotificationOpen && (
                  <>
                    <div className="fixed inset-0 z-40" onClick={() => setIsNotificationOpen(false)} />
                    <motion.div 
                      initial={{ opacity: 0, y: 10, scale: 0.95 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      exit={{ opacity: 0, y: 10, scale: 0.95 }}
                      transition={{ duration: 0.2 }}
                      className="absolute top-full right-12 mt-2 w-80 bg-white border border-slate-200 shadow-xl rounded-2xl z-50 overflow-hidden"
                    >
                      <div className="p-4 border-b border-slate-100 flex items-center justify-between bg-slate-50">
                        <h3 className="font-bold text-slate-800">Notifications</h3>
                        <span className="text-xs font-semibold text-brand-blue bg-blue-100 px-2 py-1 rounded-full">3 New</span>
                      </div>
                      <div className="max-h-80 overflow-y-auto">
                        <div className="p-4 border-b border-slate-50 hover:bg-slate-50 cursor-pointer transition-colors">
                           <p className="text-sm font-semibold text-slate-800">Dr. Sarah requested a consult</p>
                           <p className="text-xs text-slate-500 mt-1">Regarding patient #8472 in Cardiology.</p>
                           <p className="text-[10px] text-slate-400 mt-2 font-medium">10 mins ago</p>
                        </div>
                        <div className="p-4 border-b border-slate-50 hover:bg-slate-50 cursor-pointer transition-colors">
                           <p className="text-sm font-semibold text-slate-800">System Update Complete</p>
                           <p className="text-xs text-slate-500 mt-1">Kimi-k2.5 multimodal features are now active.</p>
                           <p className="text-[10px] text-slate-400 mt-2 font-medium">1 hour ago</p>
                        </div>
                        <div className="p-4 border-b border-slate-50 hover:bg-slate-50 cursor-pointer transition-colors opacity-60">
                           <p className="text-sm font-semibold text-slate-800">Lab Results Ready</p>
                           <p className="text-xs text-slate-500 mt-1">Metabolic panel for John Doe is ready for review.</p>
                           <p className="text-[10px] text-slate-400 mt-2 font-medium">Yesterday</p>
                        </div>
                      </div>
                      <div className="p-3 bg-slate-50 border-t border-slate-100">
                         <button className="w-full text-center text-sm font-bold text-slate-600 hover:text-brand-blue">View All</button>
                      </div>
                    </motion.div>
                  </>
                )}
              </AnimatePresence>

              <button 
                onClick={() => { setIsSettingsOpen(!isSettingsOpen); setIsNotificationOpen(false); }}
                className="relative p-2 text-slate-500 hover:bg-slate-100 rounded-xl transition-colors hidden sm:flex"
              >
                <Settings className="h-5 w-5" />
              </button>

              {/* Settings Dropdown */}
              <AnimatePresence>
                {isSettingsOpen && (
                  <>
                    <div className="fixed inset-0 z-40" onClick={() => setIsSettingsOpen(false)} />
                    <motion.div 
                      initial={{ opacity: 0, y: 10, scale: 0.95 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      exit={{ opacity: 0, y: 10, scale: 0.95 }}
                      transition={{ duration: 0.2 }}
                      className="absolute top-full right-0 mt-2 w-64 bg-white border border-slate-200 shadow-xl rounded-2xl z-50 overflow-hidden"
                    >
                      <div className="p-4 border-b border-slate-100 bg-slate-50 flex flex-col gap-1">
                        <h3 className="font-bold text-slate-800 text-sm">Quick Settings</h3>
                        <p className="text-xs text-slate-500">Manage your portal preferences</p>
                      </div>
                      <div className="p-2 space-y-1">
                        <button onClick={toggleDarkMode} className="w-full flex items-center justify-between p-3 rounded-xl hover:bg-slate-50 transition-colors text-left group">
                          <div className="flex items-center gap-3 text-sm font-medium text-slate-700">
                            <Moon className="w-4 h-4 text-slate-400 group-hover:text-indigo-500" />
                            Night Mode
                          </div>
                          <div className={`w-8 h-4 rounded-full relative transition-colors ${isDarkMode ? 'bg-indigo-500' : 'bg-slate-200'}`}>
                            <div className={`w-4 h-4 bg-white rounded-full shadow border border-slate-300 absolute top-0 transition-transform ${isDarkMode ? 'translate-x-4 border-indigo-500' : 'left-0'}`} />
                          </div>
                        </button>
                        <button onClick={handleClearCache} className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-slate-50 transition-colors text-left text-sm font-medium text-slate-700 group">
                          <Trash2 className="w-4 h-4 text-slate-400 group-hover:text-red-500" />
                          Clear Cache
                        </button>
                        <Link to="/dashboard/profile" onClick={() => setIsSettingsOpen(false)} className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-slate-50 transition-colors text-left text-sm font-medium text-slate-700 group">
                          <User className="w-4 h-4 text-slate-400 group-hover:text-brand-blue" />
                          Account Settings
                        </Link>
                        <div className="h-px bg-slate-100 my-1"></div>
                        <Link to="/login" className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-red-50 transition-colors text-left text-sm font-medium text-red-600 group">
                          <LogOut className="w-4 h-4 text-red-400 group-hover:text-red-600" />
                          Logout
                        </Link>
                      </div>
                    </motion.div>
                  </>
                )}
              </AnimatePresence>

              {/* Mobile avatar */}
              <div className="md:hidden w-8 h-8 rounded-full overflow-hidden border-2 border-slate-200 shrink-0 cursor-pointer hover:opacity-80 transition-opacity">
                <img src="https://ui-avatars.com/api/?name=Dr.+Smith&background=1A6BFF&color=fff" className="w-full h-full object-cover" alt="Dr Smith" />
              </div>
            </div>
          </header>
        )}

        {/* Page Content */}
        <div className={cn(
          'flex-1 overflow-auto custom-scrollbar flex flex-col',
          location.pathname !== '/dashboard/ai' ? 'p-3 md:p-8' : 'p-0'
        )}>
          <Outlet />
        </div>

        {/* ── Mobile Bottom Nav ── */}
        {!isNewUser && (
          <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 border-t border-slate-200 z-50 flex justify-around items-center px-1 pt-2 pb-3 backdrop-blur-md shadow-[0_-2px_16px_-2px_rgba(0,0,0,0.08)]">
            {bottomNavItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.path;
              return (
                <Link
                  key={item.name}
                  to={item.path}
                  className={cn(
                    'flex flex-col items-center justify-center gap-0.5 flex-1 py-1 rounded-xl transition-all',
                    isActive ? 'text-brand-blue' : 'text-slate-400'
                  )}
                >
                  <div className={cn('p-1.5 rounded-xl transition-all', isActive && 'bg-blue-50')}>
                    <Icon className={cn('h-[22px] w-[22px]', isActive ? 'stroke-[2.5px]' : 'stroke-[1.8px]')} />
                  </div>
                  <span className={cn('text-[10px] leading-none', isActive ? 'font-bold' : 'font-medium')}>{item.name}</span>
                </Link>
              );
            })}
          </div>
        )}

      </main>
    </div>
  );
};

export default DashboardLayout;