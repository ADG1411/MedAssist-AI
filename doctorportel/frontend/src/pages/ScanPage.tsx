import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { QRCodeSVG } from 'qrcode.react';
import {
  QrCode, Plus, ArrowLeft, CheckCircle2, ExternalLink,
  FlaskConical, Stethoscope, User, Share2,
} from 'lucide-react';
import { cn } from '../layouts/DashboardLayout';
import { PatientPreview }   from '../components/medcard/PatientPreview';
import { PatientDashboard } from '../components/medcard/PatientDashboard';
import { scanQR, accessFullRecord } from '../services/medcardService';
import type { QRPreview, FullRecord } from '../services/medcardService';
import { AIInsights }      from '../components/referral/AIInsights';
import { ReferralDetails } from '../components/referral/ReferralDetails';
import { ReferralForm }    from '../components/referral/ReferralForm';
import { BookingModal }    from '../components/referral/BookingModal';
import { TicketView }      from '../components/referral/TicketView';
import { QRScanner }       from '../components/medcard/QRScanner';
import { useNavigate }     from 'react-router-dom';
import {
  createReferral, generateReferralQR, scanReferralQR,
  getProviders, createBooking
} from '../services/referralService';
import type {
  Referral, AIInsight, Provider, Ticket,
  BookingType, CreateReferralPayload,
} from '../types/referral';

// ─── Tabs ────────────────────────────────────────────────────────────────────
type Tab = 'scan' | 'create';

// Hook removed as we now use the unified QRScanner component

// ─── Main Page ─────────────────────────────────────────────────────────────────
export default function ScanPage() {
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('scan');

  // Universal Scan Flow State
  const [activeFlow, setActiveFlow] = useState<'none' | 'medcard' | 'referral'>('none');

  // MedCard Flow State
  const [medcardToken, setMedcardToken] = useState('');
  const [medcardPreview, setMedcardPreview] = useState<QRPreview | null>(null);
  const [medcardRecord, setMedcardRecord]   = useState<FullRecord | null>(null);
  const [isEmergency, setIsEmergency]       = useState(false);
  const [accessingRecord, setAccessingRecord] = useState(false);

  // Referral Flow State
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

    if (token.startsWith('MEDCARD::')) {
      setActiveFlow('medcard');
      setMedcardToken(token);
      try {
        const data = await scanQR(token);
        setMedcardPreview(data);
        setScanPhase('details');
      } catch (e: any) {
        setScanError(e.message ?? 'QR scan failed. Token may be expired or invalid.');
        setActiveFlow('none');
      } finally {
        setScanning(false);
      }
      return;
    }

    // Default to referral
    setActiveFlow('referral');
    setQrToken(token);
    try {
      const { referral: r, ai_insight } = await scanReferralQR(token);
      setReferral(r);
      setInsight(ai_insight);
      setScanPhase('details');
    } catch (e: any) {
      setScanError(e.message ?? 'Invalid or expired referral QR.');
      setActiveFlow('none');
    } finally {
      setScanning(false);
    }
  };

  const handleMedCardAccess = async (emergency = false) => {
    if (!medcardToken) return;
    setScanError(null);
    setAccessingRecord(true);
    setIsEmergency(emergency);
    try {
      const data = await accessFullRecord(medcardToken, emergency);
      setMedcardRecord(data);
      setScanPhase('dashboard' as any); // hack to show dashboard
    } catch (e: any) {
      setScanError(e.message ?? 'Access denied. Please re-authenticate.');
    } finally {
      setAccessingRecord(false);
    }
  };


  // Note: we let QRScanner manage its own camera lifecycle now.

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
    setActiveFlow('none');
    setReferral(null);
    setInsight(null);
    setTicket(null);
    setScanError(null);
    setMedcardPreview(null);
    setMedcardRecord(null);
    setMedcardToken('');
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
                  <h2 className="text-lg font-black text-slate-800">Global QR Scanner</h2>
                  <p className="text-[13px] text-slate-500">Scan Patient MedCards or Doctor Referrals seamlessly</p>
                </div>

                <QRScanner onScan={handleScan} scanning={scanning} error={scanError} modeContext="universal" />
              </div>
            )}

            {/* MedCard Renderer */}
            {activeFlow === 'medcard' && scanPhase === 'details' && medcardPreview && (
              <div className="space-y-4">
                <button onClick={resetScan} className="flex items-center gap-2 text-[13px] font-bold text-slate-500 hover:text-slate-800 transition-colors">
                  <ArrowLeft className="w-4 h-4" /> Back to Scanner
                </button>
                <div className="bg-white rounded-2xl border border-slate-200 border-l-4 border-l-blue-500 p-4 shadow-sm mb-4">
                   <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400 mb-0.5">Detected Token Type</p>
                   <p className="text-[14px] font-black text-slate-800">Patient MedCard</p>
                </div>
                <PatientPreview
                  preview={medcardPreview}
                  onAccess={() => handleMedCardAccess(false)}
                  onEmergency={() => handleMedCardAccess(true)}
                  loading={accessingRecord}
                />
              </div>
            )}

            {/* MedCard Dashboard */}
            {activeFlow === 'medcard' && (scanPhase as any) === 'dashboard' && medcardRecord && (
              <div className="space-y-4">
                <button onClick={resetScan} className="flex items-center gap-2 text-[13px] font-bold text-slate-500 hover:text-slate-800 transition-colors">
                  <ArrowLeft className="w-4 h-4" /> Scan Another Patient
                </button>
                <div className="flex items-center justify-between gap-3 bg-white border border-slate-200 rounded-2xl px-5 py-4 shadow-sm mb-4">
                  <div>
                    <p className="font-black text-slate-800 text-[13px]">Full Record &amp; PDF</p>
                    <p className="text-[11px] font-medium text-slate-400">Open printable view · download as PDF</p>
                  </div>
                  <button
                    onClick={() => navigate(`/dashboard/medcard/record/${medcardRecord.patient.id}`)}
                    className="flex items-center gap-2 bg-teal-500 hover:bg-teal-600 text-white font-bold text-[12px] px-4 py-2 rounded-xl transition-all shrink-0">
                    <ExternalLink className="w-3.5 h-3.5" /> Open PDF
                  </button>
                </div>
                <PatientDashboard
                  record={medcardRecord}
                  isEmergency={isEmergency}
                  onNewScan={resetScan}
                />
              </div>
            )}

            {/* Referral Renderer */}
            {activeFlow === 'referral' && scanPhase === 'details' && referral && insight && (
              <div className="space-y-4">
                <button onClick={resetScan} className="flex items-center gap-2 text-[13px] font-bold text-slate-500 hover:text-slate-800 transition-colors">
                  <ArrowLeft className="w-4 h-4" /> Back to Scanner
                </button>
                <div className="bg-white rounded-2xl border border-slate-200 border-l-4 border-l-teal-500 p-4 shadow-sm mb-4">
                   <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400 mb-0.5">Detected Token Type</p>
                   <p className="text-[14px] font-black text-slate-800">Clinical Referral</p>
                </div>
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

      </AnimatePresence>
    </div>
  );
}
