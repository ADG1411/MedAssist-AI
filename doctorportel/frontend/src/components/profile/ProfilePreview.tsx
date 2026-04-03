import { X, Star, MapPin, Clock, BadgeCheck, Stethoscope, GraduationCap, Languages, Phone, Calendar } from 'lucide-react';
import type { DoctorProfile } from '../../services/profileService';

interface ProfilePreviewProps {
  profile: DoctorProfile;
  bio: string;
  onClose: () => void;
}

export const ProfilePreview = ({ profile, bio, onClose }: ProfilePreviewProps) => {
  const name   = profile.full_name || 'Dr. Name';
  const spec   = profile.specialization || 'Specialist';
  const exp    = profile.experience_years ?? 0;
  const rating = profile.rating ?? 4.8;
  const loc    = profile.location || 'Location not specified';
  const langs  = profile.languages || 'English';
  const avatar = profile.avatar || `https://i.pravatar.cc/150?u=${name}`;
  const stats  = profile.stats;

  return (
    /* Backdrop */
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={e => { if (e.target === e.currentTarget) onClose(); }}
    >
      <div className="relative w-full max-w-md bg-white rounded-3xl shadow-2xl overflow-hidden animate-in slide-in-from-bottom-4 duration-300 max-h-[90vh] flex flex-col">
        {/* Close */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 w-8 h-8 bg-white/80 hover:bg-white rounded-full flex items-center justify-center shadow-sm text-slate-500 hover:text-slate-800 transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Banner */}
        <div className="h-28 bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-600 shrink-0" />

        {/* Scrollable content */}
        <div className="flex-1 overflow-y-auto">
          {/* Profile top section */}
          <div className="px-6 pb-4 -mt-12">
            <div className="flex items-end gap-4 mb-4">
              <img
                src={avatar}
                alt={name}
                className="w-20 h-20 rounded-2xl border-4 border-white shadow-lg object-cover shrink-0"
              />
              <div className="mb-1">
                <div className="flex items-center gap-1.5">
                  <h2 className="text-lg font-black text-slate-800">{name}</h2>
                  <BadgeCheck className="w-5 h-5 text-blue-500" />
                </div>
                <p className="text-sm text-indigo-600 font-semibold">{spec}</p>
              </div>
            </div>

            {/* Pill badges */}
            <div className="flex flex-wrap gap-2 mb-4">
              <span className="flex items-center gap-1 bg-blue-50 text-blue-700 border border-blue-200 px-3 py-1 rounded-full text-xs font-bold">
                <Clock className="w-3 h-3" /> {exp}+ yrs exp
              </span>
              <span className="flex items-center gap-1 bg-amber-50 text-amber-700 border border-amber-200 px-3 py-1 rounded-full text-xs font-bold">
                <Star className="w-3 h-3 fill-amber-400 text-amber-400" /> {rating}
              </span>
              {stats?.success_rate && (
                <span className="flex items-center gap-1 bg-emerald-50 text-emerald-700 border border-emerald-200 px-3 py-1 rounded-full text-xs font-bold">
                  ✓ {stats.success_rate} success
                </span>
              )}
            </div>

            {/* Stats row */}
            {stats && (
              <div className="grid grid-cols-3 gap-3 mb-4">
                {[
                  { label: 'Patients', value: stats.total_patients?.toLocaleString() },
                  { label: 'Consultations', value: stats.consultations },
                  { label: 'Success Rate', value: stats.success_rate },
                ].map(s => (
                  <div key={s.label} className="bg-slate-50 rounded-xl p-2.5 text-center border border-slate-100">
                    <p className="text-base font-black text-slate-800">{s.value || '—'}</p>
                    <p className="text-[10px] text-slate-500 font-medium mt-0.5">{s.label}</p>
                  </div>
                ))}
              </div>
            )}

            {/* Bio */}
            <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-2xl p-4 border border-indigo-100 mb-4">
              <div className="flex items-center gap-2 mb-2">
                <Stethoscope className="w-4 h-4 text-indigo-500" />
                <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wide">About</h3>
              </div>
              <p className="text-sm text-slate-600 leading-relaxed">
                {bio || 'No bio added yet.'}
              </p>
            </div>

            {/* Info grid */}
            <div className="space-y-2.5 mb-4">
              {[
                { icon: MapPin,       text: loc,   label: 'Location' },
                { icon: Languages,    text: langs, label: 'Languages' },
                { icon: GraduationCap, text: `${exp} years of clinical practice`, label: 'Experience' },
              ].map(({ icon: Icon, text, label }) => (
                <div key={label} className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center shrink-0">
                    <Icon className="w-4 h-4 text-slate-500" />
                  </div>
                  <div>
                    <p className="text-[10px] font-semibold text-slate-400 uppercase tracking-wide">{label}</p>
                    <p className="text-sm text-slate-700 font-medium">{text}</p>
                  </div>
                </div>
              ))}
            </div>

            {/* CTA buttons (visual only, patient facing) */}
            <div className="grid grid-cols-2 gap-3 pb-2">
              <button className="flex items-center justify-center gap-2 bg-brand-blue text-white py-2.5 rounded-xl text-sm font-bold hover:bg-blue-700 transition-colors shadow-sm">
                <Calendar className="w-4 h-4" /> Book Appointment
              </button>
              <button className="flex items-center justify-center gap-2 bg-slate-100 text-slate-700 py-2.5 rounded-xl text-sm font-bold hover:bg-slate-200 transition-colors">
                <Phone className="w-4 h-4" /> Contact
              </button>
            </div>
          </div>
        </div>

        {/* Footer label */}
        <div className="px-6 py-3 bg-slate-50 border-t border-slate-100 shrink-0">
          <p className="text-center text-xs text-slate-400 font-medium">
            👁 This is how patients see your profile
          </p>
        </div>
      </div>
    </div>
  );
};
