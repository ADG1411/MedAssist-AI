import { Bell, Lock } from 'lucide-react';

export const SettingsTab = () => {
  return (
    <div className="space-y-6">
      
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <div className="flex items-center gap-3 mb-6">
          <Bell className="w-5 h-5 text-slate-400" />
          <h3 className="font-bold text-lg text-slate-800">Notifications</h3>
        </div>
        
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-slate-800 text-sm">New Appointment Alerts</p>
              <p className="text-xs text-slate-500">Get notified when a patient books.</p>
            </div>
            <input type="checkbox" className="w-4 h-4 text-brand-blue rounded border-slate-300" defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-slate-800 text-sm">Patient Messages</p>
              <p className="text-xs text-slate-500">Alerts for new chat messages.</p>
            </div>
            <input type="checkbox" className="w-4 h-4 text-brand-blue rounded border-slate-300" defaultChecked />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <div className="flex items-center gap-3 mb-6">
          <Lock className="w-5 h-5 text-slate-400" />
          <h3 className="font-bold text-lg text-slate-800">Privacy</h3>
        </div>
        
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-slate-800 text-sm">Show Profile in public search</p>
              <p className="text-xs text-slate-500">Allow patients to find you easily.</p>
            </div>
            <input type="checkbox" className="w-4 h-4 text-brand-blue rounded border-slate-300" defaultChecked />
          </div>
        </div>
      </div>

    </div>
  );
};