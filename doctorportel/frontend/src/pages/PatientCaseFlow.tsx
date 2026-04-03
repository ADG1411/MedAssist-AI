import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ArrowLeft, ArrowRight, Download, ChevronRight,
  Clock, Activity, AlertCircle, CheckCircle2, Users, Clipboard, Siren,
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { cn } from '../layouts/DashboardLayout';
import { Stepper, STEP_CONFIG } from '../components/caseflow/Stepper';
import { Step1Overview }    from '../components/caseflow/Step1Overview';
import { Step2VisitDetails } from '../components/caseflow/Step2VisitDetails';
import { Step3AIChat }      from '../components/caseflow/Step3AIChat';
import { Step4Consultation } from '../components/caseflow/Step4Consultation';
import { Step5Prescription } from '../components/caseflow/Step5Prescription';
import { Step6Report }      from '../components/caseflow/Step6Report';
import { MOCK_CASES }       from '../types/caseflow';
import type { CaseFlowState, ChatMessage, PrescriptionData } from '../types/caseflow';

/* ── Status badge ──────────────────────────────────────────────────────────── */
const StatusBadge = ({ status }: { status: CaseFlowState['currentStatus'] }) => {
  const map = {
    'Pending':        { bg: 'bg-slate-100 text-slate-600 border-slate-200',    dot: 'bg-slate-400'    },
    'In Review':      { bg: 'bg-amber-50  text-amber-700  border-amber-200',   dot: 'bg-amber-400 animate-pulse' },
    'In Consultation':{ bg: 'bg-blue-50   text-blue-700   border-blue-200',    dot: 'bg-blue-400  animate-pulse' },
    'Completed':      { bg: 'bg-emerald-50 text-emerald-700 border-emerald-200', dot: 'bg-emerald-400' },
  };
  const s = map[status] ?? map['Pending'];
  return (
    <div className={cn('flex items-center gap-1.5 px-2.5 py-1 rounded-full border text-[11px] font-bold', s.bg)}>
      <span className={cn('w-1.5 h-1.5 rounded-full', s.dot)} />
      {status}
    </div>
  );
};

/* ── Case Card (grid list) ──────────────────────────────────────────────────── */
const CaseCard = ({ caseData, onOpen }: { caseData: CaseFlowState; onOpen: () => void }) => {
  const { patient } = caseData;
  const scoreColor  = patient.aiScore >= 76 ? 'text-rose-500' : patient.aiScore >= 41 ? 'text-amber-500' : 'text-emerald-500';

  return (
    <motion.div
      whileHover={{ y: -2 }}
      onClick={onOpen}
      className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md hover:border-slate-300 transition-all cursor-pointer overflow-hidden group"
    >
      {/* Top accent bar */}
      <div className="h-1 w-full" style={{ backgroundColor: patient.avatarColor }} />

      <div className="p-5">
        {/* Header row */}
        <div className="flex items-start justify-between gap-3 mb-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-2xl flex items-center justify-center text-white font-black text-sm shadow-md shrink-0"
              style={{ backgroundColor: patient.avatarColor }}>
              {patient.name.split(' ').map(n => n[0]).join('')}
            </div>
            <div>
              <p className="font-black text-slate-800 text-[14px] leading-tight">{patient.name}</p>
              <p className="text-[11px] font-semibold text-slate-400 mt-0.5">{patient.age} yrs · {patient.gender} · {patient.bloodGroup}</p>
            </div>
          </div>
          <StatusBadge status={caseData.currentStatus} />
        </div>

        {/* Procedure */}
        <div className="bg-slate-50 rounded-xl px-3 py-2.5 mb-3">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">Procedure</p>
          <p className="text-[12px] font-bold text-slate-700 leading-tight">{patient.procedure}</p>
        </div>

        {/* Stats row */}
        <div className="flex items-center justify-between text-[11px]">
          <span className="text-slate-400 font-medium">{patient.reqId}</span>
          <div className="flex items-center gap-3">
            <span className="font-bold text-slate-500">{patient.urgency}</span>
            <span className={cn('font-black', scoreColor)}>⚡ {patient.aiScore}</span>
          </div>
        </div>

        {/* Open chevron */}
        <div className="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
          <span className="text-[11px] font-bold text-slate-400">₹{(patient.costMin / 1000).toFixed(0)}k – {(patient.costMax / 1000).toFixed(0)}k</span>
          <div className="flex items-center gap-1 text-[11px] font-bold text-teal-600 group-hover:gap-2 transition-all">
            Open Workflow <ChevronRight className="w-3.5 h-3.5" />
          </div>
        </div>
      </div>
    </motion.div>
  );
};

