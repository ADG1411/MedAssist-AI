import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Clock, FileText, Activity, User, QrCode } from 'lucide-react';
import { getAccessLogs } from '../../services/medcardService';
import type { AccessLog } from '../../services/medcardService';
import { getReferrals } from '../../services/referralService';
import type { Referral } from '../../types/referral';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onSelectReferral?: (token: string) => void;
  onSelectMedcard?: (token: string) => void;
}

export function ScanHistoryDrawer({ isOpen, onClose, onSelectReferral, onSelectMedcard }: Props) {
  const [logs, setLogs] = useState<AccessLog[]>([]);
  const [referrals, setReferrals] = useState<Referral[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<'medcards' | 'referrals'>('referrals');

  useEffect(() => {
    if (isOpen) {
      setLoading(true);
      Promise.all([getAccessLogs(), getReferrals()])
        .then(([logsData, refData]) => {
          setLogs(logsData);
          setReferrals(refData);
        })
        .finally(() => setLoading(false));
    }
  }, [isOpen]);

  // Handle format dates safely to prevent RangeError crashes
  const formatDate = (iso: string) => {
    try {
      if (!iso) return 'Unknown date';
      const d = new Date(iso);
      if (isNaN(d.getTime())) return 'Invalid date';
      return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    } catch {
      return 'Unknown date';
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 transition-opacity"
          />
          <motion.div
            initial={{ x: '100%', opacity: 0.5 }} animate={{ x: 0, opacity: 1 }} exit={{ x: '100%', opacity: 0 }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed inset-y-0 right-0 w-full max-w-sm bg-slate-50 border-l border-slate-200 z-50 shadow-2xl flex flex-col"
          >
            <div className="flex items-center justify-between px-5 py-4 border-b border-slate-200 bg-white">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-indigo-50 flex items-center justify-center">
                  <Clock className="w-4 h-4 text-indigo-500" />
                </div>
                <h2 className="font-bold text-slate-800">Scan History</h2>
              </div>
              <button onClick={onClose} className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="flex bg-white px-2 pt-2 border-b border-slate-200">
              <button onClick={() => setActiveTab('referrals')} className={cn("px-4 py-3 text-[13px] font-bold border-b-2 transition-colors", activeTab === 'referrals' ? "border-indigo-500 text-indigo-700" : "border-transparent text-slate-500 hover:text-slate-700")}>
                Created Referrals ({referrals.length})
              </button>
              <button onClick={() => setActiveTab('medcards')} className={cn("px-4 py-3 text-[13px] font-bold border-b-2 transition-colors", activeTab === 'medcards' ? "border-indigo-500 text-indigo-700" : "border-transparent text-slate-500 hover:text-slate-700")}>
                Scanned MedCards ({logs.length})
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {loading ? (
                <div className="flex flex-col items-center justify-center py-10 gap-3 text-slate-400">
                  <div className="w-8 h-8 border-4 border-slate-200 border-t-indigo-500 rounded-full animate-spin" />
                  <p className="text-[13px] font-medium">Loading history from database...</p>
                </div>
              ) : (
                <>
                  {activeTab === 'referrals' && (
                    referrals.length === 0 ? (
                      <p className="text-center text-slate-400 text-[13px] py-10">No referrals created yet.</p>
                    ) : (
                      referrals.map(r => (
                        <div key={r.id} className="bg-white border text-left flex flex-col border-slate-200 rounded-2xl p-4 shadow-sm hover:border-indigo-300 transition-colors">
                          <div className="flex items-start justify-between mb-2">
                            <div>
                              <p className="text-[14px] font-black text-slate-800">{r.patient_name}</p>
                              <p className="text-[11px] text-slate-500 font-medium">{formatDate(r.created_at)}</p>
                            </div>
                            <span className="px-2 py-0.5 rounded-md text-[10px] font-black uppercase tracking-wider bg-slate-100 text-slate-600">{r.type}</span>
                          </div>
                          <p className="text-[12px] text-slate-600 mb-3 line-clamp-2">{r.diagnosis}</p>
                          <button onClick={() => { if(onSelectReferral) onSelectReferral(`REFQR::${r.id}::${new Date(r.expires_at).getTime()}`); onClose(); }} className="w-full py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-600 rounded-xl text-[12px] font-bold transition-colors flex items-center justify-center gap-2">
                            <QrCode className="w-3.5 h-3.5" /> Re-scan QR Token
                          </button>
                        </div>
                      ))
                    )
                  )}

                  {activeTab === 'medcards' && (
                    logs.length === 0 ? (
                      <p className="text-center text-slate-400 text-[13px] py-10">No MedCards scanned recently.</p>
                    ) : (
                      logs.map(log => (
                        <div key={log.id} className="bg-white border text-left flex flex-col border-slate-200 rounded-2xl p-4 shadow-sm hover:border-teal-300 transition-colors group">
                           <div className="flex items-center gap-3 mb-2">
                             <div className={cn("w-8 h-8 rounded-lg flex items-center justify-center shrink-0", log.access_type === 'emergency' ? "bg-red-100 text-red-500" : "bg-teal-100 text-teal-600")}>
                               {log.access_type === 'emergency' ? <Activity className="w-4 h-4" /> : <User className="w-4 h-4" />}
                             </div>
                             <div>
                               <p className="text-[13px] font-black text-slate-800 flex items-center gap-2">Patient #{log.patient_id} {log.access_type === 'emergency' && <span className="text-[9px] bg-red-500 text-white px-1.5 py-0.5 rounded uppercase">SOS</span>}</p>
                               <p className="text-[10px] text-slate-500 font-medium">{formatDate(log.timestamp)}</p>
                             </div>
                           </div>
                           <button onClick={() => { if(onSelectMedcard) onSelectMedcard(`MEDCARD::${log.patient_id}::${Date.now() + 100000}`); onClose(); }} className="mt-1 w-full py-2 border border-slate-200 hover:border-teal-300 text-slate-600 hover:text-teal-700 rounded-xl text-[12px] font-bold transition-colors flex items-center justify-center gap-2">
                            <FileText className="w-3.5 h-3.5" /> Reload Record
                           </button>
                        </div>
                      ))
                    )
                  )}
                </>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
