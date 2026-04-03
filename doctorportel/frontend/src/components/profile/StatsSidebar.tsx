import { Users, CalendarCheck, TrendingUp, DollarSign } from 'lucide-react';
import type { DoctorProfile } from '../../services/profileService';

interface StatsSidebarProps {
  stats: DoctorProfile['stats'];
}

export const StatsSidebar = ({ stats }: StatsSidebarProps) => {
  return (
    <div className="space-y-4">
      <h3 className="font-bold text-slate-800 text-lg mb-2">Performance</h3>
      
      <div className="grid grid-cols-2 gap-4">
        
        <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200">
          <div className="w-8 h-8 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center mb-3">
            <Users className="w-4 h-4" />
          </div>
          <p className="text-2xl font-black text-slate-800">{stats?.total_patients || '0'}</p>
          <p className="text-xs text-slate-500 font-medium">Total Patients</p>
        </div>

        <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200">
          <div className="w-8 h-8 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mb-3">
            <CalendarCheck className="w-4 h-4" />
          </div>
          <p className="text-2xl font-black text-slate-800">{stats?.consultations || '0'}</p>
          <p className="text-xs text-slate-500 font-medium">Appointments</p>
        </div>

        <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200">
          <div className="w-8 h-8 rounded-full bg-purple-50 text-purple-600 flex items-center justify-center mb-3">
            <TrendingUp className="w-4 h-4" />
          </div>
          <p className="text-2xl font-black text-slate-800">{stats?.success_rate || '0%'}</p>
          <p className="text-xs text-slate-500 font-medium">Success Rate</p>
        </div>

        <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200">
          <div className="w-8 h-8 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center mb-3">
            <DollarSign className="w-4 h-4" />
          </div>
          <p className="text-2xl font-black text-slate-800">{stats?.earnings_this_month || '$0'}</p>
          <p className="text-xs text-slate-500 font-medium">This Month</p>
        </div>

      </div>
    </div>
  );
};