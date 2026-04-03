import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Loader2 } from 'lucide-react';

import { QRPassportPanel } from '../components/consultation/QRPassportPanel';
import { VideoConsultation } from '../components/consultation/VideoConsultation';
import { AIInsightsPanel } from '../components/consultation/AIInsightsPanel';

import { getPatientIntelligence, startAIConsultationAnalysis } from '../services/consultationService';
import type { FullConsultationSummary, AIAnalysisResult } from '../types/consultation';

export function ConsultationRoom() {
  const { patientId = 'pat-123' } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<FullConsultationSummary | null>(null);
  
  const [aiData, setAiData] = useState<AIAnalysisResult | null>(null);
  const [aiLoading, setAiLoading] = useState(false);

  useEffect(() => {
    async function load() {
      try {
        const result = await getPatientIntelligence(patientId);
        setData(result);
        
        // Setup initial AI Insights after data loads
        setAiLoading(true);
        const aiResult = await startAIConsultationAnalysis(patientId, "patient just joined");
        setAiData(aiResult);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
        setAiLoading(false);
      }
    }
    load();
  }, [patientId]);

  const handleRefreshAI = async () => {
    setAiLoading(true);
    try {
      const result = await startAIConsultationAnalysis(patientId, "updated symptoms via video: mild chest pain");
      setAiData(result);
    } finally {
      setAiLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="h-screen w-full flex flex-col items-center justify-center bg-slate-50 gap-4">
        <Loader2 className="w-10 h-10 text-indigo-500 animate-spin" />
        <h2 className="text-sm font-black text-slate-500 tracking-widest uppercase animate-pulse">
          Loading Consultation Environment...
        </h2>
      </div>
    );
  }

  if (!data) return <div className="p-10 text-center">Failed to load consultation</div>;

  return (
    <div className="h-screen w-full flex flex-col bg-white overflow-hidden">
      
      {/* Top Navbar */}
      <div className="h-14 bg-white border-b border-slate-200 flex items-center px-4 shrink-0 shadow-sm z-20">
        <button 
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 mr-2 hover:bg-slate-100 rounded-full transition-colors text-slate-500"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <span className="bg-indigo-100 text-indigo-700 text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-md mr-3 border border-indigo-200">
          Live Consult
        </span>
        <h1 className="text-sm font-black text-slate-800">
          Smart Consultation Room
        </h1>
      </div>

      {/* 3-Panel Layout */}
      {/* 
          On Mobile: They stack or we use tabs (for simplicity here, we'll flex-col then hide side panels or allow scrolling, 
          but grid helps with desktop view). 
      */}
      <div className="flex-1 flex flex-col lg:flex-row overflow-hidden relative">
        
        {/* Left Panel: QR Passport */}
        <div className="hidden lg:block w-[320px] shrink-0 border-r border-slate-200 bg-white z-10 transition-transform">
          <QRPassportPanel data={data} />
        </div>

        {/* Center Panel: Video */}
        <div className="flex-1 bg-black relative">
          <VideoConsultation patientName={data.patient.name} />
        </div>

        {/* Right Panel: AI Insights */}
        <div className="hidden lg:block w-[340px] xl:w-[380px] shrink-0 border-l border-slate-200 bg-white z-10">
          <AIInsightsPanel 
            patientId={patientId} 
            aiData={aiData} 
            loading={aiLoading} 
            onRefresh={handleRefreshAI} 
          />
        </div>

        {/* Mobile Tabs / Stacking could be added by replacing the above with a tab interface on small screens. 
            For now, hidden on very small screens, focusing on the desktop dashboard UX as requested. 
        */}
      </div>
    </div>
  );
}
