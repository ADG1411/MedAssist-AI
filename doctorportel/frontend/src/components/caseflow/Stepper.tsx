import React from 'react';
import { Check, User, Calendar, Bot, Video, Pill, FileText } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

export const STEP_CONFIG = [
  { id: 0, label: 'Patient Overview', shortLabel: 'Overview', icon: User },
  { id: 1, label: 'Visit Details',    shortLabel: 'Visit',    icon: Calendar },
  { id: 2, label: 'AI Assistant',     shortLabel: 'AI',       icon: Bot },
  { id: 3, label: 'Consultation',     shortLabel: 'Consult',  icon: Video },
  { id: 4, label: 'Prescription',     shortLabel: 'Rx',       icon: Pill },
  { id: 5, label: 'Final Report',     shortLabel: 'Report',   icon: FileText },
];

interface StepperProps {
  currentStep: number;
  completedSteps: number[];
  onStepClick: (step: number) => void;
}

export const Stepper = ({ currentStep, completedSteps, onStepClick }: StepperProps) => {
  return (
    <div className="w-full">
      {/* ── Desktop stepper ── */}
      <div className="hidden md:flex items-center w-full">
        {STEP_CONFIG.map((step, index) => {
          const isActive    = currentStep === index;
          const isCompleted = completedSteps.includes(index);
          const Icon        = step.icon;

          return (
            <React.Fragment key={step.id}>
              <button
                onClick={() => onStepClick(index)}
                className={cn(
                  'flex flex-col items-center gap-1.5 group relative z-10 shrink-0',
                  isActive || isCompleted ? 'opacity-100' : 'opacity-50 hover:opacity-75'
                )}
              >
                <div className={cn(
                  'w-10 h-10 rounded-full flex items-center justify-center border-2 transition-all duration-300',
                  isCompleted
                    ? 'bg-teal-500 border-teal-500 text-white shadow-lg shadow-teal-500/30'
                    : isActive
                    ? 'bg-white border-teal-500 text-teal-600 shadow-md'
                    : 'bg-white border-slate-200 text-slate-400'
                )}>
                  {isCompleted
                    ? <Check className="w-4 h-4" />
                    : <Icon className="w-4 h-4" />
                  }
                </div>
                <span className={cn(
                  'text-[11px] font-bold whitespace-nowrap',
                  isActive ? 'text-teal-600' : isCompleted ? 'text-teal-500' : 'text-slate-400'
                )}>
                  {step.label}
                </span>
              </button>

              {index < STEP_CONFIG.length - 1 && (
                <div className="flex-1 h-0.5 mx-2 mb-5 rounded-full transition-all duration-500"
                  style={{ background: completedSteps.includes(index) ? '#14b8a6' : '#e2e8f0' }}
                />
              )}
            </React.Fragment>
          );
        })}
      </div>

      {/* ── Mobile: horizontal pill tabs ── */}
      <div className="md:hidden flex items-center gap-2 overflow-x-auto hide-scrollbar pb-1">
        {STEP_CONFIG.map((step, index) => {
          const isActive    = currentStep === index;
          const isCompleted = completedSteps.includes(index);
          const Icon        = step.icon;

          return (
            <button
              key={step.id}
              onClick={() => onStepClick(index)}
              className={cn(
                'flex items-center gap-1.5 px-3 py-2 rounded-xl text-[11px] font-bold whitespace-nowrap border shrink-0 transition-all',
                isCompleted ? 'bg-teal-500 text-white border-teal-500 shadow-sm'
                : isActive   ? 'bg-white text-teal-600 border-teal-500 shadow-sm'
                : 'bg-white text-slate-400 border-slate-200'
              )}
            >
              {isCompleted
                ? <Check className="w-3 h-3" />
                : <Icon  className="w-3 h-3" />
              }
              {step.shortLabel}
            </button>
          );
        })}
      </div>
    </div>
  );
};
