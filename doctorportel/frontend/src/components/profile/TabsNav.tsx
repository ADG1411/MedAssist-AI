import { cn } from '../../layouts/DashboardLayout';

export type TabId = 'overview' | 'workplace' | 'availability' | 'fees' | 'reviews' | 'documents' | 'settings';

interface TabsNavProps {
  activeTab: TabId;
  onChange: (tab: TabId) => void;
}

const TABS: { id: TabId; label: string }[] = [
  { id: 'overview', label: 'Overview' },
  { id: 'workplace', label: 'Workplaces' },
  { id: 'availability', label: 'Availability' },
  { id: 'fees', label: 'Fees & Pricing' },
  { id: 'reviews', label: 'Reviews' },
  { id: 'documents', label: 'Documents' },
  { id: 'settings', label: 'Settings' },
];

export const TabsNav = ({ activeTab, onChange }: TabsNavProps) => {
  return (
    <div className="bg-white rounded-2xl p-2 shadow-sm border border-slate-200 mb-6 overflow-x-auto hide-scrollbar sticky top-0 z-40">
      <div className="flex items-center min-w-max">
        {TABS.map(tab => (
          <button
            key={tab.id}
            onClick={() => onChange(tab.id)}
            className={cn(
              "px-5 py-2.5 rounded-xl text-sm font-bold transition-all whitespace-nowrap",
              activeTab === tab.id 
                ? "bg-slate-900 text-white shadow-md" 
                : "text-slate-500 hover:text-slate-800 hover:bg-slate-50"
            )}
          >
            {tab.label}
          </button>
        ))}
      </div>
    </div>
  );
};