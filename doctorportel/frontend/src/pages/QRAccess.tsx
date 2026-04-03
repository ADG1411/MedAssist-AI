import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { ExternalLink } from 'lucide-react';
import { QRScanner }       from '../components/medcard/QRScanner';
import { PatientPreview }   from '../components/medcard/PatientPreview';
import { PatientDashboard } from '../components/medcard/PatientDashboard';
import {
  scanQR, accessFullRecord,
  type QRPreview, type FullRecord,
} from '../services/medcardService';

type Phase = 'scan' | 'preview' | 'dashboard';

export default function QRAccess() {
  const [phase, setPhase]             = useState<Phase>('scan');
  const [token, setToken]             = useState('');
  const [preview, setPreview]         = useState<QRPreview | null>(null);
  const [record, setRecord]           = useState<FullRecord | null>(null);
  const [isEmergency, setIsEmergency] = useState(false);
  const [scanning, setScanning]       = useState(false);
  const [accessing, setAccessing]     = useState(false);
  const [error, setError]             = useState<string | null>(null);
  const navigate = useNavigate();

  const handleScan = async (scannedToken: string) => {
    setError(null);
    setScanning(true);
    setToken(scannedToken);
    try {
      const data = await scanQR(scannedToken);
      setPreview(data);
      setPhase('preview');
    } catch (e: any) {
      setError(e.message ?? 'QR scan failed. Token may be expired or invalid.');
    } finally {
      setScanning(false);
    }
  };

  const handleAccess = async (emergency = false) => {
    if (!token) return;
    setError(null);
    setAccessing(true);
    setIsEmergency(emergency);
    try {
      const data = await accessFullRecord(token, emergency);
      setRecord(data);
      setPhase('dashboard');
    } catch (e: any) {
      setError(e.message ?? 'Access denied. Please re-authenticate.');
    } finally {
      setAccessing(false);
    }
  };

  const handleNewScan = () => {
    setPhase('scan');
    setToken('');
    setPreview(null);
    setRecord(null);
    setError(null);
    setIsEmergency(false);
  };

  return (
    <div className="max-w-lg mx-auto pb-20 md:pb-8">
      <AnimatePresence mode="wait">
        <motion.div
          key={phase}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -10 }}
          transition={{ duration: 0.2 }}
        >
          {phase === 'scan' && (
            <QRScanner onScan={handleScan} scanning={scanning} error={error} />
          )}

          {phase === 'preview' && preview && (
            <PatientPreview
              preview={preview}
              onAccess={() => handleAccess(false)}
              onEmergency={() => handleAccess(true)}
              loading={accessing}
            />
          )}

          {phase === 'dashboard' && record && (
            <div className="space-y-4">
              <div className="flex items-center justify-between gap-3 bg-white border border-slate-200 rounded-2xl px-5 py-4 shadow-sm">
                <div>
                  <p className="font-black text-slate-800 text-[13px]">Full Record &amp; PDF</p>
                  <p className="text-[11px] font-medium text-slate-400">Open printable view · download as PDF</p>
                </div>
                <button
                  onClick={() => navigate(`/dashboard/medcard/record/${record.patient.id}`)}
                  className="flex items-center gap-2 bg-teal-500 hover:bg-teal-600 text-white font-bold text-[12px] px-4 py-2 rounded-xl transition-all shrink-0">
                  <ExternalLink className="w-3.5 h-3.5" /> Open PDF
                </button>
              </div>
              <PatientDashboard
                record={record}
                isEmergency={isEmergency}
                onNewScan={handleNewScan}
              />
            </div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}
