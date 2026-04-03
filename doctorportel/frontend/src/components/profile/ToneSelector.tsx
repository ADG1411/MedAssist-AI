import type { ElementType } from 'react';
import { Briefcase, Smile, AlignLeft, BookOpen, Globe } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

export type Tone = 'professional' | 'friendly' | 'short' | 'detailed';
export type Language = 'english' | 'hindi';

const TONES: { value: Tone; label: string; icon: ElementType; color: string }[] = [
  { value: 'professional', label: 'Professional', icon: Briefcase,  color: 'bg-blue-50 text-blue-700 border-blue-200 hover:border-blue-400' },
  { value: 'friendly',     label: 'Friendly',     icon: Smile,      color: 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:border-emerald-400' },
  { value: 'short',        label: 'Short',        icon: AlignLeft,  color: 'bg-amber-50 text-amber-700 border-amber-200 hover:border-amber-400' },
  { value: 'detailed',     label: 'Detailed',     icon: BookOpen,   color: 'bg-purple-50 text-purple-700 border-purple-200 hover:border-purple-400' },
];

const LANGS: { value: Language; flag: string; label: string }[] = [
  { value: 'english', flag: '🇺🇸', label: 'English' },
  { value: 'hindi',   flag: '🇮🇳', label: 'Hindi'   },
];

interface ToneSelectorProps {
  tone: Tone;
  language: Language;
  onToneChange: (t: Tone) => void;
  onLanguageChange: (l: Language) => void;
}

export const ToneSelector = ({ tone, language, onToneChange, onLanguageChange }: ToneSelectorProps) => {
  return (
    <div className="flex flex-col gap-3 p-4 bg-slate-50 rounded-xl border border-slate-200">
      {/* Tone pills */}
      <div className="flex items-center gap-2 flex-wrap">
        <span className="text-xs font-semibold text-slate-500 uppercase tracking-wide mr-1 shrink-0">Tone:</span>
        {TONES.map(({ value, label, icon: Icon, color }) => (
          <button
            key={value}
            onClick={() => onToneChange(value)}
            className={cn(
              'flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold border transition-all duration-150',
              tone === value
                ? cn(color, 'ring-2 ring-offset-1 ring-current/30 shadow-sm')
                : 'bg-white text-slate-500 border-slate-200 hover:text-slate-700',
            )}
          >
            <Icon className="w-3.5 h-3.5" />
            {label}
          </button>
        ))}
      </div>

      {/* Language selector */}
      <div className="flex items-center gap-2">
        <Globe className="w-3.5 h-3.5 text-slate-400 shrink-0" />
        <span className="text-xs font-semibold text-slate-500 uppercase tracking-wide shrink-0">Language:</span>
        <div className="flex gap-2">
          {LANGS.map(({ value, flag, label }) => (
            <button
              key={value}
              onClick={() => onLanguageChange(value)}
              className={cn(
                'flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold border transition-all duration-150',
                language === value
                  ? 'bg-indigo-50 text-indigo-700 border-indigo-300 ring-2 ring-offset-1 ring-indigo-300/40'
                  : 'bg-white text-slate-500 border-slate-200 hover:text-slate-700',
              )}
            >
              <span>{flag}</span>
              {label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
