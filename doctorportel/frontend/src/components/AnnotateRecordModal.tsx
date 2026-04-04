import { useState } from 'react';
import { X, Save, AlertCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface AnnotateRecordModalProps {
  recordId: string;
  patientName: string;
  category: string;
  onClose: () => void;
  onSuccess: () => void;
}

export function AnnotateRecordModal({ recordId, patientName, category, onClose, onSuccess }: AnnotateRecordModalProps) {
  const [note, setNote] = useState('');
  const [severity, setSeverity] = useState<'Normal' | 'Monitor' | 'Urgent'>('Normal');
  const [followUp, setFollowUp] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSave = async () => {
    if (!note.trim()) {
      setError('Please write a clinical note.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { error: dbError } = await supabase
        .from('doctor_record_notes')
        .insert({
          record_id: recordId,
          doctor_id: user.id,
          note: note,
          severity: severity,
          follow_up_required: followUp
        });

      if (dbError) throw dbError;
      onSuccess();
    } catch (err: any) {
      setError(err.message || 'Failed to save annotation.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-white rounded-3xl shadow-xl w-full max-w-lg overflow-hidden border border-slate-200">
        
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50">
          <div>
            <h3 className="font-black text-slate-800 text-lg tracking-tight">Annotate Record</h3>
            <p className="text-xs font-semibold text-slate-500">{category} · {patientName}</p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-slate-200 rounded-full text-slate-500 transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {error && (
            <div className="flex items-center gap-2 p-3 bg-red-50 text-red-700 text-sm font-bold rounded-xl border border-red-200">
              <AlertCircle className="w-4 h-4 shrink-0" /> {error}
            </div>
          )}

          <div>
            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Clinical Note</label>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="e.g., Patient displays mild iron deficiency. Instructed to begin supplements..."
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30 focus:border-teal-500 min-h-[120px] resize-none"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Severity Level</label>
              <div className="flex bg-slate-100 p-1 rounded-xl">
                {['Normal', 'Monitor', 'Urgent'].map(level => {
                  const active = severity === level;
                  return (
                    <button
                      key={level}
                      onClick={() => setSeverity(level as any)}
                      className={`flex-1 py-1.5 text-xs font-bold rounded-lg transition-all ${
                        active 
                          ? level === 'Urgent' ? 'bg-red-500 text-white shadow-sm' 
                          : level === 'Monitor' ? 'bg-amber-400 text-slate-900 shadow-sm' 
                          : 'bg-white text-slate-800 shadow-sm'
                          : 'text-slate-500 hover:text-slate-700'
                      }`}
                    >
                      {level}
                    </button>
                  );
                })}
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Action Required</label>
              <label className="flex items-center justify-center h-[38px] bg-slate-50 border border-slate-200 rounded-xl cursor-pointer hover:bg-slate-100 transition-colors">
                <input 
                  type="checkbox" 
                  checked={followUp} 
                  onChange={e => setFollowUp(e.target.checked)}
                  className="w-4 h-4 text-teal-600 rounded border-slate-300 focus:ring-teal-500" 
                />
                <span className="ml-2 text-sm font-semibold text-slate-700">Flag for Follow-up</span>
              </label>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 flex justify-end gap-3 bg-slate-50">
          <button
            onClick={onClose}
            className="px-5 py-2.5 text-sm font-bold text-slate-600 hover:bg-slate-200 rounded-xl transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={loading}
            className="flex items-center gap-2 bg-teal-500 hover:bg-teal-600 text-white px-6 py-2.5 rounded-xl text-sm font-bold shadow-sm transition-all disabled:opacity-50"
          >
            {loading ? (
              <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <Save className="w-4 h-4" />
            )}
            Save Note
          </button>
        </div>

      </div>
    </div>
  );
}
