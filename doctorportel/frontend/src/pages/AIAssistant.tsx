import { useState, useRef, useEffect } from 'react';
import { Send, Bot, Sparkles, AlertCircle, RefreshCcw } from 'lucide-react';
import type { ChatMessage } from '../types/chat';
import { MessageBubble } from '../components/ai/MessageBubble';
import { PromptSuggestions } from '../components/ai/PromptSuggestions';
import { AITypingIndicator } from '../components/ai/AITypingIndicator';
import { sendChatMessage } from '../services/aiChatService';
import { cn } from '../layouts/DashboardLayout';

const AIAssistant = () => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputValue, setInputValue] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  const handleSend = async (text: string) => {
    if (!text.trim() || isLoading) return;

    const userMsg: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'user',
      content: text,
      timestamp: new Date().toISOString()
    };

    setMessages(prev => [...prev, userMsg]);
    setInputValue("");
    setIsLoading(true);

    try {
      const resp = await sendChatMessage(text, messages);
      setMessages(prev => [...prev, resp]);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
      setTimeout(() => inputRef.current?.focus(), 100);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend(inputValue);
    }
  };

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

      {/* CHAT MESSAGES AREA */}
      <div className="flex-1 overflow-y-auto px-4 md:px-8 pt-8 pb-40 space-y-6 flex flex-col scroll-smooth relative bg-white/50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:16px_16px]">
        {messages.length === 0 ? (
          <div className="m-auto flex flex-col items-center justify-center text-center max-w-2xl fade-in w-full mt-10 md:mt-16">
            <div className="relative inline-flex mb-8">
              <div className="absolute inset-0 bg-indigo-500/20 rounded-full blur-2xl"></div>
              <div className="bg-white p-5 rounded-3xl shadow-xl shadow-indigo-100/50 border border-white relative">
                <Bot className="w-14 h-14 text-indigo-600" />
              </div>
            </div>
            <h3 className="text-3xl font-extrabold text-slate-800 mb-3 tracking-tight">Good afternoon, Doctor.</h3>
            <p className="text-slate-500 mb-10 text-lg max-w-lg leading-relaxed">
              I'm your clinical AI assistant. I can help analyze records, draft prescriptions, or map out your day.
            </p>
            <PromptSuggestions onSelect={handleSend} />
          </div>
        ) : (
          <div className="flex flex-col space-y-6">
            {messages.map((msg) => (
              <div key={msg.id} className={cn("flex flex-col w-full", msg.role === 'user' ? 'items-end' : 'items-start')}>
                 <MessageBubble message={msg} />
              </div>
            ))}
            {isLoading && (
              <AITypingIndicator />
            )}
            <div ref={bottomRef} className="h-4 w-full" />
          </div>
        )}
      </div>

      {/* INPUT AREA */}
      <div className="absolute bottom-0 left-0 right-0 z-20 bg-gradient-to-t from-slate-50 via-slate-50/95 to-transparent pt-10 pb-6 px-4 md:px-8">
        <div className="max-w-4xl mx-auto relative">
          
          <div className="absolute -top-12 left-0 right-0 flex justify-center pointer-events-none fade-in">
            {messages.length > 0 && messages.length < 5 && (
              <div className="bg-white border border-amber-200/50 text-slate-600 text-[11px] font-medium px-4 py-1.5 rounded-full pointer-events-auto shadow-sm flex items-center gap-2">
                <AlertCircle className="w-3.5 h-3.5 text-amber-500" /> AI-generated content may be inaccurate. Verify clinical data.
              </div>
            )}
          </div>

          <div className="relative group flex items-end bg-white rounded-3xl border border-slate-200 shadow-lg shadow-indigo-500/5 focus-within:shadow-xl focus-within:shadow-indigo-500/10 focus-within:border-indigo-300 transition-all overflow-hidden text-sm">
            <textarea
              ref={inputRef}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={(e: React.KeyboardEvent<HTMLTextAreaElement>) => handleKeyDown(e)}
              placeholder="Ask for patient status, draft a prescription, or summarize a case..."
              className="w-full bg-transparent px-6 py-4 min-h-[60px] max-h-[200px] outline-none text-slate-700 resize-none placeholder:text-slate-400 leading-relaxed overflow-hidden my-1"
              rows={1}
            />
            
            <div className="flex items-center p-3 h-full self-end shrink-0">
               <button 
                 onClick={() => handleSend(inputValue)}
                 disabled={!inputValue.trim() || isLoading}
                 className="p-3 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-100 disabled:text-slate-400 text-white rounded-2xl transition-all hover:scale-105 active:scale-95 disabled:scale-100 disabled:hover:bg-slate-100 flex items-center justify-center shadow-md disabled:shadow-none"
               >
                 <Send className="w-4 h-4" />
               </button>
            </div>
          </div>
          
          <div className="text-center mt-3 text-[11px] text-slate-400 font-medium">
            Shift + Enter for new line • Protected by Enterprise Encryption
          </div>

        </div>
      </div>
    </div>
  );
};

export default AIAssistant;