/* ── Cases grid list ──────────────────────────────────────────────────────── */
const CasesGrid = ({ onSelect }: { onSelect: (c: CaseFlowState) => void }) => {
  const navigate = useNavigate();
  const stats = [
    { label: 'Total Cases',    value: MOCK_CASES.length,                                        icon: Users,        color: 'text-blue-600',    bg: 'bg-blue-50'    },
    { label: 'In Review',      value: MOCK_CASES.filter(c => c.currentStatus === 'In Review').length,      icon: Clock,        color: 'text-amber-600',   bg: 'bg-amber-50'   },
    { label: 'Consultation',   value: MOCK_CASES.filter(c => c.currentStatus === 'In Consultation').length, icon: Activity,     color: 'text-blue-600',    bg: 'bg-blue-50'    },
    { label: 'High Risk',      value: MOCK_CASES.filter(c => c.patient.aiScore >= 76).length,   icon: AlertCircle,  color: 'text-rose-500',    bg: 'bg-rose-50'    },
  ];

  return (
    <div className="max-w-[1400px] mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20 md:pb-6">

      {/* Page header */}
      <div className="flex items-start justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-800 tracking-tight">Case Workflow</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Select a patient case to begin the step-by-step workflow</p>
        </div>
        <button
          onClick={() => navigate('/dashboard/sos')}
          className="flex items-center gap-2 bg-red-500 hover:bg-red-600 active:scale-95 text-white font-black text-[13px] px-4 py-2.5 rounded-2xl transition-all shadow-lg shadow-red-500/30 shrink-0 animate-pulse hover:animate-none"
        >
          <Siren className="w-4 h-4" />
          SOS
        </button>
      </div>

      {/* Stats bar */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-8">
        {stats.map(({ label, value, icon: Icon, color, bg }) => (
          <div key={label} className={cn('rounded-2xl p-3 sm:p-4 border flex items-center gap-3', bg, 'border-slate-200/60')}>
            <div className={cn('w-9 h-9 sm:w-10 sm:h-10 rounded-xl flex items-center justify-center shrink-0 bg-white shadow-sm', color)}>
              <Icon className="w-4 h-4 sm:w-5 sm:h-5" />
            </div>
            <div>
              <p className="text-xl sm:text-2xl font-black text-slate-800 leading-none">{value}</p>
              <p className="text-[11px] sm:text-[12px] font-semibold text-slate-500 mt-0.5">{label}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Cases grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {MOCK_CASES.map(c => (
          <CaseCard key={c.patient.id} caseData={c} onOpen={() => onSelect(c)} />
        ))}
      </div>
    </div>
  );
};

/* ── Workflow view ──────────────────────────────────────────────────────────── */
const WorkflowView = ({
  caseData, currentStep, completedSteps,
  onStepClick, onBack, onNext, onClose, onSave,
  onVisitChange, onRxChange, onChatChange,
}: {
  caseData: CaseFlowState;
  currentStep: number;
  completedSteps: number[];
  onStepClick: (s: number) => void;
  onBack: () => void;
  onNext: () => void;
  onClose: () => void;
  onSave: () => void;
  onVisitChange: (v: CaseFlowState['visit']) => void;
  onRxChange: (rx: PrescriptionData) => void;
  onChatChange: (msgs: ChatMessage[]) => void;
}) => {
  const isFirst = currentStep === 0;
  const isLast  = currentStep === STEP_CONFIG.length - 1;

  return (
    <div className="max-w-[1100px] mx-auto pb-20 md:pb-6 animate-in fade-in duration-300">

      {/* ── Top bar ── */}
      <div className="flex items-center gap-3 mb-5 flex-wrap">
        <button onClick={onClose}
          className="flex items-center gap-1.5 text-[13px] font-bold text-slate-600 hover:text-slate-800 bg-white border border-slate-200 hover:border-slate-300 px-3 py-2 rounded-xl transition-all shadow-sm shrink-0">
          <ArrowLeft className="w-4 h-4" /> All Cases
        </button>

        {/* Patient pill */}
        <div className="flex items-center gap-2 bg-white border border-slate-200 px-3 py-2 rounded-xl shadow-sm min-w-0">
          <div className="w-6 h-6 rounded-lg flex items-center justify-center text-white font-black text-[10px] shrink-0"
            style={{ backgroundColor: caseData.patient.avatarColor }}>
            {caseData.patient.name.split(' ').map(n => n[0]).join('')}
          </div>
          <p className="font-black text-slate-800 text-[13px] truncate">{caseData.patient.name}</p>
          <span className="text-slate-300">·</span>
          <p className="text-[11px] font-semibold text-slate-400 shrink-0">{caseData.patient.reqId}</p>
        </div>

        <div className="ml-auto shrink-0">
          <StatusBadge status={caseData.currentStatus} />
        </div>
      </div>

      {/* ── Stepper ── */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm px-4 sm:px-6 py-4 mb-5">
        <Stepper currentStep={currentStep} completedSteps={completedSteps} onStepClick={onStepClick} />
      </div>

      {/* ── Step content — fixed height, internally scrollable ── */}
      <div className="h-[calc(100vh-280px)] min-h-[480px] overflow-y-auto custom-scrollbar rounded-2xl">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentStep}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className="pb-4"
          >
            {currentStep === 0 && <Step1Overview data={caseData} />}
            {currentStep === 1 && <Step2VisitDetails data={caseData} onChange={onVisitChange} />}
            {currentStep === 2 && <Step3AIChat data={caseData} onMessagesChange={onChatChange} />}
            {currentStep === 3 && <Step4Consultation data={caseData} />}
            {currentStep === 4 && <Step5Prescription data={caseData} onChange={onRxChange} />}
            {currentStep === 5 && <Step6Report data={caseData} onSave={onSave} />}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* ── Footer navigation ── */}
      <div className="fixed bottom-0 left-0 right-0 md:relative md:bottom-auto md:left-auto md:right-auto bg-white/90 md:bg-transparent backdrop-blur-xl md:backdrop-blur-none border-t border-slate-200/60 md:border-0 px-4 py-3 md:px-0 md:py-0 md:mt-5 z-30">
        <div className="max-w-[1100px] mx-auto flex items-center justify-between gap-3">

          {/* Left: status indicator */}
          <div className="hidden sm:flex items-center gap-2 text-[12px] font-bold text-slate-500">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
            {caseData.currentStatus}
          </div>

          {/* Right: nav buttons */}
          <div className="flex items-center gap-3 ml-auto w-full sm:w-auto">
            {!isFirst && (
              <button onClick={onBack}
                className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold text-[13px] px-5 py-2.5 rounded-xl transition-all shadow-sm">
                <ArrowLeft className="w-4 h-4" /> Back
              </button>
            )}

            {!isLast ? (
              <button onClick={onNext}
                className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-slate-900 hover:bg-slate-800 text-white font-bold text-[13px] px-6 py-2.5 rounded-xl transition-all active:scale-[0.98] shadow-lg">
                Next Step <ArrowRight className="w-4 h-4" />
              </button>
            ) : (
              <div className="flex items-center gap-2 flex-1 sm:flex-none">
                <button onClick={onSave}
                  className="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-teal-500 hover:bg-teal-600 text-white font-bold text-[13px] px-5 py-2.5 rounded-xl transition-all active:scale-[0.98] shadow-lg shadow-teal-500/25">
                  <CheckCircle2 className="w-4 h-4" /> Complete Case
                </button>
                <button
                  className="flex items-center gap-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold text-[13px] px-4 py-2.5 rounded-xl transition-all shadow-sm">
                  <Download className="w-4 h-4" />
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

/* ── Main Page ──────────────────────────────────────────────────────────────── */
export default function PatientCaseFlow() {
  const [activeCaseIndex, setActiveCaseIndex]   = useState<number | null>(null);
  const [cases, setCases]                        = useState<CaseFlowState[]>(MOCK_CASES);
  const [currentStep, setCurrentStep]            = useState(0);
  const [completedSteps, setCompletedSteps]      = useState<number[]>([]);

  const activeCase = activeCaseIndex !== null ? cases[activeCaseIndex] : null;

  const openCase = (caseData: CaseFlowState) => {
    const idx = cases.findIndex(c => c.patient.id === caseData.patient.id);
    setActiveCaseIndex(idx);
    setCurrentStep(0);
    setCompletedSteps([]);
  };

  const closeCase = () => {
    setActiveCaseIndex(null);
    setCurrentStep(0);
    setCompletedSteps([]);
  };

  const updateCase = (patch: Partial<CaseFlowState>) => {
    if (activeCaseIndex === null) return;
    setCases(prev => prev.map((c, i) => i === activeCaseIndex ? { ...c, ...patch } : c));
  };

  const goNext = () => {
    setCompletedSteps(prev => prev.includes(currentStep) ? prev : [...prev, currentStep]);
    if (currentStep < STEP_CONFIG.length - 1) {
      setCurrentStep(s => s + 1);
      // Update status based on step
      if (currentStep === 1) updateCase({ currentStatus: 'In Consultation' });
    }
  };

  const goBack = () => {
    if (currentStep > 0) setCurrentStep(s => s - 1);
  };

  const handleSave = () => {
    updateCase({ currentStatus: 'Completed' });
    setCompletedSteps(Array.from({ length: STEP_CONFIG.length }, (_, i) => i));
  };

  const handleStepClick = (step: number) => {
    if (completedSteps.includes(step) || step === currentStep || step <= Math.max(...completedSteps, 0)) {
      setCurrentStep(step);
    }
  };

  if (!activeCase) {
    return <CasesGrid onSelect={openCase} />;
  }

  return (
    <WorkflowView
      caseData={activeCase}
      currentStep={currentStep}
      completedSteps={completedSteps}
      onStepClick={handleStepClick}
      onBack={goBack}
      onNext={goNext}
      onClose={closeCase}
      onSave={handleSave}
      onVisitChange={visit => updateCase({ visit })}
      onRxChange={prescription => updateCase({ prescription })}
      onChatChange={chatMessages => updateCase({ chatMessages })}
    />
  );
}

// Sidebar icon export for DashboardLayout
export { Clipboard as CaseFlowIcon };
