import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { QRCodeSVG } from 'qrcode.react';
import {
  QrCode, Plus, TrendingUp, ArrowLeft,
  CheckCircle2, Loader2, IndianRupee, BarChart3,
  FlaskConical, Stethoscope, User, Share2,
} from 'lucide-react';
import jsQR from 'jsqr';
import { useRef, useEffect, useCallback } from 'react';
import { cn } from '../layouts/DashboardLayout';
import { AIInsights }      from '../components/referral/AIInsights';
import { ReferralDetails } from '../components/referral/ReferralDetails';
import { ReferralForm }    from '../components/referral/ReferralForm';
import { BookingModal }    from '../components/referral/BookingModal';
import { TicketView }      from '../components/referral/TicketView';
import {
  createReferral, generateReferralQR, scanReferralQR,
  getProviders, createBooking, getEarnings,
  getDemoReferralToken,
} from '../services/referralService';
import type {
  Referral, AIInsight, Provider, Ticket, Earning,
  EarningsSummary, BookingType, CreateReferralPayload,
} from '../types/referral';

// ─── Tabs ────────────────────────────────────────────────────────────────────
type Tab = 'scan' | 'create' | 'earnings';

// ─── Scanner hook ─────────────────────────────────────────────────────────────
function useQRScanner(onScan: (token: string) => void) {
  const videoRef  = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const rafRef    = useRef(0);
  const streamRef = useRef<MediaStream | null>(null);
  const scanned   = useRef(false);
  const [camState, setCamState] = useState<'idle' | 'requesting' | 'active' | 'denied'>('idle');

  const stop = useCallback(() => {
    cancelAnimationFrame(rafRef.current);
    streamRef.current?.getTracks().forEach(t => t.stop());
    streamRef.current = null;
    if (videoRef.current) videoRef.current.srcObject = null;
    setCamState('idle');
  }, []);

  const start = useCallback(async () => {
    scanned.current = false;
    setCamState('requesting');
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false });
      streamRef.current = stream;
      const v = videoRef.current!;
      v.srcObject = stream;
      v.onloadedmetadata = () => {
        v.play();
        setCamState('active');
        const tick = () => {
          if (scanned.current) return;
          const c = canvasRef.current!;
          if (v.readyState >= 2 && v.videoWidth > 0) {
            c.width = v.videoWidth; c.height = v.videoHeight;
            const ctx = c.getContext('2d', { willReadFrequently: true })!;
            ctx.drawImage(v, 0, 0);
            const code = jsQR(ctx.getImageData(0, 0, c.width, c.height).data, c.width, c.height);
            if (code?.data) { scanned.current = true; stop(); setTimeout(() => onScan(code.data), 200); return; }
          }
          rafRef.current = requestAnimationFrame(tick);
        };
        rafRef.current = requestAnimationFrame(tick);
      };
    } catch { setCamState('denied'); }
  }, [onScan, stop]);

  useEffect(() => () => stop(), [stop]);
  return { videoRef, canvasRef, camState, start, stop };
}

