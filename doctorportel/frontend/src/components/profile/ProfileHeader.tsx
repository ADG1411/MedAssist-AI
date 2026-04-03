import { CheckCircle2, Share2, Edit2, Eye } from 'lucide-react';
import type { DoctorProfile } from '../../services/profileService';

interface ProfileHeaderProps {
  profile: DoctorProfile;
  onEdit: () => void;
  onShare: () => void;
  onPreview: () => void;
}

export const ProfileHeader = ({ profile, onEdit, onShare, onPreview }: ProfileHeaderProps) => {

  return (
    <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden mb-6">
      <div className="h-32 bg-gradient-to-r from-brand-blue/80 to-blue-600/80 relative">
        <button 
          onClick={onEdit}
          className="absolute top-4 right-4 bg-white/20 hover:bg-white/30 text-white p-2 rounded-lg backdrop-blur-sm transition-colors"
        >
          <Edit2 className="w-4 h-4" />
        </button>
      </div>
      
      <div className="px-6 pb-6 relative">
        <div className="flex flex-col sm:flex-row gap-6">
          {/* Avatar */}
          <div className="-mt-16 relative w-32 h-32 shrink-0">
            <img 
              src={profile.avatar || "https://ui-avatars.com/api/?name=Dr+Smith"} 
              alt={profile.full_name}
              className="w-full h-full rounded-2xl border-4 border-white shadow-md object-cover bg-white"
            />
            <button className="absolute bottom-2 right-2 bg-white text-slate-700 p-1.5 rounded-lg shadow-sm border border-slate-200 hover:bg-slate-50">
              <Edit2 className="w-3 h-3" />
            </button>
          </div>

          {/* Info */}
          <div className="flex-1 pt-2">
            <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h1 className="text-2xl font-bold text-slate-800">{profile.full_name}</h1>
                  {profile.is_active && <CheckCircle2 className="w-5 h-5 text-blue-500" />}
                </div>
                <p className="text-brand-blue font-medium mb-2">{profile.specialization}</p>
                <div className="flex flex-wrap items-center gap-4 text-sm text-slate-600">
                  <span className="flex items-center gap-1 font-medium bg-amber-50 text-amber-700 px-2 py-0.5 rounded border border-amber-200">
                    ⭐ {profile.rating} Rating
                  </span>
                  <span>{profile.experience_years} Years Experience</span>
                  <span>{profile.languages}</span>
                </div>
              </div>

              {/* Actions */}
              <div className="flex gap-2">
                <button 
                  onClick={onShare}
                  className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 text-slate-700 rounded-xl hover:bg-slate-50 transition-colors shadow-sm text-sm font-bold"
                >
                  <Share2 className="w-4 h-4" /> Share
                </button>
                <button 
                  onClick={onPreview}
                  className="flex items-center gap-2 px-4 py-2 bg-brand-blue text-white rounded-xl hover:bg-blue-700 transition-colors shadow-sm text-sm font-bold"
                >
                  <Eye className="w-4 h-4" /> Preview View
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};