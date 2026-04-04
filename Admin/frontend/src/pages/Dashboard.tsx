import React from 'react';
import { DashboardView as EcommerceDashboard } from '@/components/watermelon/e-commerce-dashboard/dashboardView';

export const Dashboard: React.FC = () => {
  return (
    <div className="fade-in animate-in slide-in-from-bottom-2 duration-300 w-full h-full">
      <EcommerceDashboard />
    </div>
  );
};

