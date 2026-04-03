import { useState } from 'react';
import { MapPin, Check, Loader2, Eye } from 'lucide-react';
import { profileService } from '../../services/profileService';
import type { DoctorProfile } from '../../services/profileService';
import { aiProfileService } from '../../services/aiProfileService';
import type { Language, Tone } from './ToneSelector';
import { DoctorIdCard } from './DoctorIdCard';
import { AISuggestButton } from './AISuggestButton';
import { ToneSelector } from './ToneSelector';
import { GeneratedBioBox } from './GeneratedBioBox';
import { ProfileStrengthScore } from './ProfileStrengthScore';
import { ProfilePreview } from './ProfilePreview';

interface OverviewTabProps {
  profile: DoctorProfile;
}

export const OverviewTab = ({ profile }: OverviewTabProps) => {
  // ── Core bio state ──────────────────────────────────────────────────────────
  const [bio, setBio]           = useState(profile.bio || '');
  const [languages, setLanguages] = useState(profile.languages || '');
  const [saving, setSaving]     = useState(false);
  const [statusMsg, setStatusMsg] = useState<{ type: 'error' | 'success'; text: string } | null>(null);

  // ── AI Suggest state ────────────────────────────────────────────────────────
  const [showAIPanel, setShowAIPanel] = useState(false);
  const [generating, setGenerating]   = useState(false);
  const [generatedBio, setGeneratedBio] = useState('');
  const [isStreaming, setIsStreaming]  = useState(false);
  const [tone, setTone]               = useState<Tone>('professional');
  const [language, setLanguage]       = useState<Language>('english');

  // ── Preview state ───────────────────────────────────────────────────────────
  const [showPreview, setShowPreview] = useState(false);

  // ── Helpers ─────────────────────────────────────────────────────────────────

  const buildBioRequest = () => ({
    name:             profile.full_name || 'The Doctor',
    degree:           (profile as any).degree || '',
    specialization:   profile.specialization || '',
    experience_years: profile.experience_years ?? 0,
    success_rate:     profile.stats?.success_rate || '',
    hospital:         profile.location || '',
    role:             (profile as any).role || 'Consultant',
    skills:           [] as string[],
    tone,
    language,
  });

  const handleAISuggest = async () => {
    setShowAIPanel(true);
    setGenerating(true);
    setGeneratedBio('');
    setIsStreaming(false);

    const result = await aiProfileService.generateBio(buildBioRequest());

    setGenerating(false);
    setIsStreaming(true);
    setGeneratedBio(result);
  };

  const handleRegenerate = async () => {
    setGenerating(true);
    setGeneratedBio('');
    setIsStreaming(false);

    const result = await aiProfileService.generateBio(buildBioRequest());

    setGenerating(false);
    setIsStreaming(true);
    setGeneratedBio(result);
  };

  const handleAccept = (accepted: string) => {
    setBio(accepted);
    setShowAIPanel(false);
    setGeneratedBio('');
  };

  // ── Save ────────────────────────────────────────────────────────────────────
  const handleSave = async () => {
    setSaving(true);
    setStatusMsg(null);
    const { error } = await profileService.upsertProfile({ bio, languages });
    setSaving(false);
    if (error) {
      setStatusMsg({ type: 'error', text: 'Failed to save profile' });
    } else {
      setStatusMsg({ type: 'success', text: 'Profile updated successfully!' });
    }
    setTimeout(() => setStatusMsg(null), 3000);
  };

  return (
    <div className="space-y-6">
      {/* Doctor ID Card */}
      <div className="flex justify-center md:justify-start">
        <DoctorIdCard
          name={profile.full_name || 'Dr. Rahul Sharma'}
          idNumber={profile.id ? String(profile.id).slice(0, 8).toUpperCase() : '43A1FAA9'}
          specialty={profile.specialization || 'Cardiology'}
          bloodGroup={'B+'}
        />
      </div>

      {/* Profile Strength Score */}
      <ProfileStrengthScore profile={{ ...profile, bio }} />

      {/* Professional Bio Card */}
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        {/* Card header */}
        <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
          <h3 className="font-bold text-lg text-slate-800">Professional Bio</h3>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowPreview(true)}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors"
            >
              <Eye className="w-4 h-4" /> Preview
            </button>
            <AISuggestButton
              onClick={showAIPanel ? handleRegenerate : handleAISuggest}
              loading={generating}
            />
          </div>
        </div>

        {/* Tone + Language selector (shown when AI panel is open) */}
        {showAIPanel && (
          <div className="mb-4 animate-in slide-in-from-top-2 duration-200">
            <ToneSelector
              tone={tone}
              language={language}
              onToneChange={t => {
                setTone(t);
              }}
              onLanguageChange={l => {
                setLanguage(l);
              }}
            />
          </div>
        )}

        {/* AI Generated Bio Box */}
        {showAIPanel && !generating && generatedBio && (
          <div className="mb-4">
            <GeneratedBioBox
              bio={generatedBio}
              isStreaming={isStreaming}
              onAccept={handleAccept}
              onRegenerate={handleRegenerate}
              onClose={() => { setShowAIPanel(false); setGeneratedBio(''); }}
            />
          </div>
        )}

        {/* Loading skeleton while generating */}
        {generating && (
          <div className="mb-4 rounded-xl border border-indigo-200 bg-indigo-50/50 p-4 animate-pulse space-y-2">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-6 h-6 rounded-full bg-indigo-200 animate-pulse" />
              <div className="h-3 w-32 bg-indigo-200 rounded-full" />
            </div>
            <div className="h-3 w-full bg-indigo-100 rounded-full" />
            <div className="h-3 w-5/6 bg-indigo-100 rounded-full" />
            <div className="h-3 w-4/5 bg-indigo-100 rounded-full" />
            <div className="h-3 w-3/4 bg-indigo-100 rounded-full" />
          </div>
        )}

        {/* Editable Bio textarea */}
        <textarea
          value={bio}
          onChange={e => setBio(e.target.value)}
          rows={5}
          placeholder="Write a professional bio or click ✨ AI Suggest to auto-generate one..."
          className="w-full bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm text-slate-700 min-h-[120px] focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none resize-y transition-colors"
        />
        <p className="mt-2 text-xs text-slate-400">
          {bio.length} characters · Use ✨ AI Suggest to generate a professional bio automatically.
        </p>
      </div>

      {/* Languages + Location */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
          <h3 className="font-bold text-lg text-slate-800 mb-4">Languages Spoken</h3>
          <input
            type="text"
            value={languages}
            onChange={e => setLanguages(e.target.value)}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue outline-none"
            placeholder="e.g. English, Spanish, Hindi"
          />
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
          <h3 className="font-bold text-lg text-slate-800 mb-4">Primary Location</h3>
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center shrink-0">
              <MapPin className="w-6 h-6 text-slate-500" />
            </div>
            <div>
              <p className="font-bold text-sm text-slate-800 mb-1">
                {profile.location || 'New York Medical Central'}
              </p>
              <p className="text-xs text-slate-500 leading-relaxed">
                123 Healthcare Ave, Suite 400<br />New York, NY 10001
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Save row */}
      <div className="flex flex-col sm:flex-row items-center justify-end gap-4">
        {statusMsg && (
          <div className={`text-sm font-medium ${statusMsg.type === 'error' ? 'text-red-500' : 'text-emerald-600'}`}>
            {statusMsg.text}
          </div>
        )}
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-brand-blue text-white hover:bg-blue-700 px-6 py-2.5 rounded-xl text-sm font-bold flex items-center gap-2 shadow-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4" />}
          {saving ? 'Saving…' : 'Save Changes'}
        </button>
      </div>

      {/* Patient-facing preview modal */}
      {showPreview && (
        <ProfilePreview
          profile={profile}
          bio={bio}
          onClose={() => setShowPreview(false)}
        />
      )}
    </div>
  );
};