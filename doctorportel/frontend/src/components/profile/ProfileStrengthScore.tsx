import { TrendingUp, AlertCircle, CheckCircle2, ChevronRight } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { DoctorProfile } from '../../services/profileService';

interface ProfileStrengthScoreProps {
  profile: DoctorProfile;
  onSuggestionClick?: (field: string) => void;
}

interface ScoreItem {
  label: string;
  field: string;
  points: number;
  done: boolean;
  tip: string;
}

function computeScore(profile: DoctorProfile): { items: ScoreItem[]; total: number } {
  const items: ScoreItem[] = [
    {
      label: 'Full Name',
      field: 'name',
      points: 10,
      done: Boolean(profile.full_name?.trim()),
      tip: 'Add your full name',
    },
    {
      label: 'Email',
      field: 'email',
      points: 10,
      done: Boolean(profile.email?.trim()),
      tip: 'Add your email address',
    },
    {
      label: 'Specialization',
      field: 'specialization',
      points: 15,
      done: Boolean(profile.specialization?.trim()),
      tip: 'Add your medical specialization',
    },
    {
      label: 'Experience',
      field: 'experience',
      points: 15,
      done: (profile.experience_years ?? 0) > 0,
      tip: 'Add years of experience',
    },
    {
      label: 'Professional Bio',
      field: 'bio',
      points: 20,
      done: (profile.bio?.trim().length ?? 0) > 50,
      tip: 'Write a professional bio (50+ characters)',
    },
    {
      label: 'Languages',
      field: 'languages',
      points: 10,
      done: Boolean(profile.languages?.trim()),
      tip: 'Add languages you speak',
    },
    {
      label: 'Location',
      field: 'location',
      points: 10,
      done: Boolean(profile.location?.trim()),
      tip: 'Add your clinic/hospital location',
    },
    {
      label: 'Phone Number',
      field: 'phone',
      points: 10,
      done: Boolean(profile.phone_number?.trim()),
      tip: 'Add contact number',
    },
  ];

  const total = items.filter(i => i.done).reduce((acc, i) => acc + i.points, 0);
  return { items, total };
}

function scoreColor(score: number) {
  if (score >= 80) return { bar: 'from-emerald-400 to-teal-500', text: 'text-emerald-600', bg: 'bg-emerald-50 border-emerald-200' };
  if (score >= 50) return { bar: 'from-amber-400 to-orange-400', text: 'text-amber-600', bg: 'bg-amber-50 border-amber-200' };
  return { bar: 'from-red-400 to-rose-500', text: 'text-red-600', bg: 'bg-red-50 border-red-200' };
}

export const ProfileStrengthScore = ({ profile, onSuggestionClick }: ProfileStrengthScoreProps) => {
  const { items, total } = computeScore(profile);
  const colors = scoreColor(total);
  const missing = items.filter(i => !i.done).slice(0, 3);

  return (
    <div className={cn('rounded-2xl border p-5 shadow-sm', colors.bg)}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <div className={cn('w-8 h-8 rounded-full flex items-center justify-center', colors.text, 'bg-white shadow-sm border border-current/20')}>
            <TrendingUp className="w-4 h-4" />
          </div>
          <h3 className="font-bold text-slate-800 text-sm">Profile Strength</h3>
        </div>
        <span className={cn('text-2xl font-black', colors.text)}>{total}%</span>
      </div>

      {/* Progress bar */}
      <div className="h-2.5 bg-white/70 rounded-full overflow-hidden mb-4 shadow-inner">
        <div
          className={cn('h-full rounded-full bg-gradient-to-r transition-all duration-700', colors.bar)}
          style={{ width: `${total}%` }}
        />
      </div>

      {/* Score label */}
      <p className={cn('text-xs font-semibold mb-4', colors.text)}>
        {total >= 80 ? '🎉 Excellent! Your profile is highly visible.' :
         total >= 50 ? '🔥 Good progress — a few tweaks will boost visibility.' :
         '⚠️ Complete your profile to attract more patients.'}
      </p>

      {/* Missing suggestions */}
      {missing.length > 0 && (
        <div className="space-y-2">
          <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wide">Suggestions</p>
          {missing.map(item => (
            <button
              key={item.field}
              onClick={() => onSuggestionClick?.(item.field)}
              className="w-full flex items-center gap-2 bg-white/80 hover:bg-white border border-white/50 hover:border-slate-200 rounded-xl px-3 py-2 text-left transition-all group shadow-sm"
            >
              <AlertCircle className="w-3.5 h-3.5 text-amber-500 shrink-0" />
              <span className="text-xs text-slate-600 font-medium flex-1">{item.tip}</span>
              <ChevronRight className="w-3 h-3 text-slate-300 group-hover:text-slate-500 transition-colors shrink-0" />
            </button>
          ))}
        </div>
      )}

      {/* Completed */}
      {total === 100 && (
        <div className="flex items-center gap-2 text-emerald-600">
          <CheckCircle2 className="w-4 h-4" />
          <span className="text-xs font-bold">All fields complete!</span>
        </div>
      )}
    </div>
  );
};
