import { useState, useRef, useEffect, useCallback } from 'react';
import jsQR from 'jsqr';
import { QrCode, RotateCcw, CheckCircle2, CameraOff, SwitchCamera, ImagePlus } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import { getDemoToken } from '../../services/medcardService';

interface Props {
  onScan: (token: string) => void;
  scanning: boolean;
  error: string | null;
}

const DEMO_PATIENTS = [
  { id: 1, label: 'Rahul Sharma', sub: 'B+ · 34 yrs · Male'   },
  { id: 2, label: 'Priya Verma',  sub: 'A+ · 28 yrs · Female' },
  { id: 3, label: 'Arjun Mehta',  sub: 'O+ · 52 yrs · Male'   },
];

type CameraState = 'idle' | 'requesting' | 'active' | 'denied';

export const QRScanner = ({ onScan, scanning, error }: Props) => {
  const [mode, setMode]         = useState<'camera' | 'manual'>('camera');
  const [manualInput, setInput] = useState('');
  const [demoLoading, setDemo]  = useState<number | null>(null);
  const [camState, setCamState] = useState<CameraState>('idle');
  const [camError, setCamError] = useState<string | null>(null);
  const [facingMode, setFacing] = useState<'environment' | 'user'>('environment');
  const [detected, setDetected] = useState(false);

  const videoRef   = useRef<HTMLVideoElement>(null);
  const canvasRef  = useRef<HTMLCanvasElement>(null);
  const streamRef  = useRef<MediaStream | null>(null);
  const rafRef     = useRef<number>(0);
  const scannedRef = useRef(false);
  const fileRef    = useRef<HTMLInputElement>(null);

  // ── jsQR canvas scan loop (works in ALL browsers) ─────────────────────────
  const scanFrames = useCallback(() => {
    const tick = () => {
      if (scannedRef.current) return;
      const video  = videoRef.current;
      const canvas = canvasRef.current;
      if (video && canvas && video.readyState >= 2 && video.videoWidth > 0) {
        const ctx = canvas.getContext('2d', { willReadFrequently: true });
        if (ctx) {
          canvas.width  = video.videoWidth;
          canvas.height = video.videoHeight;
          ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
          const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
          const code = jsQR(imgData.data, imgData.width, imgData.height, {
            inversionAttempts: 'dontInvert',
          });
          if (code?.data) {
            scannedRef.current = true;
            setDetected(true);
            stopCamera();
            setTimeout(() => onScan(code.data), 300);
            return;
          }
        }
      }
      rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);
  }, [onScan]);

  // ── Stop camera ────────────────────────────────────────────────────────────
  const stopCamera = useCallback(() => {
    cancelAnimationFrame(rafRef.current);
    streamRef.current?.getTracks().forEach(t => t.stop());
    streamRef.current = null;
    if (videoRef.current) videoRef.current.srcObject = null;
    setCamState('idle');
  }, []);

  // ── Start camera ───────────────────────────────────────────────────────────
  const startCamera = useCallback(async (facing: 'environment' | 'user' = 'environment') => {
    stopCamera();
    scannedRef.current = false;
    setDetected(false);
    setCamError(null);
    setCamState('requesting');
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: facing }, width: { ideal: 1280 }, height: { ideal: 720 } },
        audio: false,
      });
      streamRef.current = stream;
      const video = videoRef.current;
      if (video) {
        video.srcObject = stream;
        video.onloadedmetadata = () => { video.play(); setCamState('active'); scanFrames(); };
      }
    } catch (e: any) {
      setCamState('denied');
      setCamError(
        e.name === 'NotAllowedError'
          ? 'Camera permission denied. Allow access in browser settings, then click Try Again.'
          : `Camera error: ${e.message}`
      );
    }
  }, [scanFrames, stopCamera]);

  useEffect(() => {
    if (mode === 'camera') startCamera(facingMode);
    else stopCamera();
    return () => stopCamera();
  }, [mode]);

  const flipCamera = () => {
    const next = facingMode === 'environment' ? 'user' : 'environment';
    setFacing(next);
    startCamera(next);
  };

  // ── Image file QR decode ───────────────────────────────────────────────────
  const handleImageFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width; canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        if (!ctx) return;
        ctx.drawImage(img, 0, 0);
        const imgData = ctx.getImageData(0, 0, img.width, img.height);
        const code = jsQR(imgData.data, imgData.width, imgData.height);
        if (code?.data) { onScan(code.data); }
        else { setCamError('No QR code found in image. Try a clearer photo.'); }
      };
      img.src = reader.result as string;
    };
    reader.readAsDataURL(file);
    e.target.value = '';
  };

  const handleManual = () => { const t = manualInput.trim(); if (t) onScan(t); };

  const handleDemo = async (patientId: number) => {
    setDemo(patientId);
    try { const { token } = await getDemoToken(patientId); onScan(token); }
    finally { setDemo(null); }
  };

  return (
    <div className="space-y-4">

      {/* Mode toggle */}
      <div className="flex bg-slate-100 rounded-2xl p-1 gap-1">
        {(['camera', 'manual'] as const).map(m => (
          <button key={m} onClick={() => setMode(m)}
            className={cn('flex-1 py-2.5 rounded-xl text-[13px] font-bold transition-all',
              mode === m ? 'bg-white text-slate-800 shadow-sm' : 'text-slate-500 hover:text-slate-700')}>
            {m === 'camera' ? '📷 Camera Scan' : '⌨️ Manual Entry'}
          </button>
        ))}
      </div>

      {/* ── CAMERA MODE ── */}
      {mode === 'camera' && (
        <div className="space-y-3">
          <div className="relative aspect-[4/3] bg-black rounded-3xl overflow-hidden border-2 border-slate-800 shadow-2xl">

            {/* Real camera video */}
            <video
              ref={videoRef}
              className={cn('absolute inset-0 w-full h-full object-cover', camState !== 'active' && 'hidden')}
              muted
              playsInline
              autoPlay
            />

            {/* Scan overlay — only when camera is active */}
            {camState === 'active' && !detected && (
              <div className="absolute inset-0 pointer-events-none">
                {/* Corner brackets */}
                <div className="absolute top-8 left-8 w-14 h-14 border-t-4 border-l-4 border-teal-400 rounded-tl-lg" />
                <div className="absolute top-8 right-8 w-14 h-14 border-t-4 border-r-4 border-teal-400 rounded-tr-lg" />
                <div className="absolute bottom-8 left-8 w-14 h-14 border-b-4 border-l-4 border-teal-400 rounded-bl-lg" />
                <div className="absolute bottom-8 right-8 w-14 h-14 border-b-4 border-r-4 border-teal-400 rounded-br-lg" />
                {/* Animated scan line */}
                <div className="absolute left-10 right-10 h-0.5 bg-gradient-to-r from-transparent via-teal-400 to-transparent"
                  style={{ animation: 'scanline 2.2s ease-in-out infinite' }} />
                <p className="absolute bottom-4 left-0 right-0 text-center text-[11px] text-teal-300 font-bold tracking-widest uppercase">
                  Align QR code in frame
                </p>
              </div>
            )}

            {/* Detected flash */}
            {detected && (
              <div className="absolute inset-0 bg-emerald-500/30 flex items-center justify-center">
                <div className="bg-emerald-500 rounded-full p-4 shadow-xl animate-in zoom-in duration-200">
                  <CheckCircle2 className="w-10 h-10 text-white" />
                </div>
              </div>
            )}

            {/* Requesting permission */}
            {camState === 'requesting' && (
              <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-3">
                <div className="w-10 h-10 border-4 border-teal-400 border-t-transparent rounded-full animate-spin" />
                <p className="text-slate-300 font-bold text-sm">Starting camera…</p>
              </div>
            )}

            {/* Camera denied */}
            {camState === 'denied' && (
              <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-4 px-6 text-center">
                <CameraOff className="w-12 h-12 text-slate-500" />
                <p className="text-slate-300 font-bold text-sm">{camError}</p>
                <button onClick={() => startCamera(facingMode)}
                  className="bg-teal-500 text-white font-bold text-[13px] px-5 py-2.5 rounded-xl hover:bg-teal-600 transition-colors">
                  Try Again
                </button>
              </div>
            )}

            {/* Idle state */}
            {camState === 'idle' && !detected && (
              <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-3">
                <QrCode className="w-12 h-12 text-slate-600" />
                <p className="text-slate-500 font-medium text-sm">Camera not started</p>
              </div>
            )}

            {/* Flip camera button */}
            {camState === 'active' && (
              <button onClick={flipCamera}
                className="absolute top-3 right-3 w-9 h-9 bg-black/40 backdrop-blur-sm rounded-xl flex items-center justify-center text-white hover:bg-black/60 transition-colors">
                <SwitchCamera className="w-4 h-4" />
              </button>
            )}
          </div>

          {/* Hidden canvas used by jsQR */}
          <canvas ref={canvasRef} className="hidden" />
          {/* Hidden file input */}
          <input ref={fileRef} type="file" accept="image/*" capture="environment" className="hidden" onChange={handleImageFile} />

          {camState === 'active' && (
            <p className="text-center text-[11px] text-slate-400 font-medium">
              Camera active · jsQR auto-scanning · Works in all browsers
            </p>
          )}
          {/* Upload QR image fallback */}
          <button onClick={() => fileRef.current?.click()}
            className="w-full flex items-center justify-center gap-2 bg-white border border-slate-200 hover:border-teal-300 hover:bg-teal-50 text-slate-600 hover:text-teal-700 font-bold text-[12px] py-2.5 rounded-xl transition-all">
            <ImagePlus className="w-4 h-4" /> Upload QR Image / Take Photo
          </button>
        </div>
      )}

      {/* ── MANUAL MODE ── */}
      {mode === 'manual' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
          <p className="text-[13px] font-black text-slate-700 mb-1">Paste MedCard Token</p>
          <p className="text-[11px] text-slate-400 font-medium mb-3">Format: <code className="bg-slate-100 px-1 py-0.5 rounded text-teal-600">MEDCARD::&lt;id&gt;::&lt;timestamp&gt;</code></p>
          <textarea
            value={manualInput}
            onChange={e => setInput(e.target.value)}
            placeholder="MEDCARD::1::1743680000000"
            rows={3}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-[12px] font-mono text-slate-700 outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 resize-none placeholder:text-slate-400 transition-colors"
          />
          <button onClick={handleManual} disabled={!manualInput.trim() || scanning}
            className="mt-3 w-full flex items-center justify-center gap-2 bg-teal-500 hover:bg-teal-600 disabled:opacity-50 text-white font-bold text-[13px] py-3 rounded-xl transition-all active:scale-[0.98]">
            {scanning
              ? <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              : <CheckCircle2 className="w-4 h-4" />}
            {scanning ? 'Validating…' : 'Validate Token'}
          </button>
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-2xl px-4 py-3 flex items-start gap-2.5">
          <span className="text-red-500 text-lg shrink-0">⚠</span>
          <div>
            <p className="text-[13px] font-black text-red-700">Scan Failed</p>
            <p className="text-[12px] text-red-600 font-medium mt-0.5">{error}</p>
          </div>
        </div>
      )}

      {/* Demo quick access */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
        <div className="flex items-center gap-2 mb-3">
          <span className="text-base">🧪</span>
          <p className="text-[13px] font-black text-slate-700">Quick Demo Access</p>
          <span className="ml-auto text-[10px] font-bold text-amber-600 bg-amber-50 border border-amber-200 px-2 py-0.5 rounded-lg">NO CAMERA NEEDED</span>
        </div>
        <p className="text-[11px] text-slate-400 font-medium mb-3">
          Tap to instantly simulate a QR scan for any demo patient.
        </p>
        <div className="space-y-2">
          {DEMO_PATIENTS.map(p => (
            <button key={p.id} onClick={() => handleDemo(p.id)}
              disabled={scanning || demoLoading !== null}
              className="w-full flex items-center gap-3 bg-slate-50 hover:bg-teal-50 border border-slate-200 hover:border-teal-200 rounded-xl px-4 py-3 text-left transition-all group disabled:opacity-60">
              <div className="w-8 h-8 bg-teal-100 rounded-xl flex items-center justify-center shrink-0">
                {demoLoading === p.id
                  ? <div className="w-4 h-4 border-2 border-teal-500 border-t-transparent rounded-full animate-spin" />
                  : <QrCode className="w-4 h-4 text-teal-600" />}
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[13px] font-black text-slate-800 group-hover:text-teal-700">{p.label}</p>
                <p className="text-[10px] font-medium text-slate-400">{p.sub} · Patient #{p.id}</p>
              </div>
              <RotateCcw className="w-3.5 h-3.5 text-slate-300 group-hover:text-teal-500 shrink-0" />
            </button>
          ))}
        </div>
      </div>

      <style>{`
        @keyframes scanline {
          0%   { top: 15%; opacity: 0; }
          10%  { opacity: 1; }
          90%  { opacity: 1; }
          100% { top: 85%; opacity: 0; }
        }
      `}</style>
    </div>
  );
};