// ─── Earnings Dashboard ────────────────────────────────────────────────────────
function EarningsDashboard() {
  const [data, setData] = useState<EarningsSummary | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => { getEarnings().then(setData).finally(() => setLoading(false)); }, []);

  const TYPE_COLOR: Record<string, string> = { lab: 'bg-teal-100 text-teal-700', hospital: 'bg-blue-100 text-blue-700', specialist: 'bg-violet-100 text-violet-700' };

  if (loading) return <div className="flex justify-center py-16"><Loader2 className="w-6 h-6 animate-spin text-slate-400" /></div>;
  if (!data)   return null;

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-3">
        {[
          { label: 'Total Bookings',     value: data.total_bookings.toString(),         icon: BarChart3,    color: 'text-blue-600',   bg: 'bg-blue-50' },
          { label: 'Total Revenue',      value: `₹${data.total_revenue.toLocaleString('en-IN')}`, icon: IndianRupee,  color: 'text-emerald-600', bg: 'bg-emerald-50' },
          { label: 'Total Commission',   value: `₹${data.total_commission.toLocaleString('en-IN')}`, icon: TrendingUp, color: 'text-indigo-600', bg: 'bg-indigo-50' },
          { label: 'Pending Payout',     value: `₹${data.pending_commission.toLocaleString('en-IN')}`, icon: IndianRupee, color: 'text-amber-600', bg: 'bg-amber-50' },
        ].map((s, i) => (
          <motion.div key={i} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.06 }}
            className="bg-white rounded-2xl border border-slate-100 p-4 shadow-sm">
            <div className={cn('w-9 h-9 rounded-xl flex items-center justify-center mb-2', s.bg)}>
              <s.icon className={cn('w-4 h-4', s.color)} />
            </div>
            <p className="text-xl font-black text-slate-800">{s.value}</p>
            <p className="text-[11px] text-slate-400 font-semibold mt-0.5">{s.label}</p>
          </motion.div>
        ))}
      </div>

      {data.recent.length === 0 ? (
        <div className="text-center py-12 text-slate-400">
          <IndianRupee className="w-10 h-10 mx-auto mb-2 opacity-20" />
          <p className="font-semibold text-[13px]">No earnings yet · Create referrals to start earning</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="px-4 py-3 border-b border-slate-100">
            <p className="text-[13px] font-black text-slate-700">Recent Transactions</p>
          </div>
          {data.recent.map((e: Earning) => (
            <div key={e.id} className="flex items-center gap-3 px-4 py-3 border-b border-slate-50 last:border-0">
              <div className={cn('w-8 h-8 rounded-xl flex items-center justify-center shrink-0 text-[10px] font-black', TYPE_COLOR[e.booking_type] ?? 'bg-slate-100 text-slate-600')}>
                {e.booking_type[0].toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[13px] font-black text-slate-800 truncate">{e.patient_name}</p>
                <p className="text-[11px] text-slate-400">{e.provider_name}</p>
              </div>
              <div className="text-right shrink-0">
                <p className="text-[13px] font-black text-emerald-600">+₹{e.commission_amount.toFixed(0)}</p>
                <span className={cn('text-[10px] font-bold px-1.5 py-0.5 rounded-md', e.status === 'paid' ? 'bg-emerald-50 text-emerald-600' : 'bg-amber-50 text-amber-600')}>
                  {e.status.toUpperCase()}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Main Page ─────────────────────────────────────────────────────────────────
export default function ReferralPage() {
  const [tab, setTab] = useState<Tab>('scan');

  // Scan flow state
  const [scanPhase, setScanPhase] = useState<'scanner' | 'details' | 'booking' | 'ticket'>('scanner');
  const [scanning,  setScanning]  = useState(false);
  const [scanError, setScanError] = useState<string | null>(null);
  const [referral,  setReferral]  = useState<Referral | null>(null);
  const [insight,   setInsight]   = useState<AIInsight | null>(null);
  const [bookingType, setBookingType] = useState<BookingType>('lab');
  const [providers, setProviders] = useState<Provider[]>([]);
  const [ticket,    setTicket]    = useState<Ticket | null>(null);

  // Create flow state
  const [createdReferral, setCreatedReferral] = useState<Referral | null>(null);
  const [qrToken,         setQrToken]         = useState<string | null>(null);

  const handleScan = async (token: string) => {
    setScanError(null);
    setScanning(true);
    try {
      const { referral: r, ai_insight } = await scanReferralQR(token);
      setReferral(r);
      setInsight(ai_insight);
      setScanPhase('details');
    } catch (e: any) {
      setScanError(e.message ?? 'Invalid or expired referral QR.');
    } finally {
      setScanning(false);
    }
  };

  const handleDemo = async () => {
    const token = await getDemoReferralToken();
    await handleScan(token);
  };

  const { videoRef, canvasRef, camState, start, stop } = useQRScanner(handleScan);

  useEffect(() => {
    if (tab === 'scan' && scanPhase === 'scanner') start();
    else stop();
  }, [tab, scanPhase]);

  const openBooking = async (type: BookingType) => {
    setBookingType(type);
    const list = await getProviders(type);
    setProviders(list);
    setScanPhase('booking');
  };

  const handleBookingConfirm = async (providerId: string, date: string, timeSlot: string) => {
    if (!referral) return;
    const { ticket: t } = await createBooking({ referral_id: referral.id, type: bookingType, provider_id: providerId, date, time_slot: timeSlot });
    setTicket(t);
    setScanPhase('ticket');
  };

  const resetScan = () => {
    setScanPhase('scanner');
    setReferral(null);
    setInsight(null);
    setTicket(null);
    setScanError(null);
  };

  const handleCreate = async (payload: CreateReferralPayload) => {
    const ref = await createReferral(payload);
    const qr  = await generateReferralQR(ref.id);
    setCreatedReferral(ref);
    setQrToken(qr.token);
  };

  const resetCreate = () => { setCreatedReferral(null); setQrToken(null); };

  const TABS = [
    { id: 'scan'     as Tab, label: 'Scan QR',    icon: QrCode        },
    { id: 'create'   as Tab, label: 'Create',     icon: Plus          },
    { id: 'earnings' as Tab, label: 'Earnings',   icon: TrendingUp    },
  ];

  return (
    <div className="max-w-lg mx-auto pb-20 md:pb-8">

      {/* Tab Bar */}
      <div className="flex bg-slate-100 rounded-2xl p-1 gap-1 mb-6">
        {TABS.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)}
            className={cn('flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl text-[13px] font-bold transition-all',
              tab === t.id ? 'bg-white text-slate-800 shadow-sm' : 'text-slate-500 hover:text-slate-700')}>
            <t.icon className="w-4 h-4" />
            {t.label}
          </button>
        ))}
      </div>

      <AnimatePresence mode="wait">

        {/* ── SCAN TAB ── */}
        {tab === 'scan' && (
          <motion.div key="scan" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>

            {scanPhase === 'scanner' && (
              <div className="space-y-4">
                <div className="text-center mb-2">
                  <h2 className="text-lg font-black text-slate-800">Scan Referral QR</h2>
                  <p className="text-[13px] text-slate-500">Doctor-issued referral QR to book services</p>
                </div>

                {/* Camera */}
                <div className="relative aspect-[4/3] bg-black rounded-3xl overflow-hidden border-2 border-slate-800 shadow-2xl">
                  <video ref={videoRef} className={cn('absolute inset-0 w-full h-full object-cover', camState !== 'active' && 'hidden')} muted playsInline autoPlay />
                  <canvas ref={canvasRef} className="hidden" />

                  {camState === 'active' && (
                    <div className="absolute inset-0 pointer-events-none">
                      <div className="absolute top-8 left-8 w-12 h-12 border-t-4 border-l-4 border-teal-400 rounded-tl-lg" />
                      <div className="absolute top-8 right-8 w-12 h-12 border-t-4 border-r-4 border-teal-400 rounded-tr-lg" />
                      <div className="absolute bottom-8 left-8 w-12 h-12 border-b-4 border-l-4 border-teal-400 rounded-bl-lg" />
                      <div className="absolute bottom-8 right-8 w-12 h-12 border-b-4 border-r-4 border-teal-400 rounded-br-lg" />
                    </div>
                  )}
                  {camState === 'requesting' && (
                    <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-3">
                      <div className="w-8 h-8 border-4 border-teal-400 border-t-transparent rounded-full animate-spin" />
                      <p className="text-slate-300 text-sm font-bold">Starting camera…</p>
                    </div>
                  )}
                  {(camState === 'idle' || camState === 'denied') && (
                    <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-3 px-6 text-center">
                      <QrCode className="w-10 h-10 text-slate-600" />
                      <p className="text-slate-400 text-sm font-medium">
                        {camState === 'denied' ? 'Camera permission denied' : 'Camera not started'}
                      </p>
                      <button onClick={() => start()} className="bg-teal-500 text-white font-bold text-[13px] px-4 py-2 rounded-xl hover:bg-teal-600 transition-colors">
                        {camState === 'denied' ? 'Try Again' : 'Start Camera'}
                      </button>
                    </div>
                  )}
                  {scanning && (
                    <div className="absolute inset-0 bg-black/60 flex flex-col items-center justify-center gap-3">
                      <Loader2 className="w-8 h-8 text-teal-400 animate-spin" />
                      <p className="text-white font-bold text-sm">Fetching referral…</p>
                    </div>
                  )}
                </div>

                {scanError && (
                  <div className="bg-red-50 border border-red-200 rounded-2xl px-4 py-3 text-[13px] text-red-700 font-semibold">
                    ⚠ {scanError}
                  </div>
                )}

                {/* Demo */}
                <div className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
                  <p className="text-[12px] font-black text-slate-600 mb-1">🧪 Demo — No Camera Needed</p>
                  <p className="text-[11px] text-slate-400 mb-3">Simulate scanning a doctor's referral QR instantly</p>
                  <button onClick={handleDemo} disabled={scanning}
                    className="w-full bg-teal-500 hover:bg-teal-600 text-white font-bold text-[13px] py-3 rounded-xl transition-all disabled:opacity-50 flex items-center justify-center gap-2">
                    {scanning ? <Loader2 className="w-4 h-4 animate-spin" /> : <QrCode className="w-4 h-4" />}
                    {scanning ? 'Loading…' : 'Simulate Referral Scan'}
                  </button>
                </div>
              </div>
            )}

            {scanPhase === 'details' && referral && insight && (
              <div className="space-y-4">
                <button onClick={resetScan} className="flex items-center gap-2 text-[13px] font-bold text-slate-500 hover:text-slate-800 transition-colors">
                  <ArrowLeft className="w-4 h-4" /> Back to Scanner
                </button>
                <AIInsights insight={insight} />
                <ReferralDetails
                  referral={referral}
                  onBookLab={referral.type === 'lab' || referral.tests.length > 0 ? () => openBooking('lab') : undefined}
                  onBookHospital={referral.type === 'hospital' ? () => openBooking('hospital') : () => openBooking('hospital')}
                  onBookSpecialist={referral.type === 'specialist' ? () => openBooking('specialist') : undefined}
                />
              </div>
            )}

            {scanPhase === 'ticket' && ticket && (
              <div className="space-y-4">
                <TicketView ticket={ticket} onNewScan={resetScan} />
              </div>
            )}

            {scanPhase === 'booking' && referral && (
              <BookingModal
                bookingType={bookingType}
                providers={providers}
                referralId={referral.id}
                onConfirm={handleBookingConfirm}
                onClose={() => setScanPhase('details')}
              />
            )}
          </motion.div>
        )}

        {/* ── CREATE TAB ── */}
        {tab === 'create' && (
          <motion.div key="create" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
            {!createdReferral ? (
              <div className="space-y-4">
                <div>
                  <h2 className="text-lg font-black text-slate-800">New Referral</h2>
                  <p className="text-[13px] text-slate-500">Fill details to generate a referral QR for your patient</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
                  <ReferralForm onSubmit={handleCreate} onCancel={() => {}} />
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="flex items-center gap-3 bg-emerald-50 border border-emerald-200 rounded-2xl px-4 py-3">
                  <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0" />
                  <div>
                    <p className="text-[13px] font-black text-emerald-800">Referral Created!</p>
                    <p className="text-[11px] text-emerald-600">Share this QR with your patient to book services.</p>
                  </div>
                </div>

                {/* Generated QR */}
                <div className="bg-white rounded-3xl border border-slate-200 shadow-lg p-6 flex flex-col items-center gap-4">
                  <div>
                    <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest text-center mb-1">Referral QR Code</p>
                    <h3 className="text-[15px] font-black text-slate-800 text-center">{createdReferral.patient_name}</h3>
                    <p className="text-[12px] text-slate-500 text-center">{createdReferral.diagnosis.slice(0, 60)}{createdReferral.diagnosis.length > 60 ? '…' : ''}</p>
                  </div>
                  <div className="p-3 bg-white border-2 border-slate-200 rounded-2xl shadow-inner">
                    {qrToken && (
                      <QRCodeSVG
                        value={qrToken}
                        size={180}
                        bgColor="#ffffff"
                        fgColor="#0f172a"
                        level="M"
                      />
                    )}
                  </div>
                  <div className="w-full grid grid-cols-3 gap-2 text-center text-[11px]">
                    <div className="bg-slate-50 rounded-xl p-2">
                      <p className="font-black text-slate-700 capitalize">{createdReferral.type}</p>
                      <p className="text-slate-400">Type</p>
                    </div>
                    <div className="bg-slate-50 rounded-xl p-2">
                      <p className="font-black text-slate-700">{createdReferral.tests.length}</p>
                      <p className="text-slate-400">Tests</p>
                    </div>
                    <div className="bg-slate-50 rounded-xl p-2">
                      <p className="font-black text-slate-700">{createdReferral.medicines.length}</p>
                      <p className="text-slate-400">Medicines</p>
                    </div>
                  </div>
                  <div className="w-full flex gap-2">
                    <button
                      onClick={() => { if (qrToken) navigator.clipboard.writeText(qrToken); }}
                      className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold text-[13px] hover:bg-slate-50 transition-colors">
                      <Share2 className="w-4 h-4" /> Copy Token
                    </button>
                    <button onClick={resetCreate}
                      className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-teal-500 hover:bg-teal-600 text-white font-bold text-[13px] transition-colors">
                      <Plus className="w-4 h-4" /> New Referral
                    </button>
                  </div>
                </div>

                {/* Booking shortcuts */}
                <div className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
                  <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">Quick Book for Patient</p>
                  <div className="grid grid-cols-3 gap-2">
                    {([['lab','Lab Test', FlaskConical,'bg-teal-500'],['hospital','Hospital','Stethoscope','bg-blue-500'],['specialist','Specialist','User','bg-violet-500']] as const).map(([type, label]) => {
                      const icons: Record<string, typeof FlaskConical> = { lab: FlaskConical, hospital: Stethoscope, specialist: User };
                      const Ico = icons[type];
                      const colors: Record<string, string> = { lab: 'bg-teal-500', hospital: 'bg-blue-500', specialist: 'bg-violet-500' };
                      return (
                        <button key={type} onClick={async () => {
                          setReferral(createdReferral);
                          const list = await getProviders(type as BookingType);
                          setProviders(list);
                          setBookingType(type as BookingType);
                          setTab('scan');
                          setScanPhase('booking');
                        }}
                          className={cn('flex flex-col items-center gap-1.5 py-3 rounded-2xl text-white text-[11px] font-bold transition-all hover:opacity-90', colors[type])}>
                          <Ico className="w-5 h-5" />
                          {label}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>
            )}
          </motion.div>
        )}

        {/* ── EARNINGS TAB ── */}
        {tab === 'earnings' && (
          <motion.div key="earnings" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
            <div className="mb-4">
              <h2 className="text-lg font-black text-slate-800">Earnings Dashboard</h2>
              <p className="text-[13px] text-slate-500">Commission earned from patient referrals (10% per booking)</p>
            </div>
            <EarningsDashboard />
          </motion.div>
        )}

      </AnimatePresence>
    </div>
  );
}
