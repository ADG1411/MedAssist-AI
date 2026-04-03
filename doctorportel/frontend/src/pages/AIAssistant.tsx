import { useState } from 'react';
import { Bot, Sparkles, RefreshCcw, Calendar, History, ClipboardList, Pill } from 'lucide-react';
import type { ChatMessage } from '../types/chat';
import { sendChatMessage } from '../services/aiChatService';
import { AiInput, type Message, type Suggestion } from '../components/ui/ai-input-001';
import { PiLightbulbFilament } from "react-icons/pi";
import { Cpu, Zap } from "lucide-react";

import { MessageBubble } from '../components/ai/MessageBubble';

const AIAssistant = () => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  // Map our ChatMessage to AiInput's Message type
  const mappedMessages: Message[] = messages.map(m => ({
    id: m.id,
    text: m.content,
    sender: m.role === 'user' ? 'user' : 'ai',
    originalMessage: m 
  }));

  const handleSend = async (text: string, modelId: string) => {
    if (!text.trim() || isLoading) return;

    const userMsg: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'user',
      content: text,
      timestamp: new Date().toISOString()
    };

    setMessages(prev => [...prev, userMsg]);
    setIsLoading(true);

    try {
      const resp = await sendChatMessage(text, messages);
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

  return (
    <div className="flex flex-col h-full w-full bg-slate-50 relative overflow-hidden">
      {/* HEADER */}
      <div className="flex items-center justify-between px-6 lg:px-8 py-5 bg-white border-b border-slate-200 z-10 shrink-0">
        <div className="flex items-center gap-4">
          <div className="relative">
            <div className="bg-gradient-to-br from-indigo-500 to-cyan-400 p-2.5 rounded-xl text-white shadow-md shadow-indigo-200 relative">
              <Bot className="w-5 h-5" />
            </div>
            <span className="absolute -bottom-1 -right-1 flex h-3.5 w-3.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3.5 w-3.5 bg-emerald-500 border-2 border-white"></span>
            </span>
          </div>
          <div>
            <h2 className="text-xl font-bold text-slate-800 tracking-tight">Dr. AI Co-Pilot</h2>
            <div className="flex items-center gap-1.5 mt-0.5">
              <Sparkles className="w-3.5 h-3.5 text-amber-500" />
              <p className="text-[12px] text-slate-500 font-medium">Powered by OpenMED-v4</p>
            </div>
          </div>
        </div>
        
        <div className="flex items-center gap-3">
           <button 
             onClick={() => setMessages([])}
             className="flex items-center gap-2 px-3 py-2 text-sm font-medium text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition-colors"
           >
             <RefreshCcw className="w-4 h-4" />
             <span className="hidden sm:inline">New Chat</span>
           </button>
        </div>
      </div>

      <div className="flex-1 relative">
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