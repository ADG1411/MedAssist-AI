import { useState, useEffect } from 'react';
import { Bot, Sparkles, RefreshCcw, Calendar, History, ClipboardList, Pill, Globe, Database } from 'lucide-react';
import type { ChatMessage } from '../types/chat';
import { sendChatMessage } from '../services/aiChatService';
import { AiInput, type Message, type Suggestion } from '../components/ui/ai-input-001';
import { PiLightbulbFilament } from "react-icons/pi";
import { Cpu, Zap } from "lucide-react";

import { MessageBubble } from '../components/ai/MessageBubble';

const STORAGE_KEY = 'medassist_chat_history';

const AIAssistant = () => {
  const [messages, setMessages] = useState<ChatMessage[]>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });
  const [isLoading, setIsLoading] = useState(false);
  const [searchMode, setSearchMode] = useState<'auto' | 'offline' | 'online'>('auto');

  // Persist chat history to localStorage
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(messages.slice(-50))); // keep last 50
    } catch { /* ignore quota errors */ }
  }, [messages]);

  // Map our ChatMessage to AiInput's Message type
  const mappedMessages: Message[] = messages.map(m => ({
    id: m.id,
    text: m.content,
    sender: m.role === 'user' ? 'user' : 'ai',
    originalMessage: m 
  }));

  const fileToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result as string);
      reader.onerror = error => reject(error);
    });
  };

  const handleSend = async (text: string, _modelId: string, attachments: File[] = []) => {
    if ((!text.trim() && attachments.length === 0) || isLoading) return;

    let base64Images: string[] = [];
    if (attachments.length > 0) {
      try {
        base64Images = await Promise.all(
          attachments
            .filter(file => file.type.startsWith('image/'))
            .map(file => fileToBase64(file))
        );
      } catch (err) {
        console.error("Failed to convert images", err);
      }
    }

    const userMsg: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'user',
      content: text,
      timestamp: new Date().toISOString(),
      images: base64Images
    };

    setMessages(prev => [...prev, userMsg]);
    setIsLoading(true);

    try {
      const resp = await sendChatMessage(text, messages, base64Images, searchMode);
      setMessages(prev => [...prev, resp]);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  const APP_MODELS = [
    { id: "gpt-4o", name: "Clinical GPT-4", icon: <PiLightbulbFilament className="h-4 w-4" /> },
    { id: "med-gemini", name: "Med-Gemini Pro", icon: <Cpu className="h-4 w-4" /> },
    { id: "llama-med", name: "Llama Clinical", icon: <Zap className="h-4 w-4" /> },
  ];

  const CLINICAL_SUGGESTIONS: Suggestion[] = [
    { 
      id: 'sched', 
      label: "Today's Clinical Schedule", 
      sub: "Show my appointments and patient queue",
      icon: <Calendar className="w-5 h-5" /> 
    },
    { 
      id: 'history', 
      label: "Recent Patient History", 
      sub: "Summarize records for my last 5 patients",
      icon: <History className="w-5 h-5" /> 
    },
    { 
      id: 'presc', 
      label: "Draft New Prescription", 
      sub: "Generate medication orders for consultation",
      icon: <Pill className="w-5 h-5" /> 
    },
    { 
      id: 'cases', 
      label: "Summarize Complex Cases", 
      sub: "AI analysis of complicated diagnostics",
      icon: <ClipboardList className="w-5 h-5" /> 
    },
  ];

  const modeConfig = {
    auto: { label: 'Auto', icon: Sparkles, color: 'bg-indigo-50 text-indigo-600 border-indigo-200' },
    offline: { label: 'Local DB', icon: Database, color: 'bg-emerald-50 text-emerald-600 border-emerald-200' },
    online: { label: 'Online', icon: Globe, color: 'bg-blue-50 text-blue-600 border-blue-200' },
  };

  const cycleMode = () => {
    const modes: Array<'auto' | 'offline' | 'online'> = ['auto', 'offline', 'online'];
    const currentIdx = modes.indexOf(searchMode);
    setSearchMode(modes[(currentIdx + 1) % modes.length]);
  };

  const CurrentModeIcon = modeConfig[searchMode].icon;

  return (
    <div className="flex flex-col h-full w-full bg-slate-50 relative overflow-hidden">
      {/* HEADER */}
      <div className="flex items-center justify-between px-4 sm:px-6 lg:px-8 py-4 sm:py-5 bg-white border-b border-slate-200 z-10 shrink-0">
        <div className="flex items-center gap-3 sm:gap-4 min-w-0">
          <div className="relative shrink-0">
            <div className="bg-gradient-to-br from-indigo-500 to-cyan-400 p-2 sm:p-2.5 rounded-xl text-white shadow-md shadow-indigo-200 relative">
              <Bot className="w-5 h-5" />
            </div>
            <span className="absolute -bottom-1 -right-1 flex h-3 w-3 sm:h-3.5 sm:w-3.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 sm:h-3.5 sm:w-3.5 bg-emerald-500 border-2 border-white"></span>
            </span>
          </div>
          <div className="min-w-0">
            <h2 className="text-lg sm:text-xl font-bold text-slate-800 tracking-tight truncate">Dr. AI Co-Pilot</h2>
            <div className="flex items-center gap-1.5 mt-0.5">
              <Sparkles className="w-3 sm:w-3.5 h-3 sm:h-3.5 text-amber-500 shrink-0" />
              <p className="text-[11px] sm:text-[12px] text-slate-500 font-medium truncate">Powered by Step-3.5-Flash</p>
            </div>
          </div>
        </div>
        
        <div className="flex items-center gap-1.5 sm:gap-3 shrink-0">
          {/* Mode Toggle */}
          <button 
            onClick={cycleMode}
            className={`flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 sm:py-2 text-[11px] sm:text-[12px] font-bold border rounded-xl transition-all ${modeConfig[searchMode].color}`}
            title={`Mode: ${modeConfig[searchMode].label}. Click to switch.`}
          >
            <CurrentModeIcon className="w-3.5 h-3.5" />
            <span className="hidden xs:inline sm:inline">{modeConfig[searchMode].label}</span>
          </button>

          <button 
            onClick={() => { setMessages([]); localStorage.removeItem(STORAGE_KEY); }}
            className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 sm:py-2 text-[11px] sm:text-sm font-medium text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition-colors"
          >
            <RefreshCcw className="w-3.5 sm:w-4 h-3.5 sm:h-4" />
            <span className="hidden sm:inline">New Chat</span>
          </button>
        </div>
      </div>

      <div className="flex-1 relative min-h-0">
        <AiInput 
          messages={mappedMessages}
          renderMessage={(msg) => <MessageBubble message={msg.originalMessage} />}
          onSendMessage={handleSend}
          models={APP_MODELS}
          suggestions={CLINICAL_SUGGESTIONS}
          placeholder="Ask for patient status, draft a prescription, or summarize a case..."
          isLoading={isLoading}
        />
      </div>
    </div>
  );
};

export default AIAssistant;