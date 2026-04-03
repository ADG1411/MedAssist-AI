import { useState } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Users, Settings, User, Bell, Bot, PieChart, Menu, X, Clipboard, QrCode, GitBranch } from 'lucide-react';

import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

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
  { name: 'Case Workflow', path: '/dashboard/case',        icon: Clipboard       },
  { name: 'MedCard Scan',  path: '/dashboard/medcard',     icon: QrCode          },
  { name: 'Referral QR',  path: '/dashboard/referral',    icon: GitBranch       },
];

const BOTTOM_NAV = [
  { name: 'Home',     path: '/dashboard',           icon: LayoutDashboard },
  { name: 'Patients', path: '/dashboard/patients',  icon: Users           },
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
  '/dashboard/medcard':      'MedCard Scanner',
  '/dashboard/referral':     'Referral System',
};

const DashboardLayout = () => {
  const [isSidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const pageTitle = PAGE_TITLES[location.pathname] || location.pathname.split('/').pop() || 'Dashboard';

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
            {SIDEBAR_ITEMS.map((item) => {
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

          <div className="px-5 mt-8">
            <h3 className="text-xs uppercase text-slate-400 font-bold tracking-wider mb-3 px-1">Quick Actions</h3>
            <button className="w-full flex items-center justify-center gap-2 bg-slate-900 text-white px-4 py-2.5 rounded-xl hover:bg-slate-800 transition-colors text-sm font-semibold">
              + New Patient
            </button>
          </div>
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

            <div className="flex items-center gap-2">
              <button className="relative p-2 text-slate-500 hover:bg-slate-100 rounded-xl transition-colors">
                <Bell className="h-5 w-5" />
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 border border-white rounded-full" />
              </button>
              <button className="p-2 text-slate-500 hover:bg-slate-100 rounded-xl transition-colors hidden sm:flex">
                <Settings className="h-5 w-5" />
              </button>
              {/* Mobile avatar */}
              <div className="md:hidden w-8 h-8 rounded-full overflow-hidden border-2 border-slate-200 shrink-0">
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
        <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 border-t border-slate-200 z-50 flex justify-around items-center px-1 pt-2 pb-3 backdrop-blur-md shadow-[0_-2px_16px_-2px_rgba(0,0,0,0.08)]">
          {BOTTOM_NAV.map((item) => {
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

      </main>
    </div>
  );
};

export default DashboardLayout;