import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { Sidebar } from './components/Sidebar';
import { Topbar } from './components/Topbar';
import { Dashboard } from './pages/Dashboard';
import { Users } from './pages/Users';
import { AIControl } from './pages/AIControl';
import { Cases } from './pages/Cases';
import { Referrals } from './pages/Referrals';
import { Earnings } from './pages/Earnings';
import { Analytics } from './pages/Analytics';
import { Emergency } from './pages/Emergency';
import { Settings } from './pages/Settings';
import { Login } from './pages/Login';
import { Signup } from './pages/Signup';
import { AuthProvider } from './contexts/AuthContext';
import { TooltipProvider } from '@/components/ui/tooltip';

const DashboardLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="flex h-screen overflow-hidden bg-[#f9fafb]">
    <Sidebar />
    <div className="relative flex flex-col flex-1 overflow-y-auto overflow-x-hidden scroll-smooth">
      <Topbar />
      <main className="flex-1 w-full mx-auto pb-12 pt-4">
        {children}
      </main>
    </div>
  </div>
);

function App() {
  return (
    <AuthProvider>
      <TooltipProvider>
        <BrowserRouter>
          <Toaster position="top-right" toastOptions={{ className: 'font-sans font-bold text-sm rounded-xl', duration: 3000 }} />
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Signup />} />

            <Route path="/" element={<DashboardLayout><Dashboard /></DashboardLayout>} />
            <Route path="/users" element={<DashboardLayout><Users /></DashboardLayout>} />
            <Route path="/cases" element={<DashboardLayout><Cases /></DashboardLayout>} />
            <Route path="/referrals" element={<DashboardLayout><Referrals /></DashboardLayout>} />
            <Route path="/earnings" element={<DashboardLayout><Earnings /></DashboardLayout>} />
            <Route path="/ai-control" element={<DashboardLayout><AIControl /></DashboardLayout>} />
            <Route path="/analytics" element={<DashboardLayout><Analytics /></DashboardLayout>} />
            <Route path="/emergency" element={<DashboardLayout><Emergency /></DashboardLayout>} />
            <Route path="/settings" element={<DashboardLayout><Settings /></DashboardLayout>} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  );
}

export default App;

