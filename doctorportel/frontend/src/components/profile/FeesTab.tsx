import { useState, useEffect } from "react";
import { DollarSign, Video, Users, AlertCircle, Check, Loader2 } from "lucide-react";
import { cn } from "../../layouts/DashboardLayout";
import { profileService } from "../../services/profileService";

export const FeesTab = () => {
  const [hasFreeFirst, setHasFreeFirst] = useState(false);
  const [videoFee, setVideoFee] = useState("80");
  const [inPersonFee, setInPersonFee] = useState("150");
  const [emergencyFee, setEmergencyFee] = useState("250");
  
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusMsg, setStatusMsg] = useState<{type: "error" | "success", text: string} | null>(null);

  useEffect(() => {
    const fetchFees = async () => {
      const data = await profileService.getFees();
      if (data) {
        setHasFreeFirst(data.has_free_first_consult);
        setVideoFee(data.video_fee.toString());
        setInPersonFee(data.in_person_fee.toString());
        setEmergencyFee(data.emergency_fee.toString());
      }
      setLoading(false);
    };
    fetchFees();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setStatusMsg(null);
    
    const { error } = await profileService.upsertFees({
      has_free_first_consult: hasFreeFirst,
      video_fee: Number(videoFee) || 0,
      in_person_fee: Number(inPersonFee) || 0,
      emergency_fee: Number(emergencyFee) || 0
    });
    
    setSaving(false);
    if (error) {
      setStatusMsg({ type: "error", text: "Failed to update fees" });
    } else {
      setStatusMsg({ type: "success", text: "Fees updated successfully!" });
    }
    setTimeout(() => setStatusMsg(null), 3000);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12">
        <Loader2 className="w-8 h-8 animate-spin text-brand-blue" />
      </div>
    );
  }

  return (
    <div className="space-y-6">

      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-6 gap-4">
          <div>
            <h3 className="font-bold text-lg text-slate-800">Consultation Fees</h3>
            <p className="text-sm text-slate-500">Set your pricing for different types of appointments.</p>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-sm font-bold text-slate-700">Free First Consult</span>
            <button
              onClick={() => setHasFreeFirst(!hasFreeFirst)}
              className={cn(
                "w-12 h-6 rounded-full relative transition-colors duration-300",
                hasFreeFirst ? "bg-green-500" : "bg-slate-200"
              )}
            >
              <div className={cn(
                "absolute top-1 left-1 bg-white w-4 h-4 rounded-full transition-transform duration-300 shadow-sm",
                hasFreeFirst ? "translate-x-6" : "translate-x-0"
              )} />
            </button>
          </div>
        </div>

        <div className="space-y-4 mb-6">

          {/* Video Consult */}
          <div className="flex flex-col sm:flex-row gap-4 p-4 border border-slate-200 rounded-xl items-start sm:items-center justify-between hover:border-brand-blue/30 transition-colors">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center">
                <Video className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800">Video Consultation</h4>
                <p className="text-xs text-slate-500">15 mins • Standard online</p>
              </div>
            </div>

            <div className="relative w-full sm:w-32">
              <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input 
                type="number" 
                value={videoFee}
                onChange={(e) => setVideoFee(e.target.value)}
                className="w-full pl-8 pr-4 py-2 border border-slate-200 rounded-lg outline-none focus:border-brand-blue focus:ring-2 ring-brand-blue/20" 
              />
            </div>
          </div>

          {/* In-Person Consult */}
          <div className="flex flex-col sm:flex-row gap-4 p-4 border border-slate-200 rounded-xl items-start sm:items-center justify-between hover:border-brand-blue/30 transition-colors">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-emerald-50 text-emerald-600 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800">In-Person Visit</h4>
                <p className="text-xs text-slate-500">30 mins • Clinic visit</p>
              </div>
            </div>

            <div className="relative w-full sm:w-32">
              <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input 
                type="number" 
                value={inPersonFee}
                onChange={(e) => setInPersonFee(e.target.value)}
                className="w-full pl-8 pr-4 py-2 border border-slate-200 rounded-lg outline-none focus:border-brand-blue focus:ring-2 ring-brand-blue/20" 
              />
            </div>
          </div>

          {/* Emergency / Walk-in */}
          <div className="flex flex-col sm:flex-row gap-4 p-4 border border-red-100 bg-red-50/30 rounded-xl items-start sm:items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-red-100 text-red-600 rounded-lg flex items-center justify-center">
                <AlertCircle className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800">Emergency / SOS</h4>
                <p className="text-xs text-red-500 font-medium">Immediate priority access</p>
              </div>
            </div>

            <div className="relative w-full sm:w-32">
              <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-red-400" />
              <input 
                type="number" 
                value={emergencyFee}
                onChange={(e) => setEmergencyFee(e.target.value)}
                className="w-full pl-8 pr-4 py-2 border border-red-200 rounded-lg outline-none focus:border-red-400 focus:ring-2 ring-red-400/20 bg-white" 
              />
            </div>
          </div>
        </div>

        {/* Save Actions */}
        <div className="flex flex-col sm:flex-row items-center justify-end gap-4 border-t border-slate-100 pt-6 mt-4">
          {statusMsg && (
            <div className={`text-sm font-medium ${statusMsg.type === "error" ? "text-red-500" : "text-emerald-600"}`}>
              {statusMsg.text}
            </div>
          )}
          <button
            onClick={handleSave}
            disabled={saving}
            className="bg-brand-blue text-white hover:bg-blue-700 px-6 py-2.5 rounded-xl text-sm font-bold flex items-center gap-2 shadow-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed w-full sm:w-auto justify-center"
          >
            {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4" />}
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>

      </div>
    </div>
  );
};
