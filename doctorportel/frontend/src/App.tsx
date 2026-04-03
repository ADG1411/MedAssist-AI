import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/Login';
import SignupPage from './pages/Signup';
import DashboardLayout from './layouts/DashboardLayout';
import Dashboard from './pages/Dashboard';
import PatientsPage from './pages/Patients';
import TodayAppointments from './pages/TodayAppointments';
import TicketCaseView from './pages/TicketCaseView';
import Profile from './pages/Profile';
import EmergencyAlerts from './pages/EmergencyAlerts';
import AIAssistant from './pages/AIAssistant';
import Analytics from './pages/Analytics';
import PrescriptionWriter from './pages/PrescriptionWriter';
import PatientCaseFlow from './pages/PatientCaseFlow';
import QRAccess from './pages/QRAccess';
import PatientRecordPage from './pages/PatientRecordPage';
import ReferralPage from './pages/ReferralPage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />

        {/* Dashboard Pages */}
        <Route path="/dashboard" element={<DashboardLayout />}>
          <Route index element={<Dashboard />} />
          <Route path="patients" element={<PatientsPage />} />
          <Route path="today" element={<TodayAppointments />} />
          <Route path="analytics" element={<Analytics />} />
          <Route path="prescription" element={<PrescriptionWriter />} />
          <Route path="sos" element={<EmergencyAlerts />} />
          <Route path="profile" element={<Profile />} />
          <Route path="ai" element={<AIAssistant />} />
          <Route path="case" element={<PatientCaseFlow />} />
          <Route path="medcard" element={<QRAccess />} />
          <Route path="medcard/record/:patientId" element={<PatientRecordPage />} />
          <Route path="referral" element={<ReferralPage />} />
        </Route>
        
        {/* Fullscreen Case View - Outside Dashboard Layout so it occupies the full screen */}
        <Route path="/case/:id" element={<TicketCaseView />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;