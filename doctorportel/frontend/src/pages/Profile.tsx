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
import { profileService, type DoctorProfile } from '../services/profileService';

export default function Profile() {
  const navigate = useNavigate();
  const defaultProfile: DoctorProfile = {
    id: "mock-1",
    user_id: "user-1",
    full_name: "Dr. Sarah Mitchell",
    email: "sarah.mitchell@example.com",
    phone_number: "+1 (555) 123-4567",
    specialization: "Cardiology",
    experience_years: 12,
    rating: 4.9,
    languages: "English, Spanish",
    bio: "Experienced cardiologist with over 10 years of practice.",
    location: "New York, USA",
    avatar: "https://i.pravatar.cc/150?img=32",
    is_active: true,
    stats: {
      total_patients: 1250,
      consultations: 85,
      success_rate: "98%",
      earnings_this_month: 12450.00
    }
  };

  const [activeTab, setActiveTab] = useState<TabId>('overview');
  const [profile, setProfile] = useState<DoctorProfile>(defaultProfile);

  useEffect(() => {
    const fetchProfileData = async () => {
      // Removed setLoading(true) to show data immediately
      const data = await profileService.getProfile();
      if (data) {
        setProfile(data);
      }
      // No longer displaying an error if the database connection fails
      // as we want to show the mock data directly.
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