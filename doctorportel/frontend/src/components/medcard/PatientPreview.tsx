import { useState } from 'react';
import { Share2, Lock, ShieldCheck, AlertTriangle, Eye, EyeOff } from 'lucide-react';
import { RevealAndCopy } from '../ui/reveal-copy';
import type { QRPreview } from '../../services/medcardService';

interface Props {
  preview: QRPreview;
  onAccess: () => void;
  onEmergency: () => void;
  loading: boolean;
}

/* Deterministic 8-digit suffix from patient ID */
const medId = (id: number) =>
  `MED-${new Date().getFullYear()}-${id}-${String(id * 7591 + 58569856).slice(-8)}`;

export const PatientPreview = ({ preview, onAccess, onEmergency, loading }: Props) => {
  const [hidden, setHidden] = useState(true);
  const [qrTimestamp, setQrTimestamp] = useState(() => Date.now());

  const hid    = medId(preview.patient_id);
  const qrData = `MEDCARD::${preview.patient_id}::${qrTimestamp + 30 * 60 * 1000}`;
  const qrUrl  = `https://api.qrserver.com/v1/create-qr-code/?data=${encodeURIComponent(qrData)}&size=112x112&bgcolor=ffffff&color=1a2535&margin=5`;

  const maskedPhone = preview.phone_masked;

  const handleShare = () => {
    const text = `MedAssist Patient Card\nName: ${preview.name}\nID: ${hid}\nBlood: ${preview.blood_group}`;
    if (navigator.share) navigator.share({ title: 'Patient Card', text });
    else navigator.clipboard?.writeText(text);
  };

  return (
    <div className="max-w-lg mx-auto space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-400">

      {/* QR verified pill */}
      <div className="flex items-center justify-center gap-2 text-[12px] font-bold text-emerald-500">
        <div className="w-4 h-4 bg-emerald-500 rounded-full flex items-center justify-center shrink-0">
          <span className="text-white text-[9px] font-black">✓</span>
        </div>
        QR Code Verified Successfully
      </div>

      {/* ══════════════ SINGLE-FACE CARD ══════════════ */}
      <div className="bg-[#1a2535] rounded-3xl overflow-hidden shadow-2xl shadow-slate-900/60">

        {/* ── Top bar ── */}
        <div className="flex items-start justify-between px-6 pt-5 pb-0">
          <div>
            <p className="text-slate-400 text-[9px] font-black uppercase tracking-[0.2em]">MedAssist Card</p>
            <p className="text-teal-400 text-[11px] font-bold mt-0.5">Universal Health ID</p>
          </div>
          <div className="flex items-center gap-1.5 bg-[#0f1c2c] border border-teal-500/40 px-2.5 py-1 rounded-full mt-1">
            <span className="w-1.5 h-1.5 bg-teal-400 rounded-full animate-pulse" />
            <span className="text-teal-400 text-[9px] font-black tracking-wider">ACTIVE</span>
          </div>
        </div>

        {/* ── Main content + QR side-by-side ── */}
        <div className="flex items-start gap-4 px-6 pt-4 pb-4 pr-4">

          {/* Left: all fields */}
          <div className="flex-1 min-w-0 space-y-3.5">

            {/* Patient Name */}
            <div>
              <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-0.5">Patient Name</p>
              <p className="text-white font-black text-[22px] tracking-tight leading-tight">{preview.name}</p>
            </div>

            {/* Health ID */}
            <div>
              <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-0.5">Health ID</p>
              <RevealAndCopy cardNumber={hid} hiddenIndexes={[2, 3]} revealDuration={2500} />
            </div>

            {/* Blood group + Age row */}
            <div className="flex items-center gap-3">
              <div>
                <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-1">Blood Group</p>
                <div className="flex items-center gap-1 bg-teal-500 text-white px-3 py-1.5 rounded-xl w-fit">
                  <span className="text-[8px] font-black text-teal-100">BLOOD</span>
                  <span className="font-black text-[13px]">{preview.blood_group}</span>
                </div>
              </div>
              <div>
                <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-1">Age</p>
                <p className="text-white font-bold text-[13px]">{preview.age} years</p>
              </div>
            </div>

            {/* Mobile */}
            <div>
              <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-0.5">Mobile Number</p>
              <p className="text-white font-bold text-[13px] font-mono tracking-wider">
                {hidden ? maskedPhone : maskedPhone.replace(/\*/g, preview.patient_id.toString()[0] ?? '9')}
              </p>
            </div>

            {/* Emergency Contact */}
            <div>
              <p className="text-teal-500 text-[8px] font-black uppercase tracking-[0.18em] mb-0.5">Emergency Contact</p>
              <p className="text-white font-bold text-[13px]">
                {hidden ? '••••' + maskedPhone.slice(-4) : maskedPhone}
              </p>
            </div>
          </div>

          {/* Right: QR code */}
          <button onClick={() => setQrTimestamp(Date.now())} className="flex flex-col items-center gap-1.5 shrink-0 group hover:opacity-90 active:scale-95 transition-all outline-none">
            <div className="bg-white rounded-2xl p-2 shadow-lg">
              <img
                src={qrUrl}
                alt="Scan QR"
                width={96}
                height={96}
                className="block rounded-lg pointer-events-none"
                onError={e => { (e.target as HTMLImageElement).style.opacity = '0'; }}
              />
            </div>
            <p className="text-teal-400 opacity-90 text-[9px] font-bold tracking-wider text-center">Tap for new QR</p>
          </button>
        </div>

        {/* ── Bottom action bar ── */}
        <div className="flex items-center justify-between px-5 py-3 border-t border-slate-700/50 bg-slate-800/50">

          {/* Left: Share + Hide */}
          <div className="flex items-center gap-2">
            <button onClick={handleShare}
              className="flex items-center gap-1.5 text-[11px] font-black text-slate-300 hover:text-white bg-slate-700/70 hover:bg-slate-600/80 px-3.5 py-2 rounded-xl transition-all">
              <Share2 className="w-3.5 h-3.5" /> Share
            </button>
            <button onClick={() => setHidden(h => !h)}
              className="flex items-center gap-1.5 text-[11px] font-black text-slate-300 hover:text-white bg-slate-700/70 hover:bg-slate-600/80 px-3.5 py-2 rounded-xl transition-all">
              {hidden
                ? <><EyeOff className="w-3.5 h-3.5" /> Hidden</>
                : <><Eye     className="w-3.5 h-3.5" /> Visible</>
              }
            </button>
          </div>

          {/* Right: Lock note */}
          <div className="flex items-center gap-1.5">
            <Lock className="w-3 h-3 text-slate-600" />
            <span className="text-[10px] text-slate-600 font-semibold">Auth required</span>
          </div>
        </div>
      </div>

      {/* Access buttons below card */}
      <div className="flex items-center gap-3">
        <button onClick={onAccess} disabled={loading}
          className="flex-1 flex items-center justify-center gap-2 bg-teal-500 hover:bg-teal-600 disabled:opacity-60 text-white font-black text-[13px] py-3 rounded-2xl transition-all active:scale-[0.98] shadow-lg shadow-teal-500/20">
          {loading
            ? <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
            : <ShieldCheck className="w-4 h-4" />
          }
          {loading ? 'Authenticating…' : 'Access Full Record'}
        </button>
        <button onClick={onEmergency} disabled={loading}
          className="flex items-center gap-1.5 bg-red-500/90 hover:bg-red-500 disabled:opacity-60 text-white font-black text-[12px] px-4 py-3 rounded-2xl transition-all">
          <AlertTriangle className="w-4 h-4" /> SOS
        </button>
      </div>

      <p className="text-center text-[10px] text-slate-500 font-medium">
        Emergency access is logged · No OTP required
      </p>
    </div>
  );
};
