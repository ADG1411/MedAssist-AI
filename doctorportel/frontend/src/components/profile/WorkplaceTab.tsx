import { useState, useEffect } from "react";
import { Building2, Plus, MapPin, BadgeCheck, MoreVertical, X, Check } from "lucide-react";
import { profileService, type Workplace } from "../../services/profileService";

export const WorkplaceTab = () => {
  const [workplaces, setWorkplaces] = useState<Workplace[]>([]);
  const [isAdding, setIsAdding] = useState(false);
  const [loading, setLoading] = useState(false);
  const [newWorkplace, setNewWorkplace] = useState({
    name: "",
    type: "Hospital",
    role: "",
    location: "",
    is_primary: false,
    verified: false
  });

  useEffect(() => {
    fetchWorkplaces();
  }, []);

  const fetchWorkplaces = async () => {
    const data = await profileService.getWorkplaces();
    setWorkplaces(data);
  };

  const handleAdd = async () => {
    if (!newWorkplace.name || !newWorkplace.role) return;
    setLoading(true);
    const { data } = await profileService.addWorkplace(newWorkplace);
    if (data) {
      setWorkplaces(data as Workplace[]);
      setIsAdding(false);
      setNewWorkplace({ name: "", type: "Hospital", role: "", location: "", is_primary: false, verified: false });
    }
    setLoading(false);
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-xl font-bold text-slate-800">Linked Workplaces</h2>
          <p className="text-sm text-slate-500 mt-1">Manage hospitals and clinics where you practice.</p>
        </div>
        {!isAdding && (
          <button 
            onClick={() => setIsAdding(true)}
            className="bg-brand-blue text-white hover:bg-blue-700 px-4 py-2 rounded-xl text-sm font-bold flex items-center gap-2 shadow-sm transition-colors"
          >
            <Plus className="w-4 h-4" /> Add New
          </button>
        )}
      </div>

      {isAdding && (
        <div className="bg-slate-50 rounded-2xl p-6 border border-slate-200 shadow-sm animate-in slide-in-from-top-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="font-bold text-slate-800">Add New Workplace</h3>
            <button onClick={() => setIsAdding(false)} className="text-slate-400 hover:text-red-500">
              <X className="w-5 h-5" />
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input 
              type="text" 
              placeholder="Workplace Name (e.g. City Hospital)" 
              value={newWorkplace.name}
              onChange={(e) => setNewWorkplace({...newWorkplace, name: e.target.value})}
              className="px-4 py-2.5 rounded-xl border border-slate-200 outline-none focus:border-brand-blue focus:ring-1 focus:ring-brand-blue"
            />
            <input 
              type="text" 
              placeholder="Role (e.g. Senior Surgeon)" 
              value={newWorkplace.role}
              onChange={(e) => setNewWorkplace({...newWorkplace, role: e.target.value})}
              className="px-4 py-2.5 rounded-xl border border-slate-200 outline-none focus:border-brand-blue focus:ring-1 focus:ring-brand-blue"
            />
            <input 
              type="text" 
              placeholder="Location (e.g. New York, NY)" 
              value={newWorkplace.location}
              onChange={(e) => setNewWorkplace({...newWorkplace, location: e.target.value})}
              className="px-4 py-2.5 rounded-xl border border-slate-200 outline-none focus:border-brand-blue focus:ring-1 focus:ring-brand-blue"
            />
            <select 
              value={newWorkplace.type}
              onChange={(e) => setNewWorkplace({...newWorkplace, type: e.target.value})}
              className="px-4 py-2.5 rounded-xl border border-slate-200 outline-none focus:border-brand-blue focus:ring-1 focus:ring-brand-blue bg-white"
            >
              <option value="Hospital">Hospital</option>
              <option value="Private Clinic">Private Clinic</option>
              <option value="Research Center">Research Center</option>
            </select>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button 
              onClick={() => setIsAdding(false)}
              className="px-4 py-2 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
            >
              Cancel
            </button>
            <button 
              onClick={handleAdd}
              disabled={loading}
              className="px-6 py-2 bg-brand-blue text-white font-bold rounded-xl hover:bg-blue-700 flex items-center gap-2"
            >
              <Check className="w-4 h-4" /> {loading ? "Saving..." : "Save Workplace"}
            </button>
          </div>
        </div>
      )}

      <div className="grid gap-4">
        {workplaces.map(wp => (
          <div key={wp.id} className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200 flex flex-col sm:flex-row gap-5 items-start sm:items-center">

            <div className="w-14 h-14 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center shrink-0">
              <Building2 className="w-6 h-6" />
            </div>

            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <h3 className="font-bold text-slate-800 text-lg">{wp.name}</h3>
                {wp.verified && <BadgeCheck className="w-4 h-4 text-green-500" />}
                {wp.is_primary && (
                  <span className="bg-blue-100 text-blue-800 text-[10px] uppercase tracking-wider font-bold px-2 py-0.5 rounded ml-2">Primary</span>
                )}
              </div>

              <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-slate-600">
                <span className="font-medium text-slate-700">{wp.role}</span>
                <span className="text-slate-300">•</span>
                <span>{wp.type}</span>
                <span className="text-slate-300">•</span>
                <span className="flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5 text-slate-400" /> {wp.location}
                </span>
              </div>
            </div>

            <button className="text-slate-400 hover:text-slate-600 p-2 rounded-lg hover:bg-slate-50 self-start sm:self-auto">  
              <MoreVertical className="w-5 h-5" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
