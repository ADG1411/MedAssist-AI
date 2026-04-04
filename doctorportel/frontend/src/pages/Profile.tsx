import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ProfileHeader } from '../components/profile/ProfileHeader';
import { TabsNav } from '../components/profile/TabsNav';
import type { TabId } from '../components/profile/TabsNav';
import { OverviewTab } from '../components/profile/OverviewTab';
import { WorkplaceTab } from '../components/profile/WorkplaceTab';
import { AvailabilityTab } from '../components/profile/AvailabilityTab';
import { FeesTab } from '../components/profile/FeesTab';
import { ReviewsTab } from '../components/profile/ReviewsTab';
import { DocumentsTab } from '../components/profile/DocumentsTab';
import { SettingsTab } from '../components/profile/SettingsTab';
import { StatsSidebar } from '../components/profile/StatsSidebar';
import { AIAssistant } from '../components/profile/AIAssistant';
import { getProfile as getRealProfile } from '../services/doctorProfileService';
import { profileService, type DoctorProfile } from '../services/profileService';

export default function Profile() {
  const navigate = useNavigate();
  const defaultProfile: DoctorProfile = {
    id: "mock-1",
    user_id: "user-1",
    full_name: "Doctor",
    email: "",
    phone_number: "+1 (555) 123-4567",
    specialization: "General",
    experience_years: 0,
    rating: 5.0,
    languages: "English",
    bio: "",
    location: "",
    avatar: "https://ui-avatars.com/api/?name=Doctor&background=1A6BFF&color=fff",
    is_active: true,
    stats: {
      total_patients: 0,
      consultations: 0,
      success_rate: "100%",
      earnings_this_month: 0
    }
  };

  const [activeTab, setActiveTab] = useState<TabId>('overview');
  const [profile, setProfile] = useState<DoctorProfile>(defaultProfile);

  useEffect(() => {
    const fetchProfileData = async () => {
      try {
        const [realProfile, oldProfile] = await Promise.all([
          getRealProfile(),
          profileService.getProfile()
        ]);

        if (realProfile) {
          setProfile({
            id: realProfile.id || "mock-1",
            user_id: realProfile.id || "user-1",
            full_name: realProfile.overview?.full_name || "Doctor",
            email: "doctor@example.com",
            phone_number: "+1 (555) 123-4567",
            specialization: realProfile.overview?.specialization || "General Medicine",
            experience_years: realProfile.overview?.years_of_experience || 0,
            rating: oldProfile?.rating || 5.0,
            languages: realProfile.overview?.languages?.join(", ") || "English",
            bio: realProfile.overview?.bio || "",
            location: realProfile.overview?.city || "",
            avatar: realProfile.overview?.profile_photo || `https://ui-avatars.com/api/?name=${encodeURIComponent(realProfile.overview?.full_name || 'Doctor')}&background=1A6BFF&color=fff`,
            is_active: realProfile.verification_status === 'approved',
            stats: oldProfile?.stats || defaultProfile.stats
          });
        }
      } catch (error) {
        console.error("Failed to load generic profile", error);
      }
    };
    fetchProfileData();
  }, []);

  const renderContent = () => {
    switch (activeTab) {
      case 'overview': return <OverviewTab profile={profile} />;
      case 'workplace': return <WorkplaceTab />;
      case 'availability': return <AvailabilityTab />;
      case 'fees': return <FeesTab />;
      case 'reviews': return <ReviewsTab />;
      case 'documents': return <DocumentsTab />;
      case 'settings': return <SettingsTab />;
      default: return <OverviewTab profile={profile} />;
    }
  };

  return (
    <div className="w-full mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-safe">
      
      <ProfileHeader 
        profile={profile}
        onEdit={() => navigate('/dashboard/profile-setup')}
        onShare={() => console.log('Share profile')}
        onPreview={() => console.log('Preview profile')}
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8">
        
        {/* Main Content Area */}
        <div className="lg:col-span-2 space-y-6">
          <TabsNav activeTab={activeTab} onChange={setActiveTab} />
          
          <div className="min-h-[400px]">
            {renderContent()}
          </div>
        </div>

        {/* Right Sidebar */}
        <div className="lg:col-span-1 border-t lg:border-t-0 pt-6 lg:pt-0  border-slate-200">
          <StatsSidebar stats={profile.stats} />
          <AIAssistant />
        </div>

      </div>
    </div>
  );
